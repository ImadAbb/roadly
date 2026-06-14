import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/classes.dart';

// Painter qui dessine la poutre, les appuis et les charges
class BeamPainter extends CustomPainter {
  final Beam beam;
  BeamPainter(this.beam);

  static const bY = 120.0; // hauteur de la poutre
  static const bH = 16.0;  // épaisseur poutre

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;

    // 1. Poutre (rectangle avec dégradé bleu)
    final rect = Rect.fromLTWH(0, bY - bH / 2, W, bH);
    final grad = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5AABFF), Color(0xFF2A7EE0), Color(0xFF1A5AB0)],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()..shader = grad.createShader(rect),
    );

    // 2. Appuis
    for (var s in beam.supports) {
      double cx = s.x / beam.length * W;
      final paint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      if (s.type == SupportType.simple) {
        Path tri = Path()
          ..moveTo(cx, bY + bH / 2)
          ..lineTo(cx - 12, bY + bH / 2 + 20)
          ..lineTo(cx + 12, bY + bH / 2 + 20)
          ..close();
        canvas.drawPath(tri, paint);
      } else if (s.type == SupportType.encastrement) {
        // rectangle centré sur la poutre
        canvas.drawRect(
          Rect.fromLTWH(cx - 6, bY - bH / 2 - 20, 12, bH + 40),
          Paint()..color = Colors.green,
        );
      }
    }

    // 3. Charges
    final paintPoint = Paint()..color = Colors.red..strokeWidth = 2;
    final paintDist = Paint()..color = Colors.orange..strokeWidth = 2;

    for (var l in beam.loads) {
      double cx = l.x / beam.length * W;

      if (l is PointLoad) {
        // corps de flèche plus grand que répartie
        const arrowLength = 50; // 👈 plus grand que pour répartie

        canvas.drawLine(
          Offset(cx, bY - arrowLength),
          Offset(cx, bY - bH / 2),
          paintPoint,
        );

        // tête de flèche
        canvas.drawPath(Path()
          ..moveTo(cx - 6, bY - 20)
          ..lineTo(cx, bY - bH / 2)
          ..lineTo(cx + 6, bY - 20)
          ..close(), paintPoint);

        _txt(canvas, "${l.value} kN", Offset(cx, bY - arrowLength - 15), 12, Colors.red, center: true);
      } else if (l is DistributedLoad) {
        double cx1 = l.x / beam.length * W;
        double cx2 = l.xEnd / beam.length * W;
        double endLine = cx2 - (cx2 - cx1) % 25;

        // ligne au-dessus qui s’arrête aux extrémités
        canvas.drawLine(
          Offset(cx1, bY - 30),
          Offset(endLine, bY - 30),
          paintDist,
        );

        // corps de flèche plus petit que ponctuelle
        const arrowLength = 30;

        for (double x = cx1; x <= cx2; x += 25) {
          canvas.drawLine(
            Offset(x, bY - arrowLength),
            Offset(x, bY - bH / 2),
            paintDist,
          );
          canvas.drawPath(Path()
            ..moveTo(x - 6, bY - 15)
            ..lineTo(x, bY - bH / 2)
            ..lineTo(x + 6, bY - 15)
            ..close(), paintDist);
        }

        _txt(canvas, "${l.value} kN/m", Offset((cx1 + cx2) / 2, bY - 45), 12, Colors.orange, center: true);
      }
    }
  }

  void _txt(Canvas canvas, String t, Offset o, double fs, Color col, {bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: col, fontSize: fs, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = center ? o.dx - tp.width / 2 : o.dx;
    tp.paint(canvas, Offset(dx, o.dy));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class BeamWidget extends StatelessWidget {
  final Beam beam;
  const BeamWidget({super.key, required this.beam});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BeamPainter(beam),
      size: const Size(double.infinity, 200),
    );
  }
}
