import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/control_pannel/button_log.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/classes.dart';

class MyControlPannel extends StatefulWidget {
  final Beam beam;
  final VoidCallback onUpdate;

  const MyControlPannel({
    super.key,
    required this.beam,
    required this.onUpdate,
  });

  @override
  State<MyControlPannel> createState() => _MyControlPannelState();
}

class _MyControlPannelState extends State<MyControlPannel> {
  @override
  Widget build(BuildContext context) {
    // Associer chaque label à sa fonction
    final Map<String, void Function(BuildContext, Beam, VoidCallback)> commandDialogs = {
      "Aj. support": showAddSupportDialog,
      "Aj. charge": showAddLoadDialog,
      "Modifier": showModifyDialog,
      "SUPPR": showDeleteDialog,
    };

    final List<String> commands = commandDialogs.keys.toList();

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.transparent,
      constraints: const BoxConstraints(maxHeight: 200),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: commands.map((command) {
          return GestureDetector(
            onTap: () {
              // 👉 Appelle directement la fonction associée
              commandDialogs[command]?.call(context, widget.beam, widget.onUpdate);
            },
            child: Card(
              color: const Color.fromARGB(255, 124, 160, 125),
              elevation: 1,
              child: Center(
                child: Text(
                  command,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
