import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/beam_supports/support_classes.dart';

class BeamDrawing extends StatefulWidget {
  final double beamLength;
  final List<BeamSupport> supports;
  final bool encastrementSide; // false = gauche, true = droite

  const BeamDrawing({
    super.key,
    required this.beamLength,
    this.supports = const [],
    this.encastrementSide = false,
  });

  @override
  State<BeamDrawing> createState() => _BeamDrawingState();
}

class _BeamDrawingState extends State<BeamDrawing> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BeamPainterPro(
        beamLength: widget.beamLength,
        supports: widget.supports,
        encastrementSide: widget.encastrementSide, // 👈 on passe la valeur
      ),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class BeamPainterPro extends CustomPainter {
  final double beamLength;
  final List<BeamSupport> supports;
  final bool encastrementSide;

  BeamPainterPro({
    required this.beamLength,
    required this.supports,
    required this.encastrementSide,
  });

  void _drawSupport(
    Canvas canvas,
    Size size,
    BeamSupport support,
    double scale,
  ) {
    final x = support.position * scale;
    final centerY = size.height / 2;
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    switch (support.type) {
      case SupportType.simple:
        final path = Path();
        path.moveTo(x, centerY);
        path.lineTo(x - 15, centerY + 30);
        path.lineTo(x + 15, centerY + 30);
        path.close();
        canvas.drawPath(path, paint);

        const double wheelRadius = 5.0;
        final leftWheel = Offset(x - 10, centerY + 35);
        final rightWheel = Offset(x + 10, centerY + 35);
        canvas.drawCircle(leftWheel, wheelRadius, paint);
        canvas.drawCircle(rightWheel, wheelRadius, paint);
        break;

      case SupportType.double_:
        final path = Path();
        path.moveTo(x, centerY);
        path.lineTo(x - 15, centerY + 30);
        path.lineTo(x + 15, centerY + 30);
        path.close();
        canvas.drawPath(path, paint);

        canvas.drawLine(
          Offset(x - 20, centerY + 30),
          Offset(x + 20, centerY + 30),
          paint,
        );

        canvas.drawLine(
          Offset(x - 15, centerY + 30),
          Offset(x - 15, centerY + 50),
          paint,
        );
        canvas.drawLine(
          Offset(x + 15, centerY + 30),
          Offset(x + 15, centerY + 50),
          paint,
        );

        canvas.drawLine(
          Offset(x - 20, centerY + 40),
          Offset(x + 20, centerY + 40),
          paint,
        );
        break;

      case SupportType.rotule:
        final fillPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, centerY), 8, paint);
        canvas.drawCircle(Offset(x, centerY), 7, fillPaint);
        break;

      case SupportType.encastrement:
        final rectWidth = 16.0;
        final rectHeight = 44.0;

        final rect = support.encastrementSide == true
            ? Rect.fromCenter(
                center: Offset(size.width + 8, centerY),
                width: rectWidth,
                height: rectHeight,
              )
            : Rect.fromCenter(
                center: Offset(-8, centerY),
                width: rectWidth,
                height: rectHeight,
              );

        canvas.drawRect(rect, paint);

        // hachures
        for (double y = rect.top; y < rect.bottom; y += 6) {
          canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
        }
        break;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final beamPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0;

    final beamLengthPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0;

    final groundPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0;

    final scale = size.width / beamLength;

    // Poutre
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(beamLength * scale, size.height / 2),
      beamPaint,
    );

    // Ligne de cote
    canvas.drawLine(
      Offset(0, size.height / 2 + 100),
      Offset(beamLength * scale, size.height / 2 + 100),
      beamLengthPaint,
    );
    canvas.drawLine(
      Offset(beamLength * scale, size.height / 2 + 90),
      Offset(beamLength * scale, size.height / 2 + 110),
      beamLengthPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2 + 90),
      Offset(0, size.height / 2 + 110),
      beamLengthPaint,
    );

    // Sol
    canvas.drawLine(
      Offset(0, size.height / 2 + 40),
      Offset(beamLength * scale, size.height / 2 + 40),
      groundPaint,
    );
    for (double x = 0; x < beamLength * scale; x += 15) {
      canvas.drawLine(
        Offset(x, size.height / 2 + 40),
        Offset(x + 10, size.height / 2 + 55),
        groundPaint,
      );
    }

    // Supports
    for (final support in supports) {
      if (support.position >= 0 && support.position <= beamLength) {
        _drawSupport(canvas, size, support, scale);
      }
    }

    // Texte longueur
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${beamLength.toStringAsFixed(2)} m',
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (beamLength * scale) / 2 - textPainter.width / 2,
        size.height / 2 + 105,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
