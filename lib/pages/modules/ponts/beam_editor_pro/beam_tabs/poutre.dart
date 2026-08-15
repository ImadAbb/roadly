import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/drawings/beam_drawing.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/widgets_beam_editor_pro/numeric_keypad.dart';

class PoutreTab extends StatefulWidget {
  const PoutreTab({super.key});

  @override
  State<PoutreTab> createState() => _PoutreTabState();
}

class _PoutreTabState extends State<PoutreTab> {
  double beamLength = 10.0;
  late TextEditingController beamLenghtController;
  late FocusNode _focusNode;

  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    beamLenghtController = TextEditingController(text: beamLength.toString());
    _focusNode = FocusNode();

    // Seul setState nécessaire : il pilote l'affichage clavier <-> dessin.
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    beamLenghtController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Seul endroit où beamLength change : le bouton "Appliquer".
  void _applyLength() {
    final parsed = double.tryParse(beamLenghtController.text.replaceAll(',', '.'));
    if (parsed != null && parsed > 0) {
      setState(() => beamLength = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 35,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.black, width: 2),
              ),
              height: double.infinity,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      "Poutre",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("L"),
                        const SizedBox(width: 24),
                        Expanded(
                          child: TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                            ],
                            controller: beamLenghtController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.none,
                            // groupId : regroupe ce champ avec le clavier
                            // custom (même groupId), pour qu'un tap sur une
                            // touche ne soit pas vu comme "outside".
                            groupId: RoadlyNumericKeypad.groupId,
                            onTapOutside: (event) {
                              FocusScope.of(context).unfocus();
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              suffixText: "m",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: _applyLength,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        child: const Center(
                          child: Text(
                            "Appliquer",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          flex: 65,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _hasFocus
                    ? RoadlyNumericKeypad(controller: beamLenghtController)
                    : BeamDrawing(beamLength: beamLength),
              ),
            ),
          ),
        ),
      ],
    );
  }
}