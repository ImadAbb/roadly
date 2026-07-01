// ═══════════════════════════════════════════════════════════════
//  canvas/canvas_widget.dart
//  Widget interactif canvas
//  Corrections :
//    - Guard null sur draggingId (évite le crash)
//    - SafeArea iPhone landscape (MediaQuery.padding)
//    - Bouton plein écran unique
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';
import 'beam_canvas_painter.dart';
import 'canvas_hit_test.dart';

class BeamCanvasWidget extends StatelessWidget {
  final BeamModel beam;
  final String?   selectedId;
  final String?   draggingId;
  final double    dragX;
  final bool      showReactions;
  final bool      isFullscreen;

  final ValueChanged<String?>  onSelect;
  final ValueChanged<String>   onDragStart;
  final ValueChanged<double>   onDragUpdate;
  final ValueChanged<double>   onDragEnd;
  final VoidCallback           onDragCancel;
  final VoidCallback           onAddSupport;
  final VoidCallback           onAddLoad;
  final VoidCallback           onToggleReactions;
  final VoidCallback           onToggleFullscreen;

  const BeamCanvasWidget({
    super.key,
    required this.beam,
    required this.selectedId,
    required this.draggingId,
    required this.dragX,
    required this.showReactions,
    required this.isFullscreen,
    required this.onSelect,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    required this.onAddSupport,
    required this.onAddLoad,
    required this.onToggleReactions,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    // Safe area pour iPhone landscape (notch / Dynamic Island)
    final mq      = MediaQuery.of(context);
    final leftPad = mq.padding.left;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: LayoutBuilder(builder: (ctx, box) {
        final W = box.maxWidth;
        final H = box.maxHeight;
        // Décaler offsetX selon le safe area
        final offsetX = 52.0 + leftPad;
        final scale   = (W - offsetX - 36) / beam.length;
        final offsetY = H * 0.50;

        return Stack(children: [
          // ── GestureDetector ────────────────────────────────
          GestureDetector(
            onTapDown: (d) {
              final hit = CanvasHitTest.hitTest(
                  beam, d.localPosition, scale, offsetX, offsetY);
              onSelect(hit);
            },
            onLongPressStart: (d) {
              final hit = CanvasHitTest.hitTest(
                  beam, d.localPosition, scale, offsetX, offsetY);
              if (hit != null) onDragStart(hit);
            },
            onLongPressMoveUpdate: (d) {
              // Guard : ne rien faire si draggingId est null
              if (draggingId == null) return;
              final clampedX = d.localPosition.dx
                  .clamp(offsetX, offsetX + beam.length * scale);
              onDragUpdate(clampedX);
            },
            onLongPressEnd: (d) {
              // Guard : ne rien faire si draggingId est null
              if (draggingId == null) return;
              final newPos = CanvasHitTest.pxToMeters(
                  dragX, offsetX, scale, beam.length);
              onDragEnd(newPos);
            },
            onLongPressCancel: onDragCancel,
            child: CustomPaint(
              size: Size(W, H),
              painter: BeamCanvasPainter(
                beam:           beam,
                scale:          scale,
                offsetX:        offsetX,
                offsetY:        offsetY,
                selectedId:     selectedId,
                draggingId:     draggingId,
                dragX:          dragX,
                showReactions:  showReactions,
                showDimensions: true,
              ),
            ),
          ),

          // ── Boutons overlay ─────────────────────────────────
          Positioned(
            top: 8,
            // Boutons à droite, respecte la safe area droite
            right: mq.padding.right + 8,
            child: Wrap(
              spacing: 5,
              children: [
                _CanvasChip(
                  icon:   showReactions
                      ? Icons.visibility_off
                      : Icons.visibility,
                  label:  showReactions ? 'Masquer R' : 'Réactions',
                  active: showReactions,
                  onTap:  onToggleReactions,
                ),
                _CanvasChip(
                  icon:  Icons.add_circle_outline,
                  label: 'Appui',
                  onTap: onAddSupport,
                ),
                _CanvasChip(
                  icon:  Icons.arrow_downward,
                  label: 'Charge',
                  onTap: onAddLoad,
                ),
                _CanvasChip(
                  icon:  isFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  label: isFullscreen ? 'Fermer' : 'Plein écran',
                  onTap: onToggleFullscreen,
                ),
              ],
            ),
          ),

          // ── Hint drag ───────────────────────────────────────
          Positioned(
            bottom: mq.padding.bottom + 6,
            left: offsetX,
            child: Text(
              'Appui long pour déplacer',
              style: TextStyle(
                  fontSize: 9.5, color: _ColorWo(BC.textM).wo(0.75)),
            ),
          ),
        ]);
      }),
    );
  }
}

// ─── Chip bouton canvas ───────────────────────────────────────────
class _CanvasChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     active;
  final VoidCallback onTap;

  const _CanvasChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color:  active ? BC.primary : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: active ? BC.primary : BC.border),
          boxShadow: [
            BoxShadow(
                color: _ColorWo(Colors.black).wo(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14,
                color: active ? Colors.white : BC.textS),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10.5,
                    color: active ? Colors.white : BC.textS,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

extension _ColorWo on Color {
  Color wo(double a) => withValues(alpha: a);
}
