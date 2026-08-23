import 'package:flutter/material.dart';

class ProCard extends StatelessWidget {
  final Widget child;

  const ProCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE1E7F0),
        ),
      ),
      child: child,
    );
  }
}