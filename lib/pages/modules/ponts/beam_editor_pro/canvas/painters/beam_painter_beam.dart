import 'package:flutter/material.dart';

import '../../theme/beam_painter_colors.dart';

void drawBeam(Canvas canvas, double x1, double x2, double y) {
  final paint = Paint()
    ..color = beamColor
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);
}
