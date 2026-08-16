import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/beam_supports/support_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/beam_tabs/appuis.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/beam_tabs/charges.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/beam_tabs/poutre.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/beam_tabs/resultats.dart';

class BeamEditorPro extends StatefulWidget {
  const BeamEditorPro({super.key});

  @override
  State<BeamEditorPro> createState() => _BeamEditorProState();
}

class _BeamEditorProState extends State<BeamEditorPro> {
  String selectedTab = "Poutre";
  double beamLength = 10.0;
  final List<BeamSupport> supports = [];

  void _updateBeamLength(double value) {
    if (!mounted || value <= 0) return;
    setState(() => beamLength = value);
  }

  void _addSupport(BeamSupport support) {
    if (!mounted) return;
    setState(() => supports.add(support));
  }

  Widget _buildTabButton(String label) {
    final bool isSelected = selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = label),
        child: Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade300 : Colors.grey.shade200,
            border: Border.all(
              color: isSelected ? Colors.black : Colors.black26,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedTab) {
      case "Poutre":
        return PoutreTab(
          beamLength: beamLength,
          onBeamLengthChanged: _updateBeamLength,
          supportCount: supports.length,
          supports: supports,
        );
      case "Appuis":
        return AppuisTab(
          beamLength: beamLength,
          supports: supports,
          onSupportAdded: _addSupport,
        );
      case "Charges":
        return Chargestab(beamLength: beamLength);
      case "Résultats":
        return ResultatsTab(beamLength: beamLength);
      default:
        return const Placeholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onDoubleTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 50,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              _buildTabButton("Poutre"),
              _buildTabButton("Appuis"),
              _buildTabButton("Charges"),
              _buildTabButton("Résultats"),
            ],
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}
