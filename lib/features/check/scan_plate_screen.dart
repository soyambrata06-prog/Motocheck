import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
    
    _scanAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.9).chain(CurveTween(curve: Curves.easeInOutQuart)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 0.1).chain(CurveTween(curve: Curves.easeInOutQuart)),
        weight: 50,
      ),
    ]).animate(_animationController);
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (mounted) setState(() => _isPermissionGranted = true);
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Try to find the back camera
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: PlatformDispatcher.instance.defaultRouteName.contains('android') 
          ? ImageFormatGroup.yuv420 
          : ImageFormatGroup.bgra8888,
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
      if (_isProcessing || _detectedPlate != null) return;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    _isProcessing = true;
    
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Enhanced regex for Indian License Plates
      // Standard: MH12AB1234, MH 12 AB 1234
      // BH Series: 22BH1234AA
      RegExp plateRegex = RegExp(
        r'([A-Z]{2}\s?[0-9]{1,2}\s?[A-Z]{1,3}\s?[0-9]{4})|'
        r'([0-9]{2}\s?BH\s?[0-9]{4}\s?[A-Z]{1,2})',
        caseSensitive: false,
      );
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.toUpperCase().trim();
          final match = plateRegex.firstMatch(text);
          
          if (match != null) {
            final plate = match.group(0)!.replaceAll(RegExp(r'\s+'), '');
            if (plate.length >= 7 && plate.length <= 10) {
              _onPlateDetected(plate);
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Text recognition error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final sensorOrientation = _cameraController!.description.sensorOrientation;
    InputImageRotation? rotation;
    if (defaultTargetPlatform == TargetPlatform.android) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (defaultTargetPlatform == TargetPlatform.android && format != InputImageFormat.yuv420) ||
        (defaultTargetPlatform == TargetPlatform.iOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1 && defaultTargetPlatform == TargetPlatform.iOS) return null;
    if (image.planes.length != 3 && defaultTargetPlatform == TargetPlatform.android) return null;

    final bytes = defaultTargetPlatform == TargetPlatform.android
        ? _concatenatePlanes(image.planes)
        : image.planes[0].bytes;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  void _onPlateDetected(String plate) {
    if (_detectedPlate != null) return;
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      _detectedPlate = plate;
    });

    // Slow down for visual confirmation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(plateNumber: plate),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
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
      return _buildPermissionDeniedView();
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
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          
          // Cutout for the scanning area
          _buildScanningCutout(),

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

  Widget _buildScanningCutout() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(32),
              ),
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
            // Corner Accents
            ...List.generate(4, (i) => _buildCorner(i)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_detectedPlate),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: _detectedPlate != null ? const Color(0xFF00C853) : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: _detectedPlate != null ? [
            BoxShadow(
              color: const Color(0xFF00C853).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ] : [],
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
                  color: Color(0xFF448AFF),
                ),
              ),
            if (_detectedPlate != null)
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Text(
              _detectedPlate != null ? _detectedPlate! : 'FINDING NUMBER PLATE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
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
                color: const Color(0xFF448AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF448AFF), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'AI DETECTION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Real-time processing active',
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
    final color = _detectedPlate != null ? const Color(0xFF00C853) : Colors.white.withOpacity(0.2);
    
    return Positioned(
      top: (index == 0 || index == 1) ? -2 : null,
      bottom: (index == 2 || index == 3) ? -2 : null,
      left: (index == 0 || index == 2) ? -2 : null,
      right: (index == 1 || index == 3) ? -2 : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
            topLeft: index == 0 ? const Radius.circular(24) : Radius.zero,
            topRight: index == 1 ? const Radius.circular(24) : Radius.zero,
            bottomLeft: index == 2 ? const Radius.circular(24) : Radius.zero,
            bottomRight: index == 3 ? const Radius.circular(24) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined, color: Colors.white24, size: 80),
            const SizedBox(height: 24),
            const Text(
              'CAMERA PERMISSION REQUIRED',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
              child: const Text('GRANT ACCESS'),
            ),
          ],
        ),
      ),
    );
  }
}

