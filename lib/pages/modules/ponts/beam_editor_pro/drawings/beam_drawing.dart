import 'package:flutter/material.dart';

class BeamDrawing extends StatefulWidget {
  final double beamLength;

  const BeamDrawing({super.key, required this.beamLength});

  @override
  State<BeamDrawing> createState() => _BeamDrawingState();
}

class _BeamDrawingState extends State<BeamDrawing> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BeamPainterPro(widget.beamLength), 
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class BeamPainterPro extends CustomPainter {
  final double beamLength;
  BeamPainterPro(this.beamLength);

  @override
  void paint(Canvas canvas, Size size) {
    final beamPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0;

      final beamLenghtPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0;

    double scale = size.width / beamLength;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(beamLength * scale, size.height / 2), 
      beamPaint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2 + 60), 
      Offset(beamLength * scale, size.height / 2 + 60),
      beamLenghtPaint,
    );

    canvas.drawLine(
      Offset(beamLength * scale, size.height / 2 + 50), 
      Offset(beamLength * scale, size.height / 2 + 70),
      beamLenghtPaint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2 + 50), 
      Offset(0, size.height / 2 + 70),
      beamLenghtPaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: "${beamLength.toStringAsFixed(2)} m",
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (beamLength * scale) / 2 - textPainter.width / 2,
        size.height / 2 + 65,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
