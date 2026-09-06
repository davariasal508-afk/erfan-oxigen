import 'dart:io';

import 'package:flutter/material.dart';

/// نمایش تصویر دوره/نمونه‌کار.
/// اگر source مسیر فایل/asset واقعی باشد همان را نشان می‌دهد.
/// اگر source به شکل `icon://name` باشد (برای دوره‌هایی که هنوز عکس اختصاصی ندارند)
/// به‌جای reuse یک عکس مشترک، یک کارت گرادیانی متمایز با نماد مردانه‌ی آرایشگری رسم می‌شود.
class CourseImage extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final Color? accent;

  const CourseImage({super.key, required this.source, this.fit = BoxFit.cover, this.accent});

  static const Map<String, IconData> _icons = {
    'content_cut': Icons.content_cut_rounded,
    'content_cut_rounded': Icons.content_cut_rounded,
    'palette': Icons.palette_rounded,
  };

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('icon://')) {
      final name = source.substring('icon://'.length);
      return _iconCard(mark: _customMark(name), icon: _icons[name]);
    }

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    return Image.file(
      File(source),
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  /// برای مفاهیمی که آیکون آماده Material مناسب/مردانه ندارد (ریش، خط‌تراش)
  /// یک نماد برداری اختصاصی هم‌راستا با هویت لوگو رسم می‌شود.
  Widget? _customMark(String name) {
    return switch (name) {
      'beard' => CustomPaint(size: const Size(30, 30), painter: _BeardPainter(accent ?? const Color(0xFFE9B95F))),
      'razor' => CustomPaint(size: const Size(30, 30), painter: _RazorPainter(accent ?? const Color(0xFFE9B95F))),
      _ => null,
    };
  }

  Widget _iconCard({Widget? mark, IconData? icon}) {
    final color = accent ?? const Color(0xFFE9B95F);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: .22), const Color(0xFF12151B), const Color(0xFF0B0D11)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _TexturePainter(color)),
          Positioned(
            right: -18,
            bottom: -22,
            child: Opacity(
              opacity: .10,
              child: Image.asset('assets/images/oxigen_shield_mark.png', width: 90, filterQuality: FilterQuality.high),
            ),
          ),
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: .45), width: 1.2),
                gradient: RadialGradient(colors: [color.withValues(alpha: .16), Colors.transparent]),
              ),
              alignment: Alignment.center,
              child: mark ?? Icon(icon ?? Icons.auto_awesome_rounded, color: color, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF11151C),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white24,
        size: 32,
      ),
    );
  }
}

/// نماد ساده‌ی ریش و سبیل، هم‌سبک با نمای صورت داخل لوگوی برند.
class _BeardPainter extends CustomPainter {
  final Color color;
  const _BeardPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width, h = size.height;
    final face = Path()
      ..moveTo(w * .5, h * .04)
      ..cubicTo(w * .82, h * .04, w * .86, h * .30, w * .78, h * .48)
      ..cubicTo(w * .90, h * .50, w * .88, h * .66, w * .74, h * .70)
      ..cubicTo(w * .70, h * .92, w * .58, h * 1.0, w * .5, h * 1.0)
      ..cubicTo(w * .42, h * 1.0, w * .30, h * .92, w * .26, h * .70)
      ..cubicTo(w * .12, h * .66, w * .10, h * .50, w * .22, h * .48)
      ..cubicTo(w * .14, h * .30, w * .18, h * .04, w * .5, h * .04)
      ..close();
    canvas.drawPath(face, paint);

    final erase = Paint()..blendMode = BlendMode.clear;
    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());
    canvas.drawPath(face, paint);
    final mouth = Path()
      ..moveTo(w * .30, h * .58)
      ..quadraticBezierTo(w * .5, h * .68, w * .70, h * .58)
      ..lineTo(w * .70, h * .50)
      ..quadraticBezierTo(w * .5, h * .58, w * .30, h * .50)
      ..close();
    canvas.drawPath(mouth, erase);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BeardPainter oldDelegate) => oldDelegate.color != color;
}

/// نماد ساده‌ی خط‌تراش (straight razor) سنتی آرایشگری مردانه.
class _RazorPainter extends CustomPainter {
  final Color color;
  const _RazorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.save();
    canvas.translate(w * .5, h * .5);
    canvas.rotate(-0.62);
    canvas.translate(-w * .5, -h * .5);

    final blade = Paint()..color = color;
    final bladePath = Path()
      ..moveTo(w * .06, h * .42)
      ..lineTo(w * .60, h * .42)
      ..lineTo(w * .78, h * .50)
      ..lineTo(w * .60, h * .58)
      ..lineTo(w * .06, h * .58)
      ..close();
    canvas.drawPath(bladePath, blade);

    final handle = Paint()..color = color.withValues(alpha: .55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * .74, h * .40, w * .22, h * .20), const Radius.circular(3)),
      handle,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RazorPainter oldDelegate) => oldDelegate.color != color;
}

class _TexturePainter extends CustomPainter {
  final Color color;
  const _TexturePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = color.withValues(alpha: .10);
    const step = 16.0;
    for (double y = 6; y < size.height; y += step) {
      for (double x = 6; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), .8, dot);
      }
    }
    final sweep = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: .05), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sweep);
  }

  @override
  bool shouldRepaint(covariant _TexturePainter oldDelegate) => oldDelegate.color != color;
}
