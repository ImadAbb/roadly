import 'package:flutter/material.dart';
import 'dart:math';
import 'package:roadly/componets/button.dart';

class CBRRoute extends StatefulWidget {
  final ScrollController scrollController;

  const CBRRoute({super.key, required this.scrollController});

  @override
  State<CBRRoute> createState() => _CBRRouteState();
}

class _CBRRouteState extends State<CBRRoute> {
  int _selectedIndex = 0;
  CBRResults? results;

  void _onValidated(CBRResults validatedResults) {
    setState(() {
      results = validatedResults;
      _selectedIndex = 1;
    });

    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              SingleChildScrollView(child: CBR(onValidated: _onValidated)),
              SingleChildScrollView(child: ResultPage(results: results)),
            ],
          ),
        ),
        BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            widget.scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Formulaire',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stacked_bar_chart),
              label: 'Résultats',
            ),
          ],
        ),
      ],
    );
  }
}

class CBR extends StatefulWidget {
  final void Function(CBRResults results)? onValidated;

  const CBR({super.key, this.onValidated});

  @override
  State<CBR> createState() => _CBRState();
}

class _CBRState extends State<CBR> {
  final TextEditingController anneeComptage = TextEditingController();
  final TextEditingController tjmaMin = TextEditingController();
  final TextEditingController pl = TextEditingController();
  final TextEditingController anneeMiseEnService = TextEditingController();
  final TextEditingController tauxAccroissement = TextEditingController();
  final TextEditingController iCBR = TextEditingController();
  final TextEditingController dureeDeVie = TextEditingController();

  String label1 = "Année De Comptage";
  String label2 = "TJMA à l'année de comptage";
  String label3 = "Proportion de poids Lourds (%)";
  String label4 = "Année De Mise En Sérvice";
  String label5 = "Taux d'accroissement annuel du trafic (%)";
  String label6 = "Indice Portant Californien du sol support (ICBR)";
  String label7 = "Durée de vie de la chaussée (années)";

  String? selectedValue; // valeur choisie dans le dropdown

  final List<String> options = [
    "Chaussée unidirectionnelle à 2 voies",
    "Chaussée unidirectionnelle à 3 voies",
    "Chaussée bidirectionnelle à 2 voies",
    "Chaussée bidirectionnelle à 3 voies",
  ];

  final Map<String, double> optionsCodes = {
    "Chaussée unidirectionnelle à 2 voies": 0.9,
    "Chaussée unidirectionnelle à 3 voies": 0.8,
    "Chaussée bidirectionnelle à 2 voies": 0.5,
    "Chaussée bidirectionnelle à 3 voies": 0.5,
  };


  final FocusNode focusAnneeComptage = FocusNode();
  final FocusNode focusTjmaMin = FocusNode();
  final FocusNode focusPl = FocusNode();
  final FocusNode focusAnneeMiseEnService = FocusNode();
  final FocusNode focusTauxAccroissement = FocusNode();
  final FocusNode focusICBR = FocusNode();
  final FocusNode focusDureeDeVie = FocusNode();

  @override
  void initState() {
    super.initState();
    focusTjmaMin.addListener(() {
      setState(() {
        if (focusTjmaMin.hasFocus) {
          label2 = "Trafic Moyen Journalier Annuel à l'année de comptage";
        } else {
          label2 = "TJMA à l'année de comptage";
        }
      });
    });
  }

