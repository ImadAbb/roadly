import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/beam_supports/support_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/drawings/beam_drawing.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/widgets_beam_editor_pro/numeric_keypad.dart';

class PoutreTab extends StatefulWidget {
  final double beamLength;
  final ValueChanged<double> onBeamLengthChanged;
  final int supportCount;
  final List<BeamSupport> supports;

  const PoutreTab({
    super.key,
    required this.beamLength,
    required this.onBeamLengthChanged,
    required this.supportCount,
    required this.supports,
  });

  @override
  State<PoutreTab> createState() => _PoutreTabState();
}

class _PoutreTabState extends State<PoutreTab> {
  int loadNumber = 1;
  late TextEditingController beamLenghtController;
  late FocusNode _focusNode;

  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    beamLenghtController = TextEditingController(
      text: widget.beamLength.toString(),
    );
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(covariant PoutreTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.beamLength != widget.beamLength &&
        beamLenghtController.text != widget.beamLength.toString()) {
      beamLenghtController.text = widget.beamLength.toString();
    }
  }

  @override
  void dispose() {
    beamLenghtController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _applyLength() {
    final parsed = double.tryParse(
      beamLenghtController.text.replaceAll(',', '.'),
    );
    if (parsed != null && parsed > 0) {
      widget.onBeamLengthChanged(parsed);
      setState(() {
      for (int i = 0; i < widget.supports.length; i++) {
        final support = widget.supports[i];
        if (support.type == SupportType.encastrement) {
          widget.supports[i] = BeamSupport(
            id: support.id,
            type: SupportType.encastrement,
            encastrementSide: support.encastrementSide,
            position: support.encastrementSide == true ? parsed : 0,
          );
        }
      }
    });
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
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

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Nombre d'appuis: ${widget.supportCount}"),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Nombre de charges: $loadNumber"),
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
                padding: const EdgeInsets.all(24.0),
                child: _hasFocus
                    ? RoadlyNumericKeypad(controller: beamLenghtController)
                    : BeamDrawing(
                        beamLength: widget.beamLength,
                        supports: widget.supports,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
