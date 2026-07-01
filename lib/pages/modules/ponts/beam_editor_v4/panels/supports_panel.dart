// ═══════════════════════════════════════════════════════════════
//  panels/supports_panel.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';
import '../widgets/support_tile.dart';
import '../widgets/status_chip.dart';

class SupportsPanel extends StatelessWidget {
  final List<BeamSupport>     supports;
  final String?               selectedId;
  final VoidCallback          onAdd;
  final ValueChanged<String?> onSelect;
  final ValueChanged<BeamSupport> onEdit;
  final ValueChanged<BeamSupport> onDelete;

  const SupportsPanel({
    super.key,
    required this.supports,
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
            Text('${supports.length} appui(s)',
                style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w700, color: BC.primary)),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(
                  foregroundColor: BC.support,
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (supports.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: StatusChip(
                message: 'Aucun appui défini', isError: true),
          ),
        ...supports.map((s) => SupportTile(
              support:  s,
              selected: selectedId == s.id,
              onTap:    () => onSelect(s.id == selectedId ? null : s.id),
              onEdit:   () => onEdit(s),
              onDelete: () => onDelete(s),
            )),
      ],
    );
  }
}
