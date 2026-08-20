import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_vpro/models/beam_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/pages/settings/providers/interface_settings_provider.dart';

import 'beam_painter_beam.dart';
import 'beam_painter_dimensions.dart';
import 'beam_painter_loads.dart';
import 'beam_painter_supports.dart';

class BeamDiagram extends StatelessWidget {
  final Beam beam;

  const BeamDiagram({super.key, required this.beam});

  @override
  Widget build(BuildContext context) {
    final afficherValeursCharges = context.watch<InterfaceSettingsProvider>().afficherValeursCharges;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        border: Border.all(color: const Color(0xFFD7DFEC)),
      ),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: CustomPaint(painter: BeamPainter(beam, afficherValeursCharges)),
      ),
    );
  }
}

class BeamPainter extends CustomPainter {
  final Beam beam;
  final bool afficherValeursCharges;

  BeamPainter(this.beam, this.afficherValeursCharges);

  @override
  void paint(Canvas canvas, Size size) {
    final length = beam.beamLenght;
    if (length <= 0) {
      return;
    }

    const leftMargin = 35.0;
    const rightMargin = 35.0;
    final drawingWidth = size.width - leftMargin - rightMargin;
    final beamY = size.height * 0.58;

    double xFromPosition(double position) {
      final clamped = position.clamp(0.0, length);
      return leftMargin + (clamped / length) * drawingWidth;
    }

    drawBeam(canvas, xFromPosition(0), xFromPosition(length), beamY);

    for (final support in beam.supports) {
      drawSupport(canvas, support, xFromPosition(support.position), beamY);
    }

    for (final load in beam.loads) {
      drawLoad(canvas, load, xFromPosition, beamY, afficherValeursCharges);
    }

    drawDimension(
      canvas,
      xFromPosition(0),
      xFromPosition(length),
      beamY,
      length,
    );
  }

  @override
  bool shouldRepaint(covariant BeamPainter oldDelegate) {
    return true;
  }
}
