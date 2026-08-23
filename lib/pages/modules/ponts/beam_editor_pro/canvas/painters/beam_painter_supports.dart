import 'package:flutter/material.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/support.dart';

import '../../theme/beam_painter_colors.dart';

void drawSupport(Canvas canvas, Support support, double x, double beamY) {
  switch (support.type) {
    case SupportType.simple_:
      _drawSimpleSupport(canvas, x, beamY);
    case SupportType.double_:
      _drawDoubleSupport(canvas, x, beamY);
    case SupportType.rotule_:
      _drawRotule(canvas, x, beamY);
    case SupportType.encastrement_:
      _drawEncastrement(
        canvas,
        x,
        beamY,
        support.isEncastrementRightSide == true,
      );
  }
}

void _drawSimpleSupport(Canvas canvas, double x, double y) {
  final paint = Paint()
    ..color = supportColor
    ..style = PaintingStyle.fill;
  final path = Path()
    ..moveTo(x, y + 2)
    ..lineTo(x - 13, y + 22)
    ..lineTo(x + 13, y + 22)
    ..close();
  canvas.drawPath(path, paint);
  _drawSupportBase(canvas, x - 17, x + 17, y + 25);
}

void _drawDoubleSupport(Canvas canvas, double x, double y) {
  final paint = Paint()
    ..color = supportColor
    ..style = PaintingStyle.fill;
  final path = Path()
    ..moveTo(x, y + 2)
    ..lineTo(x - 13, y + 18)
    ..lineTo(x + 13, y + 18)
    ..close();
  canvas.drawPath(path, paint);
  canvas.drawCircle(Offset(x - 7, y + 23), 4, paint);
  canvas.drawCircle(Offset(x + 7, y + 23), 4, paint);
  _drawSupportBase(canvas, x - 18, x + 18, y + 29);
}

void _drawRotule(Canvas canvas, double x, double y) {
  final strokePaint = Paint()
    ..color = supportColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final hideInsideRotule = Paint()
  ..color = Colors.white
  ..strokeWidth = 4.9;
  canvas.drawCircle(Offset(x, y), 8, strokePaint);
  canvas.drawLine(Offset(x - 7, y), Offset(x + 7, y), hideInsideRotule);
  _drawSupportBase(canvas, x - 13, x + 13, y + 25);
}

void _drawEncastrement(Canvas canvas, double x, double y, bool rightSide) {
  final wallX = rightSide ? x + 5 : x - 5;
  final paint = Paint()
    ..color = supportColor
    ..strokeWidth = 3;
  canvas.drawLine(Offset(wallX, y - 28), Offset(wallX, y + 28), paint);

  final hatchPaint = Paint()
    ..color = extensionColor
    ..strokeWidth = 1.2;
  for (double hatchY = y - 24; hatchY <= y + 24; hatchY += 7) {
    final hatchEndX = rightSide ? wallX + 12 : wallX - 12;
    canvas.drawLine(
      Offset(wallX, hatchY),
      Offset(hatchEndX, hatchY + 7),
      hatchPaint,
    );
  }
}

void _drawSupportBase(Canvas canvas, double x1, double x2, double y) {
  final linePaint = Paint()
    ..color = extensionColor
    ..strokeWidth = 1.5;
  canvas.drawLine(Offset(x1, y), Offset(x2, y), linePaint);
}
