import 'package:flutter/material.dart';
import 'dart:math';

class MultiColorCircle extends StatelessWidget {
  final List<Color> colors;
  final double size;
  final double strokeWidth;

  const MultiColorCircle({
    Key? key,
    required this.colors,
    this.size = 40,
    this.strokeWidth = 4,
    this.explosionFactor = 0.0,
  }) : super(key: key);

  final double explosionFactor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MultiColorPainter(colors: colors, strokeWidth: strokeWidth, explosionFactor: explosionFactor),
        child: Center(
          // Optionally put the day number here if used as a background
        ),
      ),
    );
  }
}

class _MultiColorPainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;
  final double explosionFactor;

  _MultiColorPainter({required this.colors, required this.strokeWidth, this.explosionFactor = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // Calculate total available angle (2pi) minus total gaps
    // explosionFactor determines how much of the circle is "gap" vs "segment"
    // Keep it simple: explosionFactor * 0.5 radians is the gap per segment
    
    final gap = colors.length > 1 ? explosionFactor : 0.0;
    final totalGap = gap * colors.length;
    final sweepAngle = ((2 * pi) - totalGap) / colors.length;
    
    double startAngle = -pi / 2; // Start from top

    for (var color in colors) {
      paint.color = color;
      canvas.drawArc(rect, startAngle + (gap / 2), sweepAngle, false, paint);
      startAngle += sweepAngle + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Simple rebuild
  }
}
