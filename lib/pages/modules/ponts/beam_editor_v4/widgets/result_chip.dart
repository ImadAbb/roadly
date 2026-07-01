// ═══════════════════════════════════════════════════════════════
//  widgets/result_chip.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class ResultChip extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const ResultChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:  color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: color,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(fontSize: 14, color: color,
                    fontWeight: FontWeight.w700, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}
