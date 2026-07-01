// ═══════════════════════════════════════════════════════════════
//  results/results_panel.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';

class ResultsPanel extends StatelessWidget {
  final BeamModel beam;
  const ResultsPanel({super.key, required this.beam});

  @override
  Widget build(BuildContext context) {
    final r = beam.results;
    if (r == null || !r.isValid) {
      return const Center(
        child: Text('Pas de résultats — appuyez sur Calculer.',
            style: TextStyle(color: BC.textS, fontSize: 13)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('Réactions d\'appui', style: BC.sectionLabel),
        const SizedBox(height: 8),
        ...beam.supports.map(_ReactionTile.new),
        const SizedBox(height: 16),
        const Text('Valeurs caractéristiques', style: BC.sectionLabel),
        const SizedBox(height: 8),
        _Row('V max', '${r.maxShear.toStringAsFixed(2)} kN',    BC.shear),
        _Row('V min', '${r.minShear.toStringAsFixed(2)} kN',    BC.shear),
        _Row('M max', '${r.maxMoment.toStringAsFixed(2)} kN·m', BC.moment),
        _Row('M min', '${r.minMoment.toStringAsFixed(2)} kN·m', BC.moment),
        _Row('Position M max', '${r.posMaxMoment.toStringAsFixed(2)} m', BC.moment),
      ],
    );
  }
}

class _ReactionTile extends StatelessWidget {
  final BeamSupport support;
  const _ReactionTile(this.support);

  @override
  Widget build(BuildContext context) {
    final extra = StringBuffer();
    if (support.reactionH.abs() > 0.01) {
      extra.write('  RH=${support.reactionH.toStringAsFixed(2)} kN');
    }
    if (support.reactionM.abs() > 0.01) {
      extra.write('  RM=${support.reactionM.toStringAsFixed(2)} kN·m');
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: BC.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: BC.border)),
      child: Row(children: [
        const Icon(Icons.arrow_upward, color: BC.support, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${support.label}  ·  x=${support.position.toStringAsFixed(2)} m',
                style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: BC.textP)),
            Text('RV=${support.reactionV.toStringAsFixed(2)} kN${extra.toString()}',
                style: const TextStyle(fontSize: 11, color: BC.textS,
                    fontFamily: 'monospace')),
          ]),
        ),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _Row(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: BC.textS)),
            Text(value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: color, fontFamily: 'monospace')),
          ],
        ),
      );
}

// ─── Barre résumé compacte ────────────────────────────────────────
class ResultsSummaryBar extends StatelessWidget {
  final BeamResults results;
  const ResultsSummaryBar({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(children: [
        _chip('V max', '${results.maxShear.abs().toStringAsFixed(1)} kN',    BC.shear),
        const SizedBox(width: 6),
        _chip('M max', '${results.maxMoment.abs().toStringAsFixed(1)} kN·m', BC.moment),
        const SizedBox(width: 6),
        _chip('M min', '${results.minMoment.toStringAsFixed(1)} kN·m',
            BC.moment.withValues(alpha: 0.7)),
      ]),
    );
  }

  Widget _chip(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 10, color: color,
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 12, color: color,
                fontWeight: FontWeight.w700, fontFamily: 'monospace')),
          ]),
        ),
      );
}
