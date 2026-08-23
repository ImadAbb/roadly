import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/models/support_classes.dart';
import '../../theme/beam_painter_colors.dart';

class BeamPainterReactions {
  // ═══════════════════════════════════════
  // DESSIN DE TOUTES LES RÉACTIONS
  // ═══════════════════════════════════════

  static void drawReactions({
    required Canvas canvas,
    required List<Support> supports,
    required double beamY,
    required double Function(double position) positionToCanvasX,
    required Map<String, double> verticalReactions,
    required double? momentReaction,
    required double middleX,
  }) {
    for (final support in supports) {
      final x = positionToCanvasX(support.position);

      // ═══════════════════════════════════
      // RÉACTION VERTICALE
      // ═══════════════════════════════════

      final reaction = verticalReactions[support.id];

      if (reaction != null) {
        drawReaction(
          canvas: canvas,
          support: support,
          x: x,
          beamY: beamY,
          value: reaction,
          middleX: middleX,
        );
      }

      // ═══════════════════════════════════
      // MOMENT DE RÉACTION
      // ═══════════════════════════════════

      if (support.type == SupportType.encastrement_ && momentReaction != null) {
        drawMomentReaction(
          canvas: canvas,
          x: x,
          beamY: beamY,
          value: momentReaction,
          middleX: middleX,
        );
      }
    }
  }

  // ═══════════════════════════════════════
  // DESSIN D'UNE RÉACTION VERTICALE
  // ═══════════════════════════════════════

  static void drawReaction({
    required Canvas canvas,
    required Support support,
    required double x,
    required double beamY,
    required double value,
    required double middleX,
  }) {
    if (value.abs() < 0.000001) {
      return;
    }

    // Positif = vers le haut
    // Négatif = vers le bas
    final isPositive = value > 0;

    final color = isPositive ? positiveReactionColor : negativeReactionColor;

    const arrowLength = 30.0;
    const arrowWidth = 7.0;
    const arrowHeadLength = 9.0;

    final shaftPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    late double startY;
    late double tipY;

    if (isPositive) {
      startY = beamY + arrowLength;
      tipY = beamY;
    } else {
      startY = beamY - arrowLength;
      tipY = beamY;
    }

    // Corps de la flèche
    canvas.drawLine(Offset(x, startY), Offset(x, tipY), shaftPaint);

    // Pointe
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isPositive) {
      path
        ..moveTo(x, tipY)
        ..lineTo(x - arrowWidth, tipY + arrowHeadLength)
        ..lineTo(x + arrowWidth, tipY + arrowHeadLength)
        ..close();
    } else {
      path
        ..moveTo(x, tipY)
        ..lineTo(x - arrowWidth, tipY - arrowHeadLength)
        ..lineTo(x + arrowWidth, tipY - arrowHeadLength)
        ..close();
    }

    canvas.drawPath(path, arrowPaint);

    // Valeur
    _drawReactionValueLabel(
      canvas: canvas,
      value: value,
      x: x,
      beamY: beamY,
      isPositive: isPositive,
      color: color,
      middleX: middleX,
    );
  }

  // ═══════════════════════════════════════
  // TEXTE RÉACTION VERTICALE
  // ═══════════════════════════════════════

  static void _drawReactionValueLabel({
    required Canvas canvas,
    required double value,
    required double x,
    required double beamY,
    required bool isPositive,
    required Color color,
    required double middleX,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Ry = ${value.abs().toStringAsFixed(2)} kN',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Gauche → texte à droite
    // Droite → texte à gauche
    final textX = x < middleX ? x + 10 : x - textPainter.width - 10;

    final textY = isPositive ? beamY + 6 : beamY - textPainter.height - 2;

    textPainter.paint(canvas, Offset(textX, textY));
  }

  // ═══════════════════════════════════════
  // DESSIN DU MOMENT DE RÉACTION
  // ═══════════════════════════════════════

  static void drawMomentReaction({
    required Canvas canvas,
    required double x,
    required double beamY,
    required double value,
    required double middleX,
  }) {
    if (value.abs() < 0.000001) {
      return;
    }

    // Positif = antihoraire
    // Négatif = horaire
    final isPositive = value > 0;

    final color = isPositive ? positiveReactionColor : negativeReactionColor;

    // Détermine automatiquement si
    // l'encastrement est à droite ou à gauche.
    final isRightSide = x > middleX;

    // ═══════════════════════════════════
    // DIMENSIONS
    // ═══════════════════════════════════

    const radius = 14.0;
    const exteriorOffset = 2.0;

    // Le cercle est placé à l'extérieur
    // de l'encastrement.
    final momentX = isRightSide
        ? x + radius + exteriorOffset
        : x - radius - exteriorOffset;

    final center = Offset(momentX, beamY);

    // ═══════════════════════════════════
    // PEINTURE
    // ═══════════════════════════════════

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // ═══════════════════════════════════
    // ARC
    // ═══════════════════════════════════

    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = -math.pi / 2;

    final sweepAngle = isPositive ? -math.pi : math.pi;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    // ═══════════════════════════════════
    // POINTE DE LA FLÈCHE
    // ═══════════════════════════════════

    final tip = Offset(momentX, beamY - radius);

    const arrowLength = 8.0;
    const arrowWidth = 6.0;

    final Path arrowPath;

    if (isPositive) {
      // ↺ Antihoraire
      arrowPath = Path()
        ..moveTo(tip.dx + 3, tip.dy - 2)
        ..lineTo(tip.dx - arrowLength - 1, tip.dy - arrowWidth / 2)
        ..lineTo(tip.dx - arrowLength + 2, tip.dy + arrowWidth * 1.4)
        ..close();
    } else {
      // ↻ Horaire
      arrowPath = Path()
        ..moveTo(tip.dx - 3, tip.dy - 2)
        ..lineTo(tip.dx + arrowLength + 1, tip.dy - arrowWidth / 2)
        ..lineTo(tip.dx + arrowLength - 2, tip.dy + arrowWidth * 1.4)
        ..close();
    }

    canvas.drawPath(arrowPath, arrowPaint);

    // ═══════════════════════════════════
    // VALEUR DU MOMENT
    // ═══════════════════════════════════

    _drawMomentValueLabel(
      canvas: canvas,
      value: value,
      x: momentX,
      beamY: beamY,
      color: color,
      isRightSide: isRightSide,
    );
  }

  // ═══════════════════════════════════════
  // TEXTE DU MOMENT
  // ═══════════════════════════════════════

  static void _drawMomentValueLabel({
    required Canvas canvas,
    required double value,
    required double x,
    required double beamY,
    required Color color,
    required bool isRightSide,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'MA = ${value.abs().toStringAsFixed(1)} kN·m',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Le texte reste à l'extérieur
    // de la poutre.
    final textX = isRightSide ? x - textPainter.width - 6 : x + 6;

    final textY = beamY - 40;

    textPainter.paint(canvas, Offset(textX, textY));
  }
}
