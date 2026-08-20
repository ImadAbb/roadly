import 'package:flutter/material.dart';

import 'beam_painter_colors.dart';

void drawDimension(
  Canvas canvas,
  double x1,
  double x2,
  double beamY,
  double length,
) {
  final y = beamY + 68;
  final paint = Paint()
    ..color = dimensionColor
    ..strokeWidth = 1;
  canvas.drawLine(Offset(x1, beamY + 28), Offset(x1, y), paint);
  canvas.drawLine(Offset(x2, beamY + 28), Offset(x2, y), paint);
  canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);

  const arrowSize = 5.0;
  final leftArrow = Path()
    ..moveTo(x1, y)
    ..lineTo(x1 + arrowSize, y - 3)
    ..lineTo(x1 + arrowSize, y + 3)
    ..close();
  final rightArrow = Path()
    ..moveTo(x2, y)
    ..lineTo(x2 - arrowSize, y - 3)
    ..lineTo(x2 - arrowSize, y + 3)
    ..close();
  final arrowPaint = Paint()
    ..color = dimensionColor
    ..style = PaintingStyle.fill;
  canvas.drawPath(leftArrow, arrowPaint);
  canvas.drawPath(rightArrow, arrowPaint);

  final textPainter = TextPainter(
    text: TextSpan(
      text: 'L = ${length.toStringAsFixed(2)} m',
      style: const TextStyle(
        color: dimensionColor,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  textPainter.paint(
    canvas,
    Offset((x1 + x2) / 2 - textPainter.width / 2, y + 6),
  );
}
