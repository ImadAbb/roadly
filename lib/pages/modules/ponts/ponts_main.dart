import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/control_pannel/pannel_view.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/classes.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/drawing.dart';

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
    // Création d'une poutre avec données
    beam = Beam(10.0);
    beam.addSupport(Support(0.0, SupportType.encastrement));
    beam.addSupport(Support(10.0, SupportType.simple));
    beam.addLoad(PointLoad(5.0, 20.0));
    beam.addLoad(DistributedLoad(2.0, 8.0, 5.0));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Module Ponts")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                children: [
                  const Text("Structurez votre poutre"),
                  const SizedBox(height: 20),
                  // Ici on affiche la poutre
                  BeamWidget(beam: beam),

                  const SizedBox(height: 20,),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Longueur de la poutre :",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${beam.length} m")
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Supports :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...beam.supports.map(
                        (t) => Text("Support à ${t.x} m, type: ${t.type.name}"),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Charges :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...beam.loads.map((l) {
                        if (l is PointLoad) {
                          return Text(
                            "Charge ponctuelle à ${l.x} m, valeur: ${l.value} kN",
                          );
                        } else if (l is DistributedLoad) {
                          return Text(
                            "Charge répartie de ${l.x} à ${l.xEnd} m, valeur: ${l.value} kN/m",
                          );
                        }
                        return const Text("Charge inconnue");
                      }),
                    ],
                  )

                ],
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: MyControlPannel(
                  beam: beam,
                  onUpdate: () {
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
