import 'package:flutter/material.dart';
import 'package:roadly/componets/modules.dart';

class ModulesTile extends StatelessWidget {
  final Modules modules;
  final void Function()? onTap;
  const ModulesTile({super.key, required this.modules, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 53, 103, 229),
              Color.fromARGB(255, 12, 137, 191),
            ],
          ),
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
      ),
    );
  }
}
