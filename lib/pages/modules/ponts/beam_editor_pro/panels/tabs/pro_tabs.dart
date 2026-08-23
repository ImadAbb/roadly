import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/beam.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/theme/pro_colors.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/panels/tabs/tab_options_widget.dart';

import 'beam_tab.dart';
import 'loads_tab.dart';
import 'results_tab.dart';
import 'supports_tab.dart';

class ProTabs extends StatefulWidget {
  final Beam beam;
  final VoidCallback onBeamChanged;

  const ProTabs({super.key, required this.beam, required this.onBeamChanged});

  @override
  State<ProTabs> createState() => _ProTabsState();
}

class _ProTabsState extends State<ProTabs> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BeamTab(beam: widget.beam, onBeamChanged: widget.onBeamChanged),

      SupportsTab(beam: widget.beam, onBeamChanged: widget.onBeamChanged),

      LoadsTab(beam: widget.beam, onBeamChanged: widget.onBeamChanged),

      ResultsTab(beam: widget.beam),
    ];

    return Scaffold(
      backgroundColor: ProColors.secondaryBackgroundColor,

      body: Column(
        children: [
          TabOptionsWidget(
            options: const ["Poutre", "Appuis", "Charges", "Résultats"],

            icons: const [
              Icons.architecture_rounded,
              Icons.expand_circle_down_rounded,
              Icons.vertical_align_bottom_rounded,
              Icons.analytics_rounded,
            ],

            onTabSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: IndexedStack(index: selectedIndex, children: pages),
          ),
        ],
      ),
    );
  }
}