  @override
  void dispose() {
        // Libère les FocusNode
    focusAnneeComptage.dispose();
    focusTjmaMin.dispose();
    focusPl.dispose();
    focusAnneeMiseEnService.dispose();
    focusTauxAccroissement.dispose();
    focusICBR.dispose();
    focusDureeDeVie.dispose();
    anneeComptage.dispose();
    tjmaMin.dispose();
    pl.dispose();
    anneeMiseEnService.dispose();
    tauxAccroissement.dispose();
    iCBR.dispose();
    dureeDeVie.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Méthode CBR",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text("1- Données du projet.", style: TextStyle(fontSize: 18)),

        const SizedBox(height: 20),

        // Dropdown avec tes options
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "Type de voies",
            border: OutlineInputBorder(),
          ),
          initialValue: selectedValue, // valeur actuelle
          items: options.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue;
            });
          },
        ),

        const SizedBox(height: 20),

        TextField(
          controller: anneeComptage,
          focusNode: focusAnneeComptage,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(focusTjmaMin);
          },
          decoration: InputDecoration(
            labelText: label1,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        // Champ 2 avec focus dynamique
        TextField(
          controller: tjmaMin,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          focusNode: focusTjmaMin,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(focusPl);
          },
          decoration: InputDecoration(
            labelText: label2,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: pl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          focusNode: focusPl,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(focusAnneeMiseEnService);
          },
          decoration: InputDecoration(
            labelText: label3,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: anneeMiseEnService,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          focusNode: focusAnneeMiseEnService,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(focusTauxAccroissement);
          },
          decoration: InputDecoration(
            labelText: label4,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: tauxAccroissement,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          focusNode: focusTauxAccroissement,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(focusICBR);
          },
          decoration: InputDecoration(
            labelText: label5,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: iCBR,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          focusNode: focusICBR,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(focusDureeDeVie);
          },
          decoration: InputDecoration(
            labelText: label6,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: dureeDeVie,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          focusNode: focusDureeDeVie,
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            labelText: label7,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(
                255,
                191,
                54,
                12,
              ), // couleur du bouton
              foregroundColor: Colors.grey[200], // couleur du texte
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 15),
            ),
            onPressed: () {
              final valAnneeComptage = cleanInput(anneeComptage.text);
              final valTjmaMin = cleanInput(tjmaMin.text);
              final valPl = cleanInput(pl.text);
              final valAnneeMiseEnService = cleanInput(anneeMiseEnService.text);
              final valTauxAccroissement = cleanInput(tauxAccroissement.text);
              final valICBR = cleanInput(iCBR.text);
              final valDureeDeVie = cleanInput(dureeDeVie.text);

                // Vérifier que tous les champs sont remplis
                if (valAnneeComptage.isEmpty ||
                  selectedValue == null ||
                  valTjmaMin.isEmpty ||
                  valPl.isEmpty ||
                  valAnneeMiseEnService.isEmpty ||
                  valTauxAccroissement.isEmpty ||
                  valICBR.isEmpty ||
                  valDureeDeVie.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text("Veuillez remplir tous les champs"),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
                return;
              }

              // Vérifier que tous les champs sont numériques
              final numericRegex = RegExp(r'^[0-9]+(\.[0-9]+)?$');

              if (!numericRegex.hasMatch(valAnneeComptage) ||
                  !numericRegex.hasMatch(valTjmaMin) ||
                  !numericRegex.hasMatch(valPl) ||
                  !numericRegex.hasMatch(valAnneeMiseEnService) ||
                  !numericRegex.hasMatch(valTauxAccroissement) ||
                  !numericRegex.hasMatch(valICBR) ||
                  !numericRegex.hasMatch(valDureeDeVie)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Tous les champs doivent contenir uniquement des chiffres",
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
                return;
              }

              // ✅ Si tout est correct
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(child: Text("SAUVGARDER ✅")),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );

              final parsedAnneeComptage = int.tryParse(valAnneeComptage);
              final parsedTjmaMin = double.tryParse(valTjmaMin);
              final parsedPl = double.tryParse(valPl);
              final parsedAnneeMiseEnService = int.tryParse(valAnneeMiseEnService);
              final parsedTauxAccroissement = double.tryParse(valTauxAccroissement);
              final parsedICBR = double.tryParse(valICBR);
              final parsedDureeDeVie = int.tryParse(valDureeDeVie);

              if (parsedAnneeComptage == null ||
                  parsedTjmaMin == null ||
                  parsedPl == null ||
                  parsedAnneeMiseEnService == null ||
                  parsedTauxAccroissement == null ||
                  parsedICBR == null ||
                  parsedDureeDeVie == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Les valeurs doivent être des nombres valides",
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
                return;
              }

              if (parsedTjmaMin <= 0 || parsedPl <= 0 || parsedDureeDeVie <= 0 || parsedICBR <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Les champs numériques doivent être supérieurs à zéro",
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
                return;
              }

              final codeChaussee = optionsCodes[selectedValue!] ?? 0.0;
              final dureeDeVieTotal =
                  (parsedDureeDeVie +
                  (parsedAnneeMiseEnService - parsedAnneeComptage));
              final anneeFinDeVie = parsedAnneeMiseEnService + parsedDureeDeVie;
              final tjmaFinDeVie =
                  parsedTjmaMin *
                  pow((1 + parsedTauxAccroissement / 100), dureeDeVieTotal);
              final tjmaZero =
                  parsedTjmaMin *
                  pow(
                    (1 + parsedTauxAccroissement / 100),
                    (parsedAnneeMiseEnService - parsedAnneeComptage),
                  );
              final nombrePL = tjmaFinDeVie * (parsedPl / 100);
              final traficPoidsLourds = nombrePL * codeChaussee;
              final eppTotalGnt =
                  (100 +
                      sqrt(13 / 2) *
                          (75 + 50 * (log(traficPoidsLourds / 10) / ln10))) /
                  (parsedICBR + 5);

              final results = CBRResults(
                pavementType: selectedValue!, //
                anneeFinDeVie: anneeFinDeVie, //
                tjmaMin: parsedTjmaMin, //
                tjmaFinDeVie: tjmaFinDeVie,
                tjmaZero: tjmaZero,
                pl: parsedPl, //
                anneeMiseEnService: parsedAnneeMiseEnService, //
                tauxAccroissement: parsedTauxAccroissement, //
                iCBR: parsedICBR, //
                dureeDeVie: parsedDureeDeVie, //
                traficPoidsLourds: traficPoidsLourds,
                eppTotalGnt: eppTotalGnt,
                codeChaussee: codeChaussee,
                dureeDeVieTotal: dureeDeVieTotal,
              );

              widget.onValidated?.call(results);
            },
            child: const Text("Sauvgarder et passer à la page suivante"),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class CBRResults {
  final String pavementType;
  final int anneeFinDeVie;
  final double tjmaMin;
  final double tjmaFinDeVie;
  final double tjmaZero;
  final double pl;
  final int anneeMiseEnService;
  final double tauxAccroissement;
  final double iCBR;
  final int dureeDeVie;
  final double traficPoidsLourds;
  final double eppTotalGnt;
  final double codeChaussee;
  final int dureeDeVieTotal;

  CBRResults({
    required this.pavementType,
    required this.anneeFinDeVie,
    required this.tjmaMin,
    required this.tjmaFinDeVie,
    required this.tjmaZero,
    required this.pl,
    required this.anneeMiseEnService,
    required this.tauxAccroissement,
    required this.iCBR,
    required this.dureeDeVie,
    required this.traficPoidsLourds,
    required this.eppTotalGnt,
    required this.codeChaussee,
    required this.dureeDeVieTotal,
  });
}

