// ═══════════════════════════════════════════════════════════════
//  diagram/diagram_fullscreen.dart
//  Page plein écran diagrammes V / M
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';
import 'diagram_painter.dart';
import 'diagram_widget.dart';

class DiagramFullscreenPage extends StatefulWidget {
  final BeamResults results;
  final double      beamLength;

  const DiagramFullscreenPage({
    super.key,
    required this.results,
    required this.beamLength,
  });

  @override
  State<DiagramFullscreenPage> createState() => _DiagramFullscreenPageState();
}

class _DiagramFullscreenPageState extends State<DiagramFullscreenPage> {
  DiagramType _active = DiagramType.shear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BC.surface,
      body: SafeArea(
        child: Column(children: [
          // ── Barre de contrôle ──────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              _DiagramToggleBtn(
                label:    'V (kN)',
                color:    BC.shear,
                selected: _active == DiagramType.shear,
                onTap:    () => setState(() => _active = DiagramType.shear),
              ),
              const SizedBox(width: 8),
              _DiagramToggleBtn(
                label:    'M (kN·m)',
                color:    BC.moment,
                selected: _active == DiagramType.moment,
                onTap:    () => setState(() => _active = DiagramType.moment),
              ),
              const Spacer(),
              IconButton(
                icon:    const Icon(Icons.fullscreen_exit),
                color:   BC.textS,
                tooltip: 'Quitter plein écran',
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
          const Divider(height: 1),

          // ── Diagramme ──────────────────────────────────────
          Expanded(
            child: DiagramWidget(
              results:    widget.results,
              type:       _active,
              beamLength: widget.beamLength,
            ),
          ),
          _ResultsSummaryBar(results: widget.results),
        ]),
      ),
    );
  }
}

// ─── Toggle V / M ────────────────────────────────────────────────
class _DiagramToggleBtn extends StatelessWidget {
  final String       label;
  final Color        color;
  final bool         selected;
  final VoidCallback onTap;

  const _DiagramToggleBtn({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? color : BC.border,
              width: selected ? 1.5 : 1),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : BC.textS)),
      ),
    );
  }
}

// ─── Résumé compact ──────────────────────────────────────────────
class _ResultsSummaryBar extends StatelessWidget {
  final BeamResults results;
  const _ResultsSummaryBar({required this.results});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        _chip('V max', '${results.maxShear.abs().toStringAsFixed(2)} kN',    BC.shear),
        const SizedBox(width: 8),
        _chip('V min', '${results.minShear.toStringAsFixed(2)} kN',          BC.shear),
        const SizedBox(width: 8),
        _chip('M max', '${results.maxMoment.abs().toStringAsFixed(2)} kN·m', BC.moment),
        const SizedBox(width: 8),
        _chip('M min', '${results.minMoment.toStringAsFixed(2)} kN·m',       BC.moment),
      ]),
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: color,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(fontSize: 12, color: color,
                  fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        ]),
      ),
    );
  }
}

// ─── Barre toggle réutilisable (utilisée dans l'écran principal) ─
class DiagramToggleBar extends StatelessWidget {
  final DiagramType           active;
  final ValueChanged<DiagramType> onChanged;
  final VoidCallback          onFullscreen;

  const DiagramToggleBar({
    super.key,
    required this.active,
    required this.onChanged,
    required this.onFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(children: [
        _DiagramToggleBtn(
          label:    'V (kN)',
          color:    BC.shear,
          selected: active == DiagramType.shear,
          onTap:    () => onChanged(DiagramType.shear),
        ),
        const SizedBox(width: 6),
        _DiagramToggleBtn(
          label:    'M (kN·m)',
          color:    BC.moment,
          selected: active == DiagramType.moment,
          onTap:    () => onChanged(DiagramType.moment),
        ),
        const Spacer(),
        Tooltip(
          message: 'Plein écran',
          child: InkWell(
            onTap: onFullscreen,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: BC.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fullscreen, size: 18, color: BC.textS),
            ),
          ),
        ),
      ]),
    );
  }
}
