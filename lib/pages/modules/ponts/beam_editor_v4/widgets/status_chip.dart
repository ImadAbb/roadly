// ═══════════════════════════════════════════════════════════════
//  widgets/status_chip.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_colors.dart';

class StatusChip extends StatelessWidget {
  final String message;
  final bool   isError;

  const StatusChip({super.key, required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final c = isError ? Colors.red.shade700 : BC.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:  c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isError ? Icons.error_outline : Icons.info_outline,
            size: 14, color: c),
        const SizedBox(width: 6),
        Flexible(child: Text(message,
            style: TextStyle(fontSize: 12, color: c,
                fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

Future<bool?> confirmDelete(BuildContext context, String what) =>
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Supprimer ?'),
        content: Text('Supprimer $what ?'),
        shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
