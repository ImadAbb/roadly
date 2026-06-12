import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/classes.dart';

// Painter qui dessine la poutre, les appuis et les charges
class BeamPainter extends CustomPainter {
  final Beam beam;
  BeamPainter(this.beam);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // 1. Dessiner la poutre (ligne horizontale)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // 2. Dessiner les appuis
    for (var support in beam.supports) {
      double posX = support.x / beam.length * size.width;

      if (support.type == SupportType.simple) {
        // triangle
        Path path = Path();
        path.moveTo(posX, size.height / 2);
        path.lineTo(posX - 10, size.height / 2 + 20);
        path.lineTo(posX + 10, size.height / 2 + 20);
        path.close();
        canvas.drawPath(path, paint);
      } else if (support.type == SupportType.encastrement) {
        // rectangle noir
        canvas.drawRect(
          Rect.fromLTWH(posX - 5, size.height / 2 - 20, 10, 40),
          paint,
        );
      }
    }

    // 3. Dessiner les charges
    for (var load in beam.loads) {
      double posX = load.x / beam.length * size.width;

      if (load is PointLoad) {
        // Corps de la flèche (descendante)
        canvas.drawLine(
          Offset(posX, size.height / 2 - 40),
          Offset(posX, size.height / 2),
          paint,
        );

        // Tête de flèche orientée vers le bas (décalée pour ne pas coller)
        canvas.drawLine(
          Offset(posX - 6, size.height / 2 - 12),
          Offset(posX, size.height / 2),
          paint,
        );
        canvas.drawLine(
          Offset(posX + 6, size.height / 2 - 12),
          Offset(posX, size.height / 2),
          paint,
        );
      } else if (load is DistributedLoad) {
        double posXstart = load.x / beam.length * size.width;
        double posXEnd = load.xEnd / beam.length * size.width;
        
        double lastArrowX = posXEnd - ((posXEnd - posXstart) % 25);

        canvas.drawLine(
          Offset(posXstart, size.height / 2 - 30), 
          Offset(lastArrowX, size.height / 2 - 30), 
          paint
        );
        // série de flèches entre x et xEnd
        for (double x = posX; x <= posXEnd; x += 25) {
          // Corps de la flèche
          canvas.drawLine(
            Offset(x, size.height / 2 - 30),
            Offset(x, size.height / 2),
            paint,
          );

          // Tête de flèche orientée vers le bas (décalée)
          canvas.drawLine(
            Offset(x - 6, size.height / 2 - 12),
            Offset(x, size.height / 2),
            paint,
          );
          canvas.drawLine(
            Offset(x + 6, size.height / 2 - 12),
            Offset(x, size.height / 2),
            paint,
          );
        }
      }
    }
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
