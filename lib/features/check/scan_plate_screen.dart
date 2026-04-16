import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'result_screen.dart';

class ScanPlateScreen extends StatefulWidget {
  const ScanPlateScreen({super.key});

  @override
  State<ScanPlateScreen> createState() => _ScanPlateScreenState();
}

class _ScanPlateScreenState extends State<ScanPlateScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  
  bool _isPermissionGranted = false;
  bool _isProcessing = false;
  String? _detectedPlate;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(_animationController);
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _isPermissionGranted = true);
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
        _startImageStream();
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _startImageStream() {
    _cameraController?.startImageStream((image) {
      if (_isProcessing) return;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    _isProcessing = true;
    
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation90deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Simple regex for Indian/International Plate
      RegExp plateRegex = RegExp(r'[A-Z]{1,3}\s?[0-9]{1,4}\s?[A-Z]{0,3}');
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final match = plateRegex.firstMatch(line.text.toUpperCase());
          if (match != null && match.group(0)!.length > 4) {
            _onPlateDetected(match.group(0)!);
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Text recognition error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _onPlateDetected(String plate) {
    if (_detectedPlate != null) return;
    
    setState(() {
      _detectedPlate = plate;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ResultScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text('Camera permission required', style: TextStyle(color: Colors.white))));
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Color(0xFF00C853))));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          
          // Scanning Overlay UI
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                _buildScanningFrame(),
                const SizedBox(height: 40),
                _buildStatusText(),
                const Spacer(),
                _buildBottomInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Column(
            children: [
              Text(
                'AI VISION',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.38),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
                'SCANNER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: Icon(
                _cameraController!.value.flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off,
                color: Colors.white, 
                size: 20
              ),
              onPressed: () {
                setState(() {
                  _cameraController!.setFlashMode(
                    _cameraController!.value.flashMode == FlashMode.torch ? FlashMode.off : FlashMode.torch
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningFrame() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
        ),
        child: Stack(
          children: [
            // Scanning Line
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 180 * _scanAnimation.value,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C853).withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Corner Accents
            ...List.generate(4, (i) => _buildCorner(i)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_detectedPlate == null)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF00C853),
              ),
            ),
          if (_detectedPlate == null) const SizedBox(width: 12),
          Text(
            _detectedPlate != null ? 'PLATE DETECTED' : 'POSITION PLATE IN FRAME',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.security_rounded, color: Color(0xFF00C853), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SECURE SCAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Encryption active',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(int index) {
    const double size = 40;
    const double thickness = 4;
    const color = Color(0xFF00C853);
    
    return Positioned(
      top: (index == 0 || index == 1) ? -2 : null,
      bottom: (index == 2 || index == 3) ? -2 : null,
      left: (index == 0 || index == 2) ? -2 : null,
      right: (index == 1 || index == 3) ? -2 : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: (index == 0 || index == 1) ? const BorderSide(color: color, width: thickness) : BorderSide.none,
            bottom: (index == 2 || index == 3) ? const BorderSide(color: color, width: thickness) : BorderSide.none,
            left: (index == 0 || index == 2) ? const BorderSide(color: color, width: thickness) : BorderSide.none,
            right: (index == 1 || index == 3) ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? const Radius.circular(24) : Radius.zero,
            topRight: index == 1 ? const Radius.circular(24) : Radius.zero,
            bottomLeft: index == 2 ? const Radius.circular(24) : Radius.zero,
            bottomRight: index == 3 ? const Radius.circular(24) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
