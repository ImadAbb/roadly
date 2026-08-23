import 'package:flutter/material.dart';


import 'package:roadly/pages/modules/ponts/beam_editor_pro/widgets/settings_widgets/section_title.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/widgets/settings_widgets/settings_container.dart';

class ProjectSettings extends StatelessWidget {
  const ProjectSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: "PROJET",
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
                Icons.info_outline_rounded,
                size: 20,
                color: Color(0xFF526174),
              ),
            ),
            title: const Text(
              "À propos de Beamy",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: const Text(
              "Version Pro",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}