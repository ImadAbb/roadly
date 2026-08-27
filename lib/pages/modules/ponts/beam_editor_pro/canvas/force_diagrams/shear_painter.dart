import 'package:flutter/material.dart';

import '../../domain/calculations/shear/shear_classes.dart';

class ShearPainter extends CustomPainter {
  final ShearResult result;
  final double beamLength;

  ShearPainter({
    required this.result,
    required this.beamLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (result.points.isEmpty || beamLength <= 0) {
      return;
    }

    // ═══════════════════════════════════════
    // DIMENSIONS
    // ═══════════════════════════════════════

    const leftMargin = 40.0;
    const rightMargin = 20.0;
    const topMargin = 20.0;
    const bottomMargin = 30.0;

    final width = size.width - leftMargin - rightMargin;
    final height = size.height - topMargin - bottomMargin;

    if (width <= 0 || height <= 0) {
      return;
    }

    // ═══════════════════════════════════════
    // CONVERSION X
    // ═══════════════════════════════════════
    //
    // La poutre va TOUJOURS de :
    //
    // x = 0
    // jusqu'à
    // x = beamLength
    //
    // Les points de calcul extérieurs ne
    // peuvent donc pas décaler le diagramme.

    double xToCanvas(double x) {
      final clampedX = x.clamp(0.0, beamLength);

      return leftMargin + (clampedX / beamLength) * width;
    }

    // ═══════════════════════════════════════
    // LIMITES Y
    // ═══════════════════════════════════════

    double maxAbsValue = 0.0;

    for (final point in result.points) {
      final value = point.value.abs();

      if (value > maxAbsValue) {
        maxAbsValue = value;
      }
    }

    if (maxAbsValue == 0) {
      maxAbsValue = 1;
    }

    // Petite marge au-dessus du maximum.
    maxAbsValue *= 1.15;

    final zeroY = topMargin + height / 2;

    double valueToCanvasY(double value) {
      return zeroY - (value / maxAbsValue) * (height / 2);
    }

    // ═══════════════════════════════════════
    // AXE T = 0
    // ═══════════════════════════════════════

    final axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.2;

    canvas.drawLine(
      Offset(leftMargin, zeroY),
      Offset(leftMargin + width, zeroY),
      axisPaint,
    );

    // ═══════════════════════════════════════
    // DIAGRAMME
    // ═══════════════════════════════════════

    final diagramPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    bool firstPoint = true;

    for (final point in result.points) {
      // Ignore complètement les points situés
      // à l'extérieur de la poutre.
      if (point.position < 0 ||
          point.position > beamLength) {
        continue;
      }

      final x = xToCanvas(point.position);
      final y = valueToCanvasY(point.value);

      if (firstPoint) {
        path.moveTo(x, y);

        fillPath.moveTo(x, zeroY);
        fillPath.lineTo(x, y);

        firstPoint = false;
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    if (firstPoint) {
      return;
    }

    // ═══════════════════════════════════════
    // FERMETURE DU REMPLISSAGE
    // ═══════════════════════════════════════

    final validPoints = result.points
        .where(
          (point) =>
              point.position >= 0 &&
              point.position <= beamLength,
        )
        .toList();

    if (validPoints.isNotEmpty) {
      final lastPoint = validPoints.last;

      fillPath.lineTo(
        xToCanvas(lastPoint.position),
        zeroY,
      );

      fillPath.close();
    }

    // ═══════════════════════════════════════
    // REMPLISSAGE
    // ═══════════════════════════════════════

    canvas.drawPath(
      fillPath,
      fillPaint,
    );

    // ═══════════════════════════════════════
    // COURBE
    // ═══════════════════════════════════════

    canvas.drawPath(
      path,
      diagramPaint,
    );

    // ═══════════════════════════════════════
    // POINTS DE CALCUL
    // ═══════════════════════════════════════

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final point in validPoints) {
      // On ne dessine PAS le zéro extérieur
      // aux appuis.
      //
      // x = 0 :
      //   on ignore la valeur 0 avant l'appui
      //   et on garde la valeur après l'appui.
      //
      // x = beamLength :
      //   on ignore la valeur 0 après l'appui
      //   et on garde la valeur avant l'appui.

      if (point.position == 0.0 &&
          point.value == 0.0) {
        continue;
      }

      if (point.position == beamLength &&
          point.value == 0.0) {
        continue;
      }

      canvas.drawCircle(
        Offset(
          xToCanvas(point.position),
          valueToCanvasY(point.value),
        ),
        3,
        pointPaint,
      );
    }

    // ═══════════════════════════════════════
    // VALEURS
    // ═══════════════════════════════════════

    _drawValues(
      canvas,
      xToCanvas,
      valueToCanvasY,
      validPoints,
    );
  }

  // ═══════════════════════════════════════
  // VALEURS
  // ═══════════════════════════════════════

  void _drawValues(
    Canvas canvas,
    double Function(double) xToCanvas,
    double Function(double) valueToCanvasY,
    List<dynamic> points,
  ) {
    const textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    for (final point in points) {
      // Ne pas afficher le zéro extérieur.
      if (point.position == 0.0 &&
          point.value == 0.0) {
        continue;
      }

      if (point.position == beamLength &&
          point.value == 0.0) {
        continue;
      }

      final x = xToCanvas(point.position);
      final y = valueToCanvasY(point.value);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${point.value.toStringAsFixed(2)} kN',
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      double textX = x - textPainter.width / 2;

      // Évite que le texte sorte à gauche.
      if (textX < 2) {
        textX = 2;
      }

      // Évite que le texte sorte à droite.
      if (textX + textPainter.width >
          canvas.getDestinationClipBounds().right) {
        textX =
            canvas.getDestinationClipBounds().right -
            textPainter.width -
            2;
      }

      final textY = point.value >= 0
          ? y - textPainter.height - 5
          : y + 5;

      textPainter.paint(
        canvas,
        Offset(textX, textY),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ShearPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.beamLength != beamLength;
  }
}