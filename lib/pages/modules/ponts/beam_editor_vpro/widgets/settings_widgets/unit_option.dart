import 'package:flutter/material.dart';

class UnitOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String selectedUnit;
  final VoidCallback onSelected;

  const UnitOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selectedUnit,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == selectedUnit;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEAF1FF)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE1E7F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFDCE5F3),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.straighten_rounded,
                size: 19,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF526174),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 21,
                color: Color(0xFF2563EB),
              ),
          ],
        ),
      ),
    );
  }
}