import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_v1/control_pannel/pannel_view.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_v1/editeur_de_poutre/structure/classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_v1/editeur_de_poutre/structure/drawing.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_v1/right_pannel/main_right_pannel.dart';

class ModulePonts extends StatefulWidget {
  const ModulePonts({super.key});

  @override
  State<ModulePonts> createState() => _ModulePontsState();
}

class _ModulePontsState extends State<ModulePonts> {
  late Beam beam;

  @override
  void initState() {
    super.initState();
    // Forcer le mode paysage
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Création d'une poutre avec données
    beam = Beam(10.0);
    beam.addSupport(Support(0.0, SupportType.encastrement));
    beam.addSupport(Support(10.0, SupportType.simple));
    beam.addLoad(PointLoad(5.0, 20.0));
    beam.addLoad(DistributedLoad(2.0, 8.0, 5.0));
  }

  @override
  void dispose() {
    // Rétablir orientation portrait par défaut
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // ✅ Padding adaptatif
    double basePadding = isLandscape ? 32 : 16;

    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 203, 203),
        elevation: 0,
        toolbarHeight: 30,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset('lib/assets/images/r.png', height: 20, cacheHeight: 25),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ROADLY',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  'PONTS',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            const Text(
              "STRUCTURAL ANALYSIS",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: EdgeInsets.only(
          left: safePadding.left > 0 ? basePadding + 8 : basePadding,
          right: safePadding.right > 0 ? basePadding + 8 : basePadding,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Expanded(
                    child: MyControlPannel(
                      beam: beam,
                      onUpdate: () => setState(() {}),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 16),
                  BeamWidget(beam: beam),
                  SizedBox(
                    height: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'L: ${beam.length}m',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'Appuis: ${beam.supports.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'Charges: ${beam.loads.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            SizedBox(width: 300, child: MainRightPannel(beam: beam)),
          ],
        ),
      ),
    );
  }
}
