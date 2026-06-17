import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class BuildField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final FocusNode? nextFocus;

  const BuildField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    this.nextFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: nextFocus != null
            ? TextInputAction.next
            : TextInputAction.done,
        onSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon),
          labelText: label,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}
