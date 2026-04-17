import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnalogClockFace extends StatelessWidget {
  final DateTime time;
  final double size;
  final bool showSecondHand;

  const AnalogClockFace({
    super.key,
    required this.time,
    required this.size,
    required this.showSecondHand,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: AnalogClockPainter(
            time: time,
            colorScheme: Theme.of(context).colorScheme,
            showSecondHand: showSecondHand,
          ),
        ),
      ),
    );
  }
}

class AnalogClockPainter extends CustomPainter {
  final DateTime time;
  final ColorScheme colorScheme;
  final bool showSecondHand;

  const AnalogClockPainter({
    required this.time,
    required this.colorScheme,
    required this.showSecondHand,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final center = Offset(centerX, centerY);
    final radius = math.min(centerX, centerY);
    final onSurface = colorScheme.onSurface;
    final primary = colorScheme.primary;

    final minuteMarkerPaint = Paint()
      ..color = onSurface.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 60; i++) {
      final angle = i * math.pi / 30 - math.pi / 2;
      final outer = Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );
      final inner = Offset(
        centerX + (radius * 0.95) * math.cos(angle),
        centerY + (radius * 0.95) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, minuteMarkerPaint);
    }

    final hourMarkerPaint = Paint()
      ..color = onSurface
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6 - math.pi / 2;
      final outer = Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );
      final inner = Offset(
        centerX + (radius * 0.9) * math.cos(angle),
        centerY + (radius * 0.9) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, hourMarkerPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: i == 0 ? '12' : '$i',
          style: TextStyle(
            color: onSurface,
            fontSize: (radius * 0.18).clamp(12.0, 24.0),
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final numberX =
          centerX + (radius * 0.75) * math.cos(angle) - textPainter.width / 2;
      final numberY =
          centerY + (radius * 0.75) * math.sin(angle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(numberX, numberY));
    }

    final hourAngle =
        (time.hour % 12 + time.minute / 60) * math.pi / 6 - math.pi / 2;
    final hourHandEnd = Offset(
      centerX + (radius * 0.6) * math.cos(hourAngle),
      centerY + (radius * 0.6) * math.sin(hourAngle),
    );
    final hourHandPaint = Paint()
      ..color = onSurface
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, hourHandEnd, hourHandPaint);

    final minuteAngle =
        (time.minute + time.second / 60) * math.pi / 30 - math.pi / 2;
    final minuteHandEnd = Offset(
      centerX + (radius * 0.8) * math.cos(minuteAngle),
      centerY + (radius * 0.8) * math.sin(minuteAngle),
    );
    final minuteHandPaint = Paint()
      ..color = onSurface
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, minuteHandEnd, minuteHandPaint);

    if (showSecondHand) {
      final secondAngle = time.second * math.pi / 30 - math.pi / 2;
      final secondHandEnd = Offset(
        centerX + (radius * 0.9) * math.cos(secondAngle),
        centerY + (radius * 0.9) * math.sin(secondAngle),
      );
      final secondHandPaint = Paint()
        ..color = primary
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center, secondHandEnd, secondHandPaint);
    }

    final centerDotPaint = Paint()..color = primary;
    canvas.drawCircle(center, 5, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.showSecondHand != showSecondHand;
  }
}
