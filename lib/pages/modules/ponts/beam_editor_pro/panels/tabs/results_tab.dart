import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/core/models/beam_classes.dart';

import '../../widgets/tab_widgets/pro_efforts_max_card.dart';
import '../../widgets/tab_widgets/pro_tab_scaffold.dart';

class ResultsTab extends StatefulWidget {
  final Beam beam;

  const ResultsTab({super.key, required this.beam});

  @override
  State<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  @override
  Widget build(BuildContext context) {
    return ProTabScaffold(
      title: "Résultats",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Les efforts maximals sont:",
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 12),

            ProMaxEffortsCard(
              momentMaxPositive: 25.40,
              momentMaxNegative: -18.20,
              shearMaxPositive: 12.60,
              shearMaxNegative: -9.80,
              momentMaxPositivePos: 10,
              momentMaxNegativePos: 5,
              shearMaxPositivePos: 0,
              shearMaxNegativePos: 7,
            ),
          ],
        ),
      ),
    );
  }
}
