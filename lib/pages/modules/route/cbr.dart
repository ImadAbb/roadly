import 'dart:math';
import 'package:flutter/material.dart';

class CBRRoute extends StatefulWidget {
  const CBRRoute({super.key});

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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              SingleChildScrollView(
                child: CBR(onValidated: _onValidated),
              ),
              ResultPage(results: results),
            ],
          ),
        ),
        BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
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

  late FocusNode _focusNode2;
  String label1 = "Année De Comptage";
  String label2 = "TJMA à l'année de comptage";
  String label3 = "Proportion de poids Lourds (%)";
  String label4 = "Année De Mise En Sérvice";
  String label5 = "Taux d'accroissement annuel du trafic (%)";
  String label6 = "Indice Portant Californien du sol support (ICBR)";
  String label7 = "Durée de vie de la chaussée (année)";

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

  double selectedCode = 0;

  @override
  void initState() {
    super.initState();
    _focusNode2 = FocusNode();
    _focusNode2.addListener(() {
      setState(() {
        if (_focusNode2.hasFocus) {
          label2 = "Trafic Moyen Journalier Annuel à l'année de comptage";
        } else {
          label2 = "TJMA à l'année de comptage";
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode2.dispose();
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
          initialValue: selectedValue, // valeur initiale
          items: options.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue;
              selectedCode = optionsCodes[newValue] ?? 0.00;
            });
          },
        ),

        const SizedBox(height: 20),

        TextField(
          controller: anneeComptage,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label1,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        // Champ 2 avec focus dynamique
        TextField(
          controller: tjmaMin,
          keyboardType: TextInputType.number,
          focusNode: _focusNode2,
          decoration: InputDecoration(
            labelText: label2,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: pl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label3,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: anneeMiseEnService,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label4,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: tauxAccroissement,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label5,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: iCBR,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label6,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: dureeDeVie,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label7,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 191, 54, 12), // couleur du bouton
              foregroundColor: Colors.grey[200], // couleur du texte
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(
                fontSize: 15,
                
              ),
            ),
            onPressed: () {
              final valAnneeComptage = anneeComptage.text;
              final valTjmaMin = tjmaMin.text;
              final valPl = pl.text;
              final valAnneeMiseEnService = anneeMiseEnService.text;
              final valTauxAccroissement = tauxAccroissement.text;
              final valICBR = iCBR.text;
              final valDureeDeVie = dureeDeVie.text;
              final valSelectedCode = selectedCode;

              // Vérifier que tous les champs sont remplis
              if (valAnneeComptage.isEmpty ||
                  valSelectedCode == 0 ||
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
              final numericRegex = RegExp(r'^[0-9]+(.[0-9]+)?$');


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
                      Expanded(
                        child: Text(
                          "SAUVGARDER ✅",
                        ),
                      ),
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

              final parsedAnneeComptage = int.parse(valAnneeComptage);
              final parsedTjmaMin = double.parse(valTjmaMin);
              final parsedPl = double.parse(valPl);
              final parsedAnneeMiseEnService = int.parse(valAnneeMiseEnService);
              final parsedTauxAccroissement = double.parse(valTauxAccroissement);
              final parsedICBR = double.parse(valICBR);
              final parsedDureeDeVie = int.parse(valDureeDeVie);

              final codeChaussee = optionsCodes[selectedValue!] ?? 0.0;
              final dureeDeVieTotal = (parsedDureeDeVie + (parsedAnneeMiseEnService - parsedAnneeComptage));
              final anneeFinDeVie = parsedAnneeMiseEnService + parsedDureeDeVie;
              final tjmaFinDeVie = parsedTjmaMin * pow((1 + parsedTauxAccroissement/100), dureeDeVieTotal);
              final tjmaZero = parsedTjmaMin * pow((1 + parsedTauxAccroissement/100), (parsedAnneeMiseEnService - parsedAnneeComptage));
              final nombrePL = tjmaFinDeVie * (parsedPl/100);
              final traficPoidsLourds = nombrePL * codeChaussee;
              final eppTotalGnt = (100 + sqrt(13 / 2) * (75 + 50 * (log(traficPoidsLourds / 10) / ln10))) / (parsedICBR + 5);

              final results = CBRResults(
                pavementType: selectedValue!, //
                anneeFinDeVie: anneeFinDeVie, //
                tjmaMin: parsedTjmaMin, //
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
        child: Text(
          'Aucun résultat calculé',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    final result = results!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Résultats', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ResultRow(label: 'Type de voies', value: result.pavementType),
          ResultRow(label: 'Répartition transversal\ndu trafic', value: result.codeChaussee.toStringAsFixed(2)),
          ResultRow(label: 'Année de fin de vie', value: result.anneeFinDeVie.toString()),
          ResultRow(label: 'TJMA mise en service', value: result.tjmaZero.toStringAsFixed(1), unit: 'V/J'),
          ResultRow(label: 'TJMA fin de vie', value: result.tjmaMin.toStringAsFixed(1), unit: 'V/J'),
          ResultRow(label: 'Trafic poids lourds', value: result.traficPoidsLourds.toStringAsFixed(1), unit: 'PL/J'),
          ResultRow(label: 'Épaisseurs équivalente', value: result.eppTotalGnt.toStringAsFixed(2), unit: 'cm'),
          Text(
            "La répartition des couches sera ajouté plus tard.",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          )

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
