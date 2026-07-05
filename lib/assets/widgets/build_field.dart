import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon),
              contentPadding: const EdgeInsets.all(18),
              suffixIcon: nextFocus != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_drop_down_circle),
                      color: const Color.fromARGB(151, 68, 137, 255),
                      onPressed: () => FocusScope.of(context).requestFocus(nextFocus),
                    )
                  : IconButton(
                      icon: const Icon(Icons.done_outlined),
                      color: const Color.fromARGB(196, 68, 137, 255),
                      onPressed: () => FocusScope.of(context).unfocus(),
                    )
            ),
          ),
        ),
      ],
    );
  }
}
