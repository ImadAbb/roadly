import 'package:flutter/material.dart';
import 'package:roadly/assets/widgets/build_field.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_checkinput.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_model.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_result.dart';
import 'package:roadly/pages/modules/route/route_widgets/from_field_config.dart';
import 'package:roadly/pages/modules/route/route_widgets/group_container.dart';
import 'package:roadly/pages/modules/route/route_widgets/info_banner.dart';
import 'package:roadly/pages/modules/route/route_widgets/fade_transitions.dart';

class CBR extends StatefulWidget {
  final void Function(CBRResults results)? onValidated;

  const CBR({super.key, this.onValidated});

  @override
  State<CBR> createState() => _CBRState();
}

class _CBRState extends State<CBR> {
  // 🔹 Contrôleurs nommés
  final anneeController = TextEditingController();
  final tjmaController = TextEditingController();
  final plController = TextEditingController();
  final anneeMiseEnServiceController = TextEditingController();
  final tauxAccroissementController = TextEditingController();
  final dureeDeVieController = TextEditingController();
  final icbrController = TextEditingController();

  late final List<FieldGroup> fieldGroups;
  String? selectedValue;

  int _selectedIndex = 0;
  CBRResults? _results;

  final List<String> options = [
    "Chaussée unidirectionnelle à 2 voies",
    "Chaussée unidirectionnelle à 3 voies",
    "Chaussée bidirectionnelle à 2 voies",
    "Chaussée bidirectionnelle à 3 voies",
  ];

  @override
  void initState() {
    super.initState();

    fieldGroups = [
      FieldGroup(
        title: "Données du trafic",
        icon: Icons.directions_car,
        fields: [
          FormFieldConfig(
            label: "Année De Comptage",
            icon: Icons.calendar_month,
            controller: anneeController,
            focusNode: FocusNode(),
          ),
          FormFieldConfig(
            label: "TJMA à l'année de comptage",
            icon: Icons.directions_car,
            controller: tjmaController,
            focusNode: FocusNode(),
          ),
          FormFieldConfig(
            label: "Proportion de poids Lourds (%)",
            icon: Icons.local_shipping,
            controller: plController,
            focusNode: FocusNode(),
          ),
        ],
      ),
      FieldGroup(
        title: "Données techniques",
        icon: Icons.settings,
        fields: [
          FormFieldConfig(
            label: "Année De Mise En Service",
            icon: Icons.engineering,
            controller: anneeMiseEnServiceController,
            focusNode: FocusNode(),
          ),
          FormFieldConfig(
            label: "Taux d'accroissement annuel du trafic (%)",
            icon: Icons.trending_up,
            controller: tauxAccroissementController,
            focusNode: FocusNode(),
          ),
          FormFieldConfig(
            label: "Durée de vie de la chaussée (années)",
            icon: Icons.schedule,
            controller: dureeDeVieController,
            focusNode: FocusNode(),
          ),
        ],
      ),
      FieldGroup(
        title: "Données du sol",
        icon: Icons.landscape,
        fields: [
          FormFieldConfig(
            label: "Indice Portant Californien du sol support (ICBR)",
            icon: Icons.landscape,
            controller: icbrController,
            focusNode: FocusNode(),
          ),
        ],
      ),
    ];

    // 🔹 Relier tous les nextFocus en aplatissant
    final flatList = fieldGroups
        .expand((g) => g.fields.whereType<FormFieldConfig>())
        .toList();
    for (int i = 0; i < flatList.length - 1; i++) {
      flatList[i].nextFocus = flatList[i + 1].focusNode;
    }
  }

  @override
  void dispose() {
    anneeController.dispose();
    tjmaController.dispose();
    plController.dispose();
    anneeMiseEnServiceController.dispose();
    tauxAccroissementController.dispose();
    dureeDeVieController.dispose();
    icbrController.dispose();

    for (var group in fieldGroups) {
      for (var f in group.fields.whereType<FormFieldConfig>()) {
        f.focusNode.dispose();
      }
    }
    super.dispose();
  }

  void _handleValidated(CBRResults results) {
    setState(() {
      _results = results;
      _selectedIndex = 1;
    });
    widget.onValidated?.call(results);
  }

  Widget _buildFormContent() {
    return FadeInWrapper(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InfoBanner(
              message:
                  "La méthode CBR permet de déterminer l'épaisseur d'une chaussée à partir du trafic et de la portance du sol.",
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calculate, color: Colors.black, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Méthode CBR",
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

            // Groupe 1 : Type de voies
            GroupContainer(
              title: "Type de voies",
              icon: Icons.route,
              content: DropdownButtonFormField<String>(
                initialValue: selectedValue,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.alt_route),
                  contentPadding: EdgeInsets.all(16),
                ),
                items: options.map((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
                dropdownColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Génération automatique des GroupContainer
            Column(
              children: fieldGroups.map((group) {
                return Column(
                  children: [
                            GroupContainer(
                      title: group.title,
                      icon: group.icon,
                      content: Column(
                        children: group.fields.whereType<FormFieldConfig>().map((f) {
                          return BuildField(
                            controller: f.controller,
                            focusNode: f.focusNode,
                            nextFocus: f.nextFocus,
                            label: f.label,
                            icon: f.icon,
                          );
                        }).toList(),
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
                  checkInputAndValidate(
                    context: context,
                    anneeComptage: anneeController.text,
                    tjmaMin: tjmaController.text,
                    pl: plController.text,
                    anneeMiseEnService: anneeMiseEnServiceController.text,
                    tauxAccroissement: tauxAccroissementController.text,
                    dureeDeVie: dureeDeVieController.text,
                    iCBR: icbrController.text,
                    selectedValue: selectedValue,
                    onValidated: _handleValidated,
                  );
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
              : ResultPageCbr(results: _results),
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
