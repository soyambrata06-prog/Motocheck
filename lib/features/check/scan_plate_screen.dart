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
          rotation: InputImageRotation.rotation90deg, // Adjust based on device
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Simple regex for Indian Plate (e.g., MH 12 AB 1234)
      RegExp plateRegex = RegExp(r'[A-Z]{2}\s?[0-9]{2}\s?[A-Z]{1,2}\s?[0-9]{4}');
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final match = plateRegex.firstMatch(line.text.toUpperCase());
          if (match != null) {
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

    // Feedback and navigation
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'SCAN PLATE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          IconButton(
            icon: Icon(
              _cameraController!.value.flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off,
              color: Colors.white, 
              size: 28
            ),
            onPressed: () {
              setState(() {
                _cameraController!.setFlashMode(
                  _cameraController!.value.flashMode == FlashMode.torch ? FlashMode.off : FlashMode.torch
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScanningFrame() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Scanning Line
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 140 * _scanAnimation.value,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00C853).withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _detectedPlate != null ? 'Plate Found: $_detectedPlate' : 'Align license plate in frame',
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF00C853), size: 20),
            const SizedBox(width: 12),
            Text(
              _detectedPlate != null ? 'Extracting Data...' : 'AI Engine Active',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(int index) {
    const double size = 30;
    const double thickness = 4;
    const color = Color(0xFF00C853);
    
    return Positioned(
      top: (index == 0 || index == 1) ? -1 : null,
      bottom: (index == 2 || index == 3) ? -1 : null,
      left: (index == 0 || index == 2) ? -1 : null,
      right: (index == 1 || index == 3) ? -1 : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: (index == 0 || index == 1) ? BorderSide(color: color, width: thickness) : BorderSide.none,
            bottom: (index == 2 || index == 3) ? BorderSide(color: color, width: thickness) : BorderSide.none,
            left: (index == 0 || index == 2) ? BorderSide(color: color, width: thickness) : BorderSide.none,
            right: (index == 1 || index == 3) ? BorderSide(color: color, width: thickness) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? const Radius.circular(15) : Radius.zero,
            topRight: index == 1 ? const Radius.circular(15) : Radius.zero,
            bottomLeft: index == 2 ? const Radius.circular(15) : Radius.zero,
            bottomRight: index == 3 ? const Radius.circular(15) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
