import 'package:flutter/material.dart';

class ProTabScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const ProTabScaffold({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const Spacer(),

                ?action,
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}