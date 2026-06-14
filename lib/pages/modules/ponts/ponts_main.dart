import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadly/pages/modules/ponts/control_pannel/pannel_view.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/classes.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/drawing.dart';
import 'package:roadly/pages/modules/ponts/right_pannel/main_right_pannel.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      // ✅ AppBar propre
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 203, 203),
        elevation: 0,
        toolbarHeight: 30,
        automaticallyImplyLeading:
            false,
        titleSpacing: 12,
        title: Row(
          children: [
            // Logo
            Image.asset(
              'lib/assets/images/r.png',
              height: 20,
              cacheHeight: 20,
            ),
            const SizedBox(width: 8),

            // Texte ROADLY + PONTS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ROADLY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'PONTS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const Spacer(),

            const Text(
              "STRUCTURAL ANALYSIS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),

      // ✅ Contenu principal
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ), // 👈 padding latéral
        child: Row(
          children: [
            // Panel de contrôle à gauche
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Expanded(
                    child: MyControlPannel(
                      beam: beam,
                      onUpdate: () {
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Contenu principal au centre
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
