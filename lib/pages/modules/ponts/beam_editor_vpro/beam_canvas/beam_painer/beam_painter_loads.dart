import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_vpro/models/load_classes.dart';

import 'beam_painter_colors.dart';

void drawLoad(
  Canvas canvas,
  Load load,
  double Function(double) xFromPosition,
  double beamY,
  bool afficherValeursCharges,
) {
  beamY = beamY - 2.5;
  if (load is PointLoad) {
    _drawPointLoad(canvas, load, xFromPosition(load.position), beamY, afficherValeursCharges);
  } else if (load is DistributedLoad) {
    _drawDistributedLoad(canvas, load, xFromPosition, beamY, afficherValeursCharges);
  } else if (load is MomentLoad) {
    _drawMoment(canvas, load, xFromPosition(load.position), beamY, afficherValeursCharges);
  }
}

void _drawPointLoad(Canvas canvas, PointLoad load, double x, double beamY, bool afficherValeursCharges) {
  final paint = Paint()
    ..color = loadColor
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(Offset(x, beamY - 46), Offset(x, beamY - 2.5), paint);
  final path = Path()
    ..moveTo(x - 6, beamY - 8)
    ..lineTo(x, beamY)
    ..lineTo(x + 6, beamY - 8);
  canvas.drawPath(path, paint);
  _drawValueLabel(canvas, '${load.value.toStringAsFixed(1)} kN', x, beamY - 54, afficherValeursCharges);
}

void _drawDistributedLoad(
  Canvas canvas,
  DistributedLoad load,
  double Function(double) xFromPosition,
  double beamY,
  bool afficherValeursCharges,
) {
  final x1 = xFromPosition(load.position);
  final x2 = xFromPosition(load.positionEnd);
  final paint = Paint()
    ..color = loadColor
    ..strokeWidth = 1.8;
  canvas.drawLine(Offset(x1, beamY - 30), Offset(x2, beamY - 30), paint);

  const desiredSpacing = 18.0;
  final span = x2 - x1;
  final arrowCount = math.max(2, (span / desiredSpacing).round() + 1);
  final step = span / (arrowCount - 1);

  for (int i = 0; i < arrowCount; i++) {
    final x = x1 + step * i;
    canvas.drawLine(Offset(x, beamY - 30), Offset(x, beamY - 5), paint);
    final path = Path()
      ..moveTo(x - 4, beamY - 6)
      ..lineTo(x, beamY - 0)
      ..lineTo(x + 4, beamY - 6);
    canvas.drawPath(path, paint);
  }

  _drawValueLabel(
    canvas,
    '${load.value.toStringAsFixed(1)} kN/m',
    (x1 + x2) / 2,
    beamY - 40,
    afficherValeursCharges,
  );
}

void _drawMoment(Canvas canvas, MomentLoad load, double x, double beamY, bool afficherValeursCharges) {
  final paint = Paint()
    ..color = loadColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;
  const radius = 18.0;
  canvas.drawArc(
    Rect.fromCircle(center: Offset(x, beamY - 22), radius: radius),
    -math.pi * 0.25,
    math.pi * 1.5,
    false,
    paint,
  );
  final arrowX = x + radius * 0.72;
  final arrowY = beamY - 22 - radius * 0.72;
  final path = Path()
    ..moveTo(arrowX - 7, arrowY)
    ..lineTo(arrowX, arrowY + 8)
    ..lineTo(arrowX + 5, arrowY - 2);
  canvas.drawPath(path, paint);
  _drawValueLabel(
    canvas,
    '${load.value.toStringAsFixed(1)} kN·m',
    x,
    beamY - 52,
    afficherValeursCharges,
  );
}

void _drawValueLabel(Canvas canvas, String text, double x, double y, bool afficherValeursCharges) {
  if (!afficherValeursCharges) return;
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(
        color: loadColor,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  textPainter.paint(
    canvas,
    Offset(x - textPainter.width / 2, y - textPainter.height),
  );
}

//TODO : fix moment load
//TODO : add loads colors