//BUTTON ADD SUPPORT
import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_v1/control_pannel/command_log.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_v1/editeur_de_poutre/structure/classes.dart';

void showAddSupportDialog(BuildContext context, Beam beam, VoidCallback onUpdate) {
  double pos = 0.0;
  SupportType type = SupportType.simple;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Ajouter un support"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Position (m)"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => pos = double.tryParse(val) ?? 0.0,
                ),
                DropdownButton<SupportType>(
                  value: type,
                  items: SupportType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        type = val;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  AddSupportCommand(pos, type).execute(beam);
                  onUpdate();
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );
}

void showAddLoadDialog(BuildContext context, Beam beam, VoidCallback onUpdate) {
  double pos = 0.0;
  double value = 0.0;
  LoadType type = LoadType.ponctuelle;
  double xEnd = 0.0;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Ajouter une charge"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: "Position (m)"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => pos = double.tryParse(val) ?? 0.0,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Valeur (kN)"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => value = double.tryParse(val) ?? 0.0,
                  ),
                  DropdownButton<LoadType>(
                    value: type,
                    items: LoadType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          type = val;
                        });
                      }
                    },
                  ),
                  if (type == LoadType.repartie)
                    TextField(
                      decoration: const InputDecoration(labelText: "Position fin (m)"),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => xEnd = double.tryParse(val) ?? 0.0,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  AddLoadCommand(pos, value, type, xEnd: xEnd).execute(beam);
                  onUpdate();
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );
}

void showModifyDialog(BuildContext context, Beam beam, VoidCallback onUpdate) {
  double pos = 0.0;
  SupportType type = SupportType.simple;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Modifier"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Position (m)"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => pos = double.tryParse(val) ?? 0.0,
                ),
                DropdownButton<SupportType>(
                  value: type,
                  items: SupportType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        type = val;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  AddSupportCommand(pos, type).execute(beam);
                  onUpdate();
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );
}

void showDeleteDialog(BuildContext context, Beam beam, VoidCallback onUpdate) {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Supprimer"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Voulez vous tous supprimer ?")
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  DeleteCommand().execute(beam);
                  onUpdate();
                  Navigator.pop(context);
                },
                child: const Text("oui"),
              ),
            ],
          );
        },
      );
    },
  );
}