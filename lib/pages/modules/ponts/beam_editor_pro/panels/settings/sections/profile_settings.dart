import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/beam.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/load.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/support.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/widgets/settings_widgets/profile_option.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/widgets/settings_widgets/section_title.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/widgets/settings_widgets/settings_container.dart';

class ProfileSettings extends StatelessWidget {
  final Beam beam;
  final VoidCallback onBeamChanged;
  const ProfileSettings({
    super.key,
    required this.beam,
    required this.onBeamChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "PROFILS"),

        const SizedBox(height: 8),

        SettingsContainer(
          child: Column(
            children: [
              ProfileOption(
                icon: Icons.account_tree_rounded,
                title: "Poutre simplement appuyée",
                subtitle: "10 m • 2 appuis • charge à 5 m",
                onTap: () {
                  loadSimpleBeam();
                },
              ),

              const Divider(
                height: 1,
                indent: 64,
                endIndent: 12,
                color: Color(0xFFE8EDF4),
              ),

              ProfileOption(
                icon: Icons.horizontal_rule_rounded,
                title: "Poutre vide",
                subtitle: "10 m • sans appuis • sans charges",
                onTap: () {
                  clearBeam();
                },
              ),

              const Divider(
                height: 1,
                indent: 64,
                endIndent: 12,
                color: Color(0xFFE8EDF4),
              ),

              ProfileOption(
                icon: Icons.work_history_rounded,
                title: "Poutre remplie",
                subtitle: "10 m • 4 appuis • 2 charges",
                onTap: () {
                  loadFullBeam();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void loadSimpleBeam() {
    clearBeam();

    beam.addSupport(
      Support(id: "support_left", position: 0, type: SupportType.double_),
    );

    beam.addSupport(
      Support(id: "support_right", position: 10, type: SupportType.simple_),
    );

    beam.addLoad(PointLoad("load_1", 5, 10));

    onBeamChanged();
  }

  void loadFullBeam() {
    clearBeamData();
    beam.beamLength = 10;

    beam.addSupport(
      Support(id: "support_left", position: 0, type: SupportType.double_),
    );

    beam.addSupport(
      Support(id: "support_right", position: 8, type: SupportType.simple_),
    );

    beam.addSupport(
      Support(id: "support_super", position: beam.beamLength, type: SupportType.encastrement_, isEncastrementRightSide: true),
    );

    beam.addSupport(
      Support(id: "support_inf", position: 4, type: SupportType.rotule_),
    );

    beam.addLoad(PointLoad("load_1", 5, 10));

    beam.addLoad(DistributedLoad("load_2", 2, 8, 5));

    beam.addLoad(MomentLoad("load_3", 2, 10));

    onBeamChanged();
  }

  void clearBeam() {
    beam.beamLength = 10;

    clearBeamData();

    onBeamChanged();
  }

  void clearBeamData() {
    beam.supports.clear();
    beam.loads.clear();
  }
}
