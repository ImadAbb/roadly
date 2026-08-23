import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/canvas/painters/beam_painter_chain_dimensions.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/beam.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/load.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/state/interface_settings_provider.dart';

import '../domain/calculations/reactions/reaction_calculator.dart';
import 'painters/beam_painter_beam.dart';
import 'painters/beam_painter_dimensions.dart';
import 'painters/beam_painter_loads.dart';
import 'painters/beam_painter_reactions.dart';
import 'painters/beam_painter_supports.dart';

class BeamDiagram extends StatelessWidget {
  final Beam beam;

  const BeamDiagram({super.key, required this.beam});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<InterfaceSettingsProvider>();

    final afficherValeursCharges = settings.afficherValeursCharges;
    final afficherCotations = settings.afficherCotations;
    final afficherReactions = settings.afficherReactions;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        border: Border.all(color: const Color(0xFFD7DFEC)),
      ),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: CustomPaint(
          painter: BeamPainter(beam, afficherValeursCharges, afficherCotations, afficherReactions: afficherReactions),
        ),
      ),
    );
  }
}

class BeamPainter extends CustomPainter {
  final Beam beam;
  final bool afficherValeursCharges;
  final bool afficherCotations;
  final bool afficherReactions;

  BeamPainter(this.beam, this.afficherValeursCharges, this.afficherCotations, {required this.afficherReactions});

  @override
  void paint(Canvas canvas, Size size) {
    final length = beam.beamLength;

    if (length <= 0) {
      return;
    }

    const leftMargin = 35.0;
    const rightMargin = 35.0;

    final drawingWidth = size.width - leftMargin - rightMargin;

    final beamY = size.height * 0.58;

    // ═══════════════════════════════════════
    // CONVERSION POSITION RÉELLE → PIXELS
    // ═══════════════════════════════════════

    double xFromPosition(double position) {
      final clamped = position.clamp(0.0, length);

      return leftMargin + (clamped / length) * drawingWidth;
    }

    // ═══════════════════════════════════════
    // POUTRE
    // ═══════════════════════════════════════

    drawBeam(canvas, xFromPosition(0), xFromPosition(length), beamY);

    // ═══════════════════════════════════════
    // APPUIS
    // ═══════════════════════════════════════

    for (final support in beam.supports) {
      drawSupport(canvas, support, xFromPosition(support.position), beamY);
    }

    // ═══════════════════════════════════════
    // CHARGES
    // ═══════════════════════════════════════

    for (final load in beam.loads) {
      drawLoad(canvas, load, xFromPosition, beamY, afficherValeursCharges);
    }

    // ═══════════════════════════════════════
    // RÉACTIONS
    // ═══════════════════════════════════════
    if (afficherReactions) {
      
    final reactions = calculateReactions(beam);
    final middleX = leftMargin + drawingWidth / 2; 

    BeamPainterReactions.drawReactions(
      canvas: canvas,
      supports: beam.supports,
      beamY: beamY,
      positionToCanvasX: xFromPosition,
      verticalReactions: reactions.verticalReactions,
      momentReaction: reactions.mA,
      middleX: middleX, 
    );
    }

    // ═══════════════════════════════════════
    // COTATIONS
    // ═══════════════════════════════════════

    if (afficherCotations) {
      drawDimension(
        canvas,
        xFromPosition(0),
        xFromPosition(length),
        beamY,
        length,
      );

      final dimensionPositions = <double>[];

      // Positions des appuis
      for (final support in beam.supports) {
        dimensionPositions.add(support.position);
      }

      // Positions des charges
      for (final load in beam.loads) {
        dimensionPositions.add(load.position);

        if (load is DistributedLoad) {
          dimensionPositions.add(load.positionEnd);
        }
      }

      drawChainDimensions(
        canvas,
        xFromPosition,
        beamY,
        length,
        dimensionPositions,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BeamPainter oldDelegate) {
    return true;
  }
}
