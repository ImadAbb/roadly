// ═══════════════════════════════════════════════════════════════
//  panels/loads_panel.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';
import '../widgets/load_tile.dart';
import '../widgets/status_chip.dart';

class LoadsPanel extends StatelessWidget {
  final List<BeamLoad>        loads;
  final String?               selectedId;
  final VoidCallback          onAdd;
  final ValueChanged<String?> onSelect;
  final ValueChanged<BeamLoad> onEdit;
  final ValueChanged<BeamLoad> onDelete;

  const LoadsPanel({
    super.key,
    required this.loads,
    required this.selectedId,
    required this.onAdd,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${loads.length} charge(s)',
                style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w700, color: BC.primary)),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(
                  foregroundColor: BC.load,
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (loads.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: StatusChip(
                message: 'Aucune charge définie', isError: true),
          ),
        ...loads.map((l) => LoadTile(
              load:     l,
              selected: selectedId == l.id,
              onTap:    () => onSelect(l.id == selectedId ? null : l.id),
              onEdit:   () => onEdit(l),
              onDelete: () => onDelete(l),
            )),
      ],
    );
  }
}
