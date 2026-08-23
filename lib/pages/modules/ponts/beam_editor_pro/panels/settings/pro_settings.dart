import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/core/models/beam_classes.dart';

import 'sections/interface_settings.dart';
import 'sections/profile_settings.dart';
import 'sections/unit_settings.dart';
import 'sections/project_settings.dart';

class ProSettings extends StatelessWidget {
  final Beam beam;
  final VoidCallback onBeamChanged;
  const ProSettings({super.key, required this.beam, required this.onBeamChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 320,
      backgroundColor: const Color(0xFFF7F9FC),
      child: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                InterfaceSettings(),

                SizedBox(height: 24),

                ProfileSettings(beam: beam, onBeamChanged: onBeamChanged),

                SizedBox(height: 24),

                UnitSettings(),

                SizedBox(height: 24),

                ProjectSettings(),
              ],
            ),
          ),

          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 18, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFE9EEF7),
        border: Border(bottom: BorderSide(color: Color(0xFFD7DFEC))),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Réglages",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Configuration de Beamy",
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFD7DFEC))),
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: Color(0xFF22C55E)),

          SizedBox(width: 8),

          Text(
            "Beamy Pro",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),

          Spacer(),

          Text(
            "v1.0",
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
