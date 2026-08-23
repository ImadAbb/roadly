import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/canvas/beam_diagram.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/core/models/beam_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/panels/settings/pro_settings.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/panels/tabs/pro_tabs.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/state/interface_settings_provider.dart';

class BeamEditorPro extends StatefulWidget {
  const BeamEditorPro({super.key});

  @override
  State<BeamEditorPro> createState() => _BeamEditorProState();
}

class _BeamEditorProState extends State<BeamEditorPro> {
  late Beam beam;

  @override
  void initState() {
    super.initState();
    beam = Beam(beamLenght: 10.00);
  }

  void _onBeamChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InterfaceSettingsProvider(),
      child: Scaffold(
        endDrawer: ProSettings(beam: beam, onBeamChanged: _onBeamChanged),

        appBar: AppBar(
          iconTheme: const IconThemeData(color: Color(0xFFDCE5F3)),

          toolbarHeight: 48,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: const Color.fromARGB(255, 83, 113, 212),
          titleSpacing: 16,

          title: const Text(
            "Beamy",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          centerTitle: true,

          actions: [
            Builder(
              builder: (context) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE5F3),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: const Color(0xFFC9D5E8)),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.settings_rounded,
                    size: 18,
                    color: Color(0xFF526174),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ),
          ],
        ),

        body: Row(
          children: [
            Expanded(
              flex: 30,
              child: ProTabs(beam: beam, onBeamChanged: _onBeamChanged),
            ),

            Expanded(flex: 70, child: BeamDiagram(beam: beam)),
          ],
        ),
      ),
    );
  }
}