class ResultPage extends StatelessWidget {
  final CBRResults? results;

  const ResultPage({super.key, this.results});

  @override
  Widget build(BuildContext context) {
    if (results == null) {
      return const Center(
        child: Text('Aucun résultat calculé', style: TextStyle(fontSize: 18)),
      );
    }

    final result = results!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résultats',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ResultRow(label: 'Type de voies', value: result.pavementType),
          ResultRow(
            label: 'Répartition transversal\ndu trafic',
            value: result.codeChaussee.toStringAsFixed(2),
          ),
          ResultRow(
            label: 'Année de fin de vie',
            value: result.anneeFinDeVie.toString(),
          ),
          ResultRow(
            label: 'TJMA mise en service',
            value: result.tjmaZero.toStringAsFixed(1),
            unit: 'V/J',
          ),
          ResultRow(
            label: 'TJMA fin de vie',
            value: result.tjmaFinDeVie.toStringAsFixed(1),
            unit: 'V/J',
          ),
          ResultRow(
            label: 'Trafic poids lourds',
            value: result.traficPoidsLourds.toStringAsFixed(1),
            unit: 'PL/J',
          ),
          ResultRow(
            label: 'Épaisseurs équivalente',
            value: result.eppTotalGnt.toStringAsFixed(2),
            unit: 'cm',
          ),
          Text(
            "La répartition des couches sera ajouté plus tard.",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          // ... autres lignes ...
        ],
      ),
    );
  }
}

class ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const ResultRow({
    super.key,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                unit != null ? "$value $unit" : value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // valeur en noir pour sobriété
                ),
              ),
            ],
          ),
          const Divider(thickness: 0.5, color: Colors.grey),
        ],
      ),
    );
  }
}
