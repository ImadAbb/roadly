import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/pages/settings/providers/interface_settings_provider.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/settings_widgets/section_title.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/settings_widgets/settings_container.dart';

class InterfaceSettings extends StatelessWidget {
  const InterfaceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<InterfaceSettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "INTERFACE"),
        const SizedBox(height: 8),
        SettingsContainer(
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            value: settings.afficherValeursCharges,
            onChanged: (value) {
              context.read<InterfaceSettingsProvider>().setAfficherValeursCharges(value);
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
              "Charges",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: const Text(
              "Afficher les valeurs des charges sur le diagramme",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            activeThumbColor: const Color(0xFF2563EB),
          ),
        ),

        const SizedBox(height: 8),

        SettingsContainer(
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            value: settings.afficherCotations,
            onChanged: (value) {
              context.read<InterfaceSettingsProvider>().setAfficherCotations(value);
            },
            secondary: Container(
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
              "Cotation",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: const Text(
              "Afficher les cotations sur le diagramme",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            activeThumbColor: const Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }
}