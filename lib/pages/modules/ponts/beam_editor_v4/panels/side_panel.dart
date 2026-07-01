// ═══════════════════════════════════════════════════════════════
//  panels/side_panel.dart
//  Conteneur onglets : Appuis / Charges / Géométrie
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';
import 'geo_panel.dart';
import 'supports_panel.dart';
import 'loads_panel.dart';

class SidePanel extends StatefulWidget {
  final BeamModel             beam;
  final String?               selectedId;
  final VoidCallback          onAddSupport;
  final ValueChanged<String?> onSelectSupport;
  final ValueChanged<BeamSupport> onEditSupport;
  final ValueChanged<BeamSupport> onDeleteSupport;
  final VoidCallback          onAddLoad;
  final ValueChanged<String?> onSelectLoad;
  final ValueChanged<BeamLoad> onEditLoad;
  final ValueChanged<BeamLoad> onDeleteLoad;
  final ValueChanged<double>  onLengthChanged;
  final ValueChanged<String>  onNameChanged;
  final VoidCallback          onLengthSubmitted;
  final VoidCallback          onOpenTheory;

  const SidePanel({
    super.key,
    required this.beam,
    required this.selectedId,
    required this.onAddSupport,
    required this.onSelectSupport,
    required this.onEditSupport,
    required this.onDeleteSupport,
    required this.onAddLoad,
    required this.onSelectLoad,
    required this.onEditLoad,
    required this.onDeleteLoad,
    required this.onLengthChanged,
    required this.onNameChanged,
    required this.onLengthSubmitted,
    required this.onOpenTheory,
  });

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  int _tab = 0;
  static const _tabs = ['Appuis', 'Charges', 'Géométrie'];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _TabBar(tabs: _tabs, selected: _tab,
          onTap: (i) => setState(() => _tab = i)),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: switch (_tab) {
            0 => SupportsPanel(
                supports:   widget.beam.supports,
                selectedId: widget.selectedId,
                onAdd:      widget.onAddSupport,
                onSelect:   widget.onSelectSupport,
                onEdit:     widget.onEditSupport,
                onDelete:   widget.onDeleteSupport),
            1 => LoadsPanel(
                loads:      widget.beam.loads,
                selectedId: widget.selectedId,
                onAdd:      widget.onAddLoad,
                onSelect:   widget.onSelectLoad,
                onEdit:     widget.onEditLoad,
                onDelete:   widget.onDeleteLoad),
            2 => GeoPanel(
                beamLength:       widget.beam.length,
                beamName:         widget.beam.name,
                onLengthChanged:  widget.onLengthChanged,
                onNameChanged:    widget.onNameChanged,
                onLengthSubmitted: widget.onLengthSubmitted,
                onOpenTheory:     widget.onOpenTheory),
            _ => const SizedBox(),
          },
        ),
      ),
    ]);
  }
}

class _TabBar extends StatelessWidget {
  final List<String>     tabs;
  final int              selected;
  final ValueChanged<int> onTap;
  const _TabBar({required this.tabs, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BC.surface,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final sel = e.key == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin:  const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? BC.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(e.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : BC.textS)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
