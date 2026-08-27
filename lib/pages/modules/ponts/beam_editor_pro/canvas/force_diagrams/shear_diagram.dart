import 'package:flutter/material.dart';

import '../../domain/calculations/shear/shear_calculator.dart';
import '../../domain/models/beam.dart';
import 'shear_painter.dart';

class ShearDiagram extends StatelessWidget {
  final Beam beam;

  const ShearDiagram({
    super.key,
    required this.beam,
  });

  @override
  Widget build(BuildContext context) {
    final result = calculateShear(beam);

    return SizedBox.expand(
      child: CustomPaint(
        painter: ShearPainter(
          result: result,
          beamLength: beam.beamLength,
        ),
      ),
    );
  }
}