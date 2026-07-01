// ═══════════════════════════════════════════════════════════════
//  widgets/support_tile.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';

class SupportTile extends StatelessWidget {
  final BeamSupport  support;
  final bool         selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SupportTile({
    super.key,
    required this.support,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin:   const EdgeInsets.only(bottom: 6),
        padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? BC.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? BC.primary : BC.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(_icon(), color: BC.support, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(support.label,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600, color: BC.textP)),
                Text(
                  'x = ${support.position.toStringAsFixed(2)} m'
                  '  ·  ${support.reactionDescription}',
                  style: const TextStyle(fontSize: 11, color: BC.textS,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          _IconBtn(icon: Icons.edit_outlined,  color: BC.textS,           onTap: onEdit),
          _IconBtn(icon: Icons.delete_outline, color: Colors.red.shade400, onTap: onDelete),
        ]),
      ),
    );
  }

  IconData _icon() {
    switch (support.type) {
      case SupportType.simple:  return Icons.change_history;
      case SupportType.double_: return Icons.vertical_align_bottom;
      case SupportType.hinge:   return Icons.circle_outlined;
      case SupportType.fixed:   return Icons.view_stream;
    }
  }
}

class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 17, color: color)),
      );
}
