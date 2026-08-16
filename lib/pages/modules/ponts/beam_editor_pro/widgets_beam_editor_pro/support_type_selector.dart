import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/beam_supports/support_classes.dart';

class SupportTypeSelector extends StatelessWidget {
  final SupportType? selectedType;
  final ValueChanged<SupportType> onSelected;

  const SupportTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  static const List<SupportType> _types = [
    SupportType.simple,
    SupportType.double_,
    SupportType.rotule,
    SupportType.encastrement,
  ];

  static String labelFor(SupportType type) {
    switch (type) {
      case SupportType.simple:
        return 'Simple';
      case SupportType.double_:
        return 'Double';
      case SupportType.rotule:
        return 'Rotule';
      case SupportType.encastrement:
        return 'Encastrement';
    }
  }

  Widget _buildCard(SupportType type) {
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onSelected(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        height: 58,
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade300 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.zero,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            labelFor(type),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.7,
      padding: const EdgeInsets.all(8),
      children: _types.map(_buildCard).toList(),
    );
  }
}
