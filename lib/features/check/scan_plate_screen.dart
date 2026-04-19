import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
    if (_isPermissionGranted) {
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
        _cameraController!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final InputImageMetadata metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final plate = _extractPlateNumber(line.text);
          if (plate != null) {
            setState(() {
              _detectedPlate = plate;
            });
            _onPlateDetected(plate);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  String? _extractPlateNumber(String text) {
    final cleanText = text.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    final plateRegex = RegExp(r'[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}');
    final match = plateRegex.firstMatch(cleanText);
    return match?.group(0);
  }

  void _onPlateDetected(String plate) {
    _cameraController?.stopImageStream();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(plateNumber: plate),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted) {
      return const Scaffold(
        body: Center(child: Text('Camera permission required')),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          _buildOverlay(),
          _buildScanLine(),
          _buildBottomPanel(),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
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
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanLine() {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: 300,
            height: 180,
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 180 * _animationController.value),
              width: 280,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ALIGN PLATE WITHIN BOX',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _detectedPlate ?? 'Scanning...',
              style: TextStyle(
                color: _detectedPlate != null ? const Color(0xFF00C853) : Colors.white38,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
