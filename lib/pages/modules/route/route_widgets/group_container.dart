import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/route/route_widgets/title_container.dart';

class GroupContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final Animation<double>? animation;

  const GroupContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleContainer(title: title, icon: icon),
          Padding(padding: const EdgeInsets.all(16.0), child: content),
        ],
      ),
    );

    return animation != null
        ? FadeTransition(opacity: animation!, child: child)
        : child;
  }
}
