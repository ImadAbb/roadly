// ═══════════════════════════════════════════════════════════════
//  widgets/load_tile.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';

class LoadTile extends StatelessWidget {
  final BeamLoad     load;
  final bool         selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LoadTile({
    super.key,
    required this.load,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static const _icons = {
    LoadType.pointForce:      Icons.arrow_downward,
    LoadType.pointMoment:     Icons.rotate_right,
    LoadType.distributedLoad: Icons.density_medium,
    LoadType.triangularLoad:  Icons.change_history,
  };

  @override
  Widget build(BuildContext context) {
    final unit = load.isDistributed
        ? 'kN/m'
        : (load.type == LoadType.pointMoment ? 'kN·m' : 'kN');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin:   const EdgeInsets.only(bottom: 6),
        padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? BC.load.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? BC.load : BC.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(_icons[load.type]!, color: BC.load, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  load.label.isNotEmpty
                      ? load.label
                      : '${load.magnitude.abs().toStringAsFixed(1)} $unit',
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600, color: BC.textP),
                ),
                Text(
                  'x = ${load.position.toStringAsFixed(2)} m'
                  '${load.isDistributed ? ' → ${(load.endPosition ?? 0).toStringAsFixed(2)} m' : ''}',
                  style: const TextStyle(fontSize: 11, color: BC.textS,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          _IconBtn(icon: Icons.edit_outlined,  color: BC.textS,            onTap: onEdit),
          _IconBtn(icon: Icons.delete_outline, color: Colors.red.shade400, onTap: onDelete),
        ]),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 17, color: color)));
}
