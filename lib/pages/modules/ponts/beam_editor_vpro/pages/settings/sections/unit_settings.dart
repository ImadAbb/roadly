import 'package:flutter/material.dart';


import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/settings_widgets/section_title.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/settings_widgets/settings_container.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/settings_widgets/unit_option.dart';

class UnitSettings extends StatefulWidget {
  const UnitSettings({super.key});

  @override
  State<UnitSettings> createState() => _UnitSettingsState();
}

class _UnitSettingsState extends State<UnitSettings> {
  String selectedUnit = "m";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: "UNITÉS",
        ),

        const SizedBox(height: 8),

        SettingsContainer(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE5F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.straighten_rounded,
                size: 20,
                color: Color(0xFF526174),
              ),
            ),
            title: const Text(
              "Unité de mesure",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              selectedUnit == "m"
                  ? "Mètres (m)"
                  : "Centimètres (cm)",
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
            onTap: _showUnitDialog,
          ),
        ),
      ],
    );
  }

  void _showUnitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Unité de mesure",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UnitOption(
                title: "Mètres",
                subtitle: "m",
                value: "m",
                selectedUnit: selectedUnit,
                onSelected: () {
                  setState(() {
                    selectedUnit = "m";
                  });

                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 8),

              UnitOption(
                title: "Centimètres",
                subtitle: "cm",
                value: "cm",
                selectedUnit: selectedUnit,
                onSelected: () {
                  setState(() {
                    selectedUnit = "cm";
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}