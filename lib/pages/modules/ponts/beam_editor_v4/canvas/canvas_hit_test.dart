// ═══════════════════════════════════════════════════════════════
//  canvas/canvas_hit_test.dart
//  Détection tap/drag — hitbox corrigée pour charges réparties
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';

class CanvasHitTest {
  CanvasHitTest._();

  static const double _hitRadius = 24.0;

  /// Retourne l'ID de l'élément le plus proche du [tapPos].
  /// Pour les charges réparties, on utilise le centre visuel
  /// (milieu de [position, endPosition]) au lieu de position seule.
  static String? hitTest(
    BeamModel beam,
    Offset tapPos,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    String? best;
    double bestDist = _hitRadius;

    // ── Appuis ─────────────────────────────────────────────────
    for (final s in beam.supports) {
      final px = offsetX + s.position * scale;
      final d  = (tapPos - Offset(px, offsetY)).distance;
      if (d < bestDist) {
        bestDist = d;
        best = s.id;
      }
    }

    // ── Charges ────────────────────────────────────────────────
    for (final l in beam.loads) {
      // Charges réparties : hitbox sur le centre visuel de la zone
      final hitPos = l.isDistributed ? l.visualCenter : l.position;
      final px = offsetX + hitPos * scale;
      // Décaler légèrement vers le haut pour les flèches
      final hitOffset = Offset(px, offsetY - 20);
      final d = (tapPos - hitOffset).distance;
      if (d < bestDist) {
        bestDist = d;
        best = l.id;
      }
    }

    return best;
  }

  static double pxToMeters(
    double px,
    double offsetX,
    double scale,
    double beamLength,
  ) => ((px - offsetX) / scale).clamp(0.0, beamLength);
}
