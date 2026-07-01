// ═══════════════════════════════════════════════════════════════
//  core/beam_colors.dart
//  Constantes de couleurs et styles partagés dans tout le module
//  Note : withValues() utilisé à la place de withOpacity() (deprecated)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class BC {
  BC._();

  // ── Couleurs principales ─────────────────────────────────────
  static const primary  = Color(0xFF1E3A8A);
  static const shear    = Color(0xFFDC2626);
  static const moment   = Color(0xFF0369A1);
  static const load     = Color(0xFFCC3A1A);
  static const support  = Color(0xFF1A5C38);
  static const reaction = Color(0xFF1A7A5E);
  static const drag     = Color(0xFF0EA5E9);
  static const warning  = Color(0xFFF59E0B);

  // ── Couleurs neutres ─────────────────────────────────────────
  static const surface  = Color(0xFFF8FAFC);
  static const border   = Color(0xFFE2E8F0);
  static const textP    = Color(0xFF0F172A);
  static const textS    = Color(0xFF64748B);
  static const textM    = Color(0xFF94A3B8);

  // ── Couleurs canvas ──────────────────────────────────────────
  static const beamFill   = Color(0xFF2D6DB5);
  static const beamBorder = Color(0xFF1E3A5F);
  static const distLoad   = Color(0xFFB84B00);
  static const momentClr  = Color(0xFF7B3FA0);
  static const ground     = Color(0xFF475569);
  static const dimLine    = Color(0xFF8090A8);
  static const selected   = Color(0xFFF59E0B);

  // ── InputDecoration partagée ─────────────────────────────────
  static InputDecoration fieldDeco(String label, {String? suffix}) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: BC.textS),
        suffixText: suffix,
        suffixStyle: const TextStyle(fontSize: 12, color: BC.textS),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BC.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BC.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BC.primary, width: 1.5),
        ),
      );

  static const sectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: BC.primary,
  );
}

/// Extension pour remplacer withOpacity (deprecated) par withValues
extension ColorX on Color {
  Color wo(double opacity) => withValues(alpha: opacity);
}
