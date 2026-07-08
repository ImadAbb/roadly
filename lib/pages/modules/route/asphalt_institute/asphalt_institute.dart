import 'package:flutter/material.dart';
import 'package:roadly/assets/widgets/build_field.dart';
import 'package:roadly/pages/modules/route/asphalt_institute/asphalt_data.dart';
import 'package:roadly/pages/modules/route/asphalt_institute/asphalt_results.dart';
import 'package:roadly/pages/modules/route/route_widgets/fade_transitions.dart';
import 'package:roadly/pages/modules/route/route_widgets/from_field_config.dart';
import 'package:roadly/pages/modules/route/route_widgets/group_container.dart';
import 'package:roadly/pages/modules/route/route_widgets/info_banner.dart';
import 'package:roadly/pages/modules/route/asphalt_institute/asphalt_widgets/pl_traffic_table.dart';

class AsphaltInstute extends StatefulWidget {
  const AsphaltInstute({super.key});

  @override
  State<AsphaltInstute> createState() => _AsphaltInstuteState();
}

class _AsphaltInstuteState extends State<AsphaltInstute>
    with SingleTickerProviderStateMixin {
  List<PLData> poidsLourds = [
    PLData(pourcentage: "43", essieuxSimples: "7", essieuxTandems: "14"),
    PLData(pourcentage: "35", essieuxSimples: "12", essieuxTandems: "18"),
    PLData(pourcentage: "22", essieuxSimples: "16", essieuxTandems: "24"),
  ];
  final TextEditingController tjmaController = TextEditingController();

  late final List<FieldGroup> fieldGroups;
  int _selectedIndex = 0;

  late FocusNode fullscreenFocusNode;
  late AnimationController _blinkController;

  void _openTrafficTableEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // permet d'occuper plus d'espace
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // gère clavier
          ),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.8, // hauteur fixe (80%)
            child: PLTrafficTable(
              data: poidsLourds,
              onSave: (newData) {
                setState(() {
                  poidsLourds = newData;
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
      fullscreenFocusNode = FocusNode();

  _blinkController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: 1.0, // ✅ commence visible
  );

  fullscreenFocusNode.addListener(() {
    if (fullscreenFocusNode.hasFocus) {
      _blinkController.repeat(reverse: true, count: 6); // 3 cycles complets
    } else {
      _blinkController.stop();
      _blinkController.value = 1.0; // remet opacité à 100%
    }
  });

  // 🔹 quand l’animation finit ses cycles
  _blinkController.addStatusListener((status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _blinkController.value = 1.0; // ✅ remet visible
    }
  });

    fieldGroups = [
      FieldGroup(
        title: "Détermination du trafic",
        icon: Icons.settings,
        fields: [
          FormFieldConfig(
            label: "Trafic à la première année de mise en service",
            icon: Icons.directions_car,
            controller: tjmaController,
            focusNode: FocusNode(),
          ),
        ],
      ),

      FieldGroup(
        title: "Données du trafic",
        icon: Icons.directions_car,
        fields: [
          FormFieldConfig(
            label: "Année De Comptage",
            icon: Icons.calendar_month,
            controller: TextEditingController(),
            focusNode: FocusNode(),
          ),
          FormFieldConfig(
            label: "TJMA à l'année de comptage",
            icon: Icons.directions_car,
            controller: TextEditingController(),
            focusNode: FocusNode(),
          ),
          FormFieldConfig(
            label: "Proportion de poids Lourds (%)",
            icon: Icons.local_shipping,
            controller: TextEditingController(),
            focusNode: FocusNode(),
          ),
        ],
      ),
    ];

    final flatList = fieldGroups.expand((g) => g.fields).toList();
    for (int i = 0; i < flatList.length - 1; i++) {
      flatList[i].nextFocus = flatList[i + 1].focusNode;
    }
    for (var f in flatList) {
      if (f.label == "Trafic à la première année de mise en service") {
        f.nextFocus = fullscreenFocusNode;
      }
    }
  }

  @override
  void dispose() {
    fullscreenFocusNode.dispose();
    _blinkController.dispose();

    for (var group in fieldGroups) {
      for (var f in group.fields) {
        f.controller.dispose();
        f.focusNode.dispose();
      }
    }
    super.dispose();
  }

  Widget _buildFormContent() {
    return FadeInWrapper(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpandableInfoBanner(
              message:
                  "La méthode de dimensionnement des chaussées proposée par l'Asphalt Institute est basée sur les résultats des essais réalisés dans le cadre du programme AASHO (American Association of State Highway Officials).\n \n"
                  "Elle a été développée afin de remédier à certaines limites observées dans les méthodes de dimensionnement reposant uniquement sur l'indice CBR.",
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calculate, color: Colors.black, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Méthode d'Asphalt Institute",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "Données du projet",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 24),

            //  Génération automatique des GroupContainer
            Column(
              children: fieldGroups.map((group) {
                return Column(
                  children: [
                    GroupContainer(
                      title: group.title,
                      icon: group.icon,
                      content: Column(
                        children: [
                          // 🔹 Affichage des champs
                          ...group.fields.map((f) {
                            return BuildField(
                              controller: f.controller,
                              focusNode: f.focusNode,
                              nextFocus: f.nextFocus,
                              label: f.label,
                              icon: f.icon,
                              // tu peux ajouter un onChanged pour mettre à jour le tableau
                              //onChanged: (_) => setState(() {}),
                            );
                          }),

                          // 🔹 Si c’est le premier groupe, on ajoute un tableau juste en dessous
                          if (group.title == "Détermination du trafic") ...[
                            const SizedBox(height: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Répartition du trafic Poids Lours",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Spacer(),

                                    Focus(
                                      focusNode: fullscreenFocusNode,
                                      child: FadeTransition(
                                        opacity: _blinkController,
                                        child: InkWell(
                                          onTap: _openTrafficTableEditor,
                                          child: const Icon(
                                            Icons.fullscreen,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  child: PLNormalTable(data: poidsLourds),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: const Icon(Icons.check_circle, size: 20),
                label: const Text("Valider et voir les résultats"),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _selectedIndex == 0
              ? Scrollbar(
                  child: SingleChildScrollView(child: _buildFormContent()),
                )
              : AsphaltResults(
                  //results: _results
                ),
        ),
        BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: "Formulaire",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Résultats",
            ),
          ],
          elevation: 0,
        ),
      ],
    );
  }
}
