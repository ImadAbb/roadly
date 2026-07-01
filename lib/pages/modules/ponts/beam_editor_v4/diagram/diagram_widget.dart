// ═══════════════════════════════════════════════════════════════
//  diagram/diagram_widget.dart
//  Widget interactif : tap/drag curseur, double tap efface
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';
import 'diagram_painter.dart';

class DiagramWidget extends StatefulWidget {
  final BeamResults results;
  final DiagramType type;
  final double      beamLength;

  const DiagramWidget({
    super.key,
    required this.results,
    required this.type,
    required this.beamLength,
  });

  @override
  State<DiagramWidget> createState() => _DiagramWidgetState();
}

class _DiagramWidgetState extends State<DiagramWidget> {
  double? _cursorX;

  Color get _color =>
      widget.type == DiagramType.shear ? BC.shear : BC.moment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:              (d) => setState(() => _cursorX = d.localPosition.dx),
      onHorizontalDragUpdate: (d) => setState(() =>
          _cursorX = (_cursorX ?? d.localPosition.dx) + d.delta.dx),
      onDoubleTap: () => setState(() => _cursorX = null),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BC.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [
            CustomPaint(
              size: Size.infinite,
              painter: DiagramPainter(
                results:    widget.results,
                type:       widget.type,
                beamLength: widget.beamLength,
                color:      _color,
                cursorX:    _cursorX,
              ),
            ),
            if (_cursorX == null)
              Positioned(
                bottom: 6, right: 8,
                child: Text(
                  'Touchez pour inspecter · Double tap pour effacer',
                  style: TextStyle(fontSize: 9,
                      color: BC.textM.withValues(alpha: 0.7)),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
