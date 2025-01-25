import 'package:flutter/material.dart';

class TimerProgressPainter extends CustomPainter {
  final double progress;

  TimerProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = progress <= 0.3 ? Colors.red : Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -90 * (3.14159 / 180);
    final sweepAngle = 360 * (3.14159 / 180) * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(TimerProgressPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
