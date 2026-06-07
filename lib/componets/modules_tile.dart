import 'package:flutter/material.dart';
import 'package:roadly/componets/modules.dart';

class ModulesTile extends StatelessWidget {
  final Modules modules;
  const ModulesTile({super.key,
  required this.modules});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [
          Text(modules.name),
          Icon(modules.icon, size: 40, color: Colors.grey[800]),
          Text("Dernière mise à jour : ${modules.lastUpdate}"),
        ],
      ),
    );
  }
}