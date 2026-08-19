import 'package:flutter/material.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_vpro/models/beam_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/tab_widgets/pro_card.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/tab_widgets/pro_info_row.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/tab_widgets/pro_tab_scaffold.dart';

class BeamTab extends StatefulWidget {
  final Beam beam;
  final VoidCallback onBeamChanged;

  const BeamTab({super.key, required this.beam, required this.onBeamChanged});

  @override
  State<BeamTab> createState() => _BeamTabState();
}

class _BeamTabState extends State<BeamTab> {
  @override
  Widget build(BuildContext context) {
    return ProTabScaffold(
      title: "Poutre",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informations générales",
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 12),

            ProCard(
              child: Row(
                children: [
                  Expanded(
                    child: ProInfoRow(
                      label: "Longueur",
                      value: "${widget.beam.beamLenght.toStringAsFixed(2)} m",
                    ),
                  ),

                  IconButton(
                    onPressed: _showLengthEditor,
                    tooltip: "Modifier la longueur",
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 7),

            ProCard(
              child: ProInfoRow(
                label: "Appuis",
                value: "${widget.beam.supports.length}",
              ),
            ),

            const SizedBox(height: 7),

            ProCard(
              child: ProInfoRow(
                label: "Charges",
                value: "${widget.beam.loads.length}",
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLengthEditor() {
    final controller = TextEditingController(
      text: widget.beam.beamLenght.toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITRE
              const Text(
                "Modifier la poutre",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Définissez la longueur totale de la poutre.",
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 20),

              // CHAMP
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Longueur",
                  suffixText: "m",
                  filled: true,
                  fillColor: const Color(0xFFF7F9FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E7F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E7F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: const BorderSide(color: Color(0xFFE1E7F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final value = double.tryParse(
                          controller.text.replaceAll(',', '.'),
                        );

                        if (value == null || value <= 0) {
                          return;
                        }

                        setState(() {
                          widget.beam.updateBeamLength(value);
                        });

                        widget.onBeamChanged();

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Appliquer",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
