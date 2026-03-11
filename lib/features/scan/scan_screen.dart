import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/local_ai_service.dart';
import 'results_screen.dart';

class ScanScreen extends StatefulWidget {
  final String cropName;
  const ScanScreen({super.key, required this.cropName});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _cameraReady = false;
  bool _isProcessing = false;
  FlashMode _flashMode = FlashMode.off;
  CameraLensDirection _lensDirection = CameraLensDirection.back;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Lock to portrait for professional camera feel
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == _lensDirection,
        orElse: () => cameras.first,
      );

      final ctrl = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      await ctrl.setFlashMode(_flashMode);


      if (!mounted) {
        ctrl.dispose();
        return;
      }
      setState(() {
        _controller = ctrl;
        _cameraReady = true;
      });
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (!_cameraReady || _controller == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final file = await _controller!.takePicture();
      await _runInference(file.path);
    } catch (e) {
      debugPrint('Capture error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickGallery() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked != null) await _runInference(picked.path);
    } catch (e) {
      debugPrint('Gallery error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    final newMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _controller!.setFlashMode(newMode);
      setState(() => _flashMode = newMode);
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_controller == null || _isProcessing) return;
    _lensDirection = _lensDirection == CameraLensDirection.back 
        ? CameraLensDirection.front 
        : CameraLensDirection.back;
    await _initCamera();
  }

  Color _getCropColor() {
    switch (widget.cropName.toLowerCase()) {
      case 'tomato':     return const Color(0xFFE53935); // Red
      case 'watermelon': return const Color(0xFF1B5E20); // Dark Green
      case 'cucumber':   return const Color(0xFF43A047); // Green
      default:           return const Color(0xFF43A047);
    }
  }


  Future<void> _runInference(String path) async {
    final result = await LocalAiService.predict(path, widget.cropName);

    if (!mounted) return;

    if (result == null || (result['allDetections'] as List).isEmpty) {
      _showNoFruit();
      return;
    }

    if (result['isWrongFruit'] == true) {
      _showWrongFruitAlert(result['suggestedCrop'] ?? 'another fruit');
      return;
    }


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          imageFile: File(path),
          scanResult: result,
          originalWidth: result['originalWidth'] as int,
          originalHeight: result['originalHeight'] as int,
        ),
      ),
    );
  }

  void _showNoFruit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Not a fruit recognized. Please point to a valid fruit.'),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showWrongFruitAlert(String suggested) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
            const SizedBox(width: 10),
            const Text('Wrong Fruit Section', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'This appears to be a $suggested. Please switch to the $suggested section for accurate freshness analysis.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: TextStyle(color: _getCropColor(), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-Screen Camera Preview
          if (_cameraReady && _controller != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 1,
                  height: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),

          // 2. Scanning Guide (Brackets)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ScanningGuidePainter(color: _getCropColor()),
              ),
            ),
          ),


          // 3. UI Overlays (Glassmorphic)
          SafeArea(
            child: Column(
              children: [
                _buildGlassTopBar(),
                const Spacer(),
                _buildGlassBottomControls(),
              ],
            ),
          ),

          // 4. Processing Loader Overlay
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black38,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        SizedBox(height: 16),
                        Text(
                          "Analyzing Fruit...",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white.withOpacity(0.15),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Scan ${widget.cropName}',
                  style: TextStyle(
                    color: _getCropColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _flashMode == FlashMode.torch ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _flashMode == FlashMode.torch ? _getCropColor() : Colors.white.withOpacity(0.5),
                  ),
                  onPressed: _toggleFlash,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 35),
            color: Colors.white.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gallery
                _buildCircleIcon(
                  icon: Icons.photo_library_outlined,
                  onPressed: _isProcessing ? null : _pickGallery,
                ),

                // Capture Button (Layered)
                GestureDetector(
                  onTap: _isProcessing ? null : _takePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _getCropColor().withOpacity(0.4), width: 3),
                    ),
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                        ],
                      ),
                      child: _isProcessing 
                        ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                        : null,
                    ),
                  ),
                ),

                // Camera Flip Action
                _buildCircleIcon(
                  icon: Icons.flip_camera_ios_outlined,
                  onPressed: _isProcessing ? null : _toggleCamera,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIcon({required IconData icon, required VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: _getCropColor().withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 26),
        onPressed: onPressed,
      ),
    );
  }
}

class ScanningGuidePainter extends CustomPainter {
  final Color color;
  const ScanningGuidePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;


    final double length = 40.0;
    final double margin = size.width * 0.15;
    final double innerW = size.width - (margin * 2);
    final double innerH = size.height * 0.45; // Center focused rect
    final double top = (size.height - innerH) / 2;
    
    final rect = Rect.fromLTWH(margin, top, innerW, innerH);

    // Top Left
    canvas.drawLine(Offset(rect.left, rect.top + length), Offset(rect.left, rect.top), paint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + length, rect.top), paint);

    // Top Right
    canvas.drawLine(Offset(rect.right - length, rect.top), Offset(rect.right, rect.top), paint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + length), paint);

    // Bottom Left
    canvas.drawLine(Offset(rect.left, rect.bottom - length), Offset(rect.left, rect.bottom), paint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + length, rect.bottom), paint);

    // Bottom Right
    canvas.drawLine(Offset(rect.right - length, rect.bottom), Offset(rect.right, rect.bottom), paint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
