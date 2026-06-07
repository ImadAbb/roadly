import 'package:flutter/material.dart';
import 'package:roadly/componets/modules.dart';

class ModulesTile extends StatelessWidget {
  final Modules modules;
  const ModulesTile({super.key, required this.modules});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(modules.icon, size: 90, color: Colors.grey[800]),

          Text(
            modules.name,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),
          Text("Dernière mise à jour : ${modules.lastUpdate}"),
        ],
      ),
    );
  }
}
