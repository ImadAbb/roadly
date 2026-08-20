import 'package:flutter/material.dart';

import 'beam_painter_colors.dart';

void drawChainDimensions(
  Canvas canvas,
  double Function(double) xFromPosition,
  double beamY,
  double beamLength,
  List<double> positions,
) {
  if (positions.isEmpty) {
    return;
  }

  final allPositions = <double>[
    0.0,
    ...positions,
    beamLength,
  ];

  // Trier les positions
  allPositions.sort();

  // Supprimer les doublons
  final uniquePositions = <double>[];

  for (final position in allPositions) {
    if (uniquePositions.isEmpty ||
        (position - uniquePositions.last).abs() > 0.001) {
      uniquePositions.add(position);
    }
  }

  // Dessiner chaque distance
  for (int i = 0; i < uniquePositions.length - 1; i++) {
    final start = uniquePositions[i];
    final end = uniquePositions[i + 1];

    final distance = end - start;

    if (distance <= 0) {
      continue;
    }

    final x1 = xFromPosition(start);
    final x2 = xFromPosition(end);

    _drawDimensionSegment(
      canvas,
      x1,
      x2,
      beamY,
      distance,
    );
  }
}

void _drawDimensionSegment(
  Canvas canvas,
  double x1,
  double x2,
  double beamY,
  double distance,
) {
  const dimensionY = 42.0;

  final y = beamY + dimensionY;

  final paint = Paint()
    ..color = dimensionColor
    ..strokeWidth = 1;

  // ─────────────────────────────────────
  // LIGNES D'EXTENSION
  // ─────────────────────────────────────

  canvas.drawLine(
    Offset(x1, beamY + 28),
    Offset(x1, y + 14),
    paint,
  );

  canvas.drawLine(
    Offset(x2, beamY + 28),
    Offset(x2, y),
    paint,
  );

  // ─────────────────────────────────────
  // LIGNE DE COTATION
  // ─────────────────────────────────────

  canvas.drawLine(
    Offset(x1, y),
    Offset(x2, y),
    paint,
  );

  // ─────────────────────────────────────
  // FLÈCHES
  // ─────────────────────────────────────

  const arrowSize = 4.0;

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

  canvas.drawPath(
    leftArrow,
    arrowPaint,
  );

  canvas.drawPath(
    rightArrow,
    arrowPaint,
  );

  // ─────────────────────────────────────
  // DISTANCE
  // ─────────────────────────────────────

  final textPainter = TextPainter(
    text: TextSpan(
      text: '${distance.toStringAsFixed(2)} m',
      style: const TextStyle(
        color: dimensionColor,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  textPainter.paint(
    canvas,
    Offset(
      (x1 + x2) / 2 - textPainter.width / 2,
      y + 5,
    ),
  );
}