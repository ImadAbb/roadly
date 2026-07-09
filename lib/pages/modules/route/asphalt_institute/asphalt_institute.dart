import 'package:flutter/material.dart';
import 'package:roadly/assets/widgets/build_field.dart';
import 'package:roadly/pages/modules/route/asphalt_institute/asphalt_results.dart';
import 'package:roadly/pages/modules/route/route_widgets/fade_transitions.dart';
import 'package:roadly/pages/modules/route/route_widgets/from_field_config.dart';
import 'package:roadly/pages/modules/route/route_widgets/group_container.dart';
import 'package:roadly/pages/modules/route/route_widgets/table_data.dart';
import 'package:roadly/pages/modules/route/route_widgets/info_banner.dart';

class AsphaltInstute extends StatefulWidget {
  const AsphaltInstute({super.key});

  @override
  State<AsphaltInstute> createState() => _AsphaltInstuteState();
}

class _AsphaltInstuteState extends State<AsphaltInstute>
    with SingleTickerProviderStateMixin {
        String? selectedValue;

//final Controller & Strings
      final List<String> options = [
    "Chaussée unidirectionnelle à 2 voies",
    "Chaussée unidirectionnelle à 3 voies",
    "Chaussée bidirectionnelle à 2 voies",
    "Chaussée bidirectionnelle à 3 voies",
  ];
  final TextEditingController tjmaController = TextEditingController();
  final TextEditingController anneeMiseEnServiceController = TextEditingController();
  final TextEditingController tauxAccroissementController = TextEditingController();
  final TextEditingController dureeDeVieController = TextEditingController();
  final TextEditingController icbrController = TextEditingController();

  final TableFieldController _plTrafficController = TableFieldController(
    initialRows: [
      ["43", "7", "14"],
      ["35", "12", "18"],
      ["22", "16", "24"],
    ],
  );

  late final List<FieldGroup> fieldGroups;
  int _selectedIndex = 0;

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
            controller: TextEditingController(),
            focusNode: FocusNode(),
          ),
          FormFieldConfig(
            label: "TJMA à l'année de comptage",
            icon: Icons.directions_car,
            controller: TextEditingController(),
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
        title: "Détermination du trafic Poids Lourds",
        icon: Icons.settings,
        fields: [
          FormFieldConfig(
            label: "Proportion de poids Lourds (%)",
            icon: Icons.local_shipping,
            controller: TextEditingController(),
            focusNode: FocusNode(),
          ),
          TableFieldConfig(
            label: "Répartition du trafic Poids Lourds",
            columns: const ["Pourcentage", "Essieux simples", "Essieux tandems"],
            suffixes: const ["%", "", ""],
            controller: _plTrafficController,
            onChanged: (rows) {
              // les données peuvent être utilisées ultérieurement via _plTrafficController.rows
            },
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

    final focusables = fieldGroups
        .expand((g) => g.fields)
        .where((field) => field is FormFieldConfig || field is TableFieldConfig)
        .toList();

    for (int i = 0; i < focusables.length - 1; i++) {
      final nextFocusNode = (focusables[i + 1] as dynamic).focusNode as FocusNode;
      if (focusables[i] is FormFieldConfig) {
        (focusables[i] as FormFieldConfig).nextFocus = nextFocusNode;
      }
    }
  }

  @override
  void dispose() {
    for (var group in fieldGroups) {
      for (var f in group.fields) {
        if (f is FormFieldConfig) {
          f.controller.dispose();
          f.focusNode.dispose();
        } else if (f is TableFieldConfig) {
          f.focusNode.dispose();
        }
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

            //  Génération automatique des GroupContainer
            Column(
              children:
              fieldGroups.map((group) {
                return Column(
                  children: [
                    GroupContainer(
                      title: group.title,
                      icon: group.icon,
                      content: Column(
                        children: [
                          // 🔹 Affichage des champs et des widgets du groupe
                          ...group.fields.map((fieldItem) {
                            if (fieldItem is FormFieldConfig) {
                              return BuildField(
                                controller: fieldItem.controller,
                                focusNode: fieldItem.focusNode,
                                nextFocus: fieldItem.nextFocus,
                                label: fieldItem.label,
                                icon: fieldItem.icon,
                              );
                            }

                            if (fieldItem is TableFieldConfig) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  fieldItem.build(context),
                                ],
                              );
                            }

                            return const SizedBox.shrink();
                          }),
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
              : AsphaltResults(onBackToForm: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
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
