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

    // Associer chaque label à une icône
    final Map<String, IconData> commandIcons = {
      "Aj. support": Icons.architecture,
      "Aj. charge": Icons.flash_on,
      "Modifier": Icons.edit,
      "SUPPR": Icons.delete_forever,
    };

    final List<String> commands = commandDialogs.keys.toList();

    return GridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 20,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2, // adapté pour icône seule
      shrinkWrap: false,
      children: commands.map((command) {
        return InkWell(
          onTap: () {
            commandDialogs[command]?.call(context, widget.beam, widget.onUpdate);
          },
          borderRadius: BorderRadius.circular(12),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.teal.shade600,
            elevation: 4,
            child: Center(
              child: Tooltip(
                message: command,
                child: Icon(
                  commandIcons[command],
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
