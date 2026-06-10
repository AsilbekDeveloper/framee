import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_colors.dart';

/// Foydalanuvchi rasmini doira shaklida crop qilish uchun to'liq ekran.
/// Rasmni suring va kattalashtiring, keyin "Saqlash" tugmasini bosing.
/// [imagePath] — image_picker'dan kelgan lokal fayl yo'li.
/// Navigator.pop orqali crop qilingan faylning yo'lini qaytaradi.
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
      // 3x pixel ratio — 840x840 px chiqadi, avatar uchun yetarli
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
          'Rasmni kesish',
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
                      'Saqlash',
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
                  // Tashqi qoraytirilgan fon
                  const SizedBox.expand(),

                  // Crop hududi — faqat shu widget capture qilinadi
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

                  // Doira chegarasi (faqat ko'rsatish uchun, capture qilinmaydi)
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
              'Rasmni suring va kattalashtiring',
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
