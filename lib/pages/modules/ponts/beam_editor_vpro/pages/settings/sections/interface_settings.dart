import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/settings_widgets/section_title.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/settings_widgets/settings_container.dart';


class InterfaceSettings extends StatefulWidget {
  const InterfaceSettings({super.key});

  @override
  State<InterfaceSettings> createState() => _InterfaceSettingsState();
}

class _InterfaceSettingsState extends State<InterfaceSettings> {
  bool integratedKeyboard = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: "INTERFACE",
        ),

        const SizedBox(height: 8),

        SettingsContainer(
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            value: integratedKeyboard,
            onChanged: (value) {
              setState(() {
                integratedKeyboard = value;
              });
            },
            secondary: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE5F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.keyboard_rounded,
                size: 20,
                color: Color(0xFF526174),
              ),
            ),
            title: const Text(
              "Clavier intégré",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: const Text(
              "Afficher le clavier virtuel",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            activeThumbColor: Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }
}