import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_colors.dart';

/// Full-screen avatar crop editor — crops the image to a circle.
/// Pan and pinch to adjust, then tap "Save" to confirm.
/// [imagePath] — local file path from image_picker.
/// Returns the cropped file path via Navigator.pop.
class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  final _cropKey = GlobalKey();
  bool _isSaving = false;

  static const double _cropSize = 280.0;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final boundary =
          _cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // 3× pixel ratio produces 840×840 px — sufficient for an avatar
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes!.buffer.asUint8List());

      if (mounted) context.pop(file.path);
    } catch (e) {
      if (mounted) context.pop(null);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(null),
        ),
        title: const Text(
          'Crop Image',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dark overlay background
                  const SizedBox.expand(),

                  // Crop area — only this widget is captured
                  RepaintBoundary(
                    key: _cropKey,
                    child: ClipOval(
                      child: SizedBox(
                        width: _cropSize,
                        height: _cropSize,
                        child: InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 8.0,
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.cover,
                            width: _cropSize,
                            height: _cropSize,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Circle border overlay (visual only, not captured)
                  IgnorePointer(
                    child: CustomPaint(
                      size: const Size(_cropSize, _cropSize),
                      painter: _CircleBorderPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Text(
              'Drag and pinch to adjust',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 1,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
