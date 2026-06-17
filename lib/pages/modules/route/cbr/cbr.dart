import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_checkinput.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_model.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_result.dart';
import 'package:roadly/assets/widgets/build_field.dart';

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
      _selectedIndex = 1; // bascule vers Résultats
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
          child: _selectedIndex == 0
              ? SingleChildScrollView(child: CBR(onValidated: _onValidated))
              : SingleChildScrollView(child: ResultPageCbr(results: results)),
        ),
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
          selectedItemColor: const Color.fromARGB(255, 225, 35, 6),
          unselectedItemColor: const Color.fromARGB(255, 244, 6, 6),
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
  String label4 = "Année De Mise En Service";
  String label5 = "Taux d'accroissement annuel du trafic (%)";
  String label6 = "Indice Portant Californien du sol support (ICBR)";
  String label7 = "Durée de vie de la chaussée (années)";

  String? selectedValue;

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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "La méthode CBR permet de déterminer l'épaisseur d'une chaussée à partir du trafic et de la portance du sol.",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "Méthode CBR",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            "Données du projet",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: selectedValue,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.alt_route),
                labelText: "Type de voies",
                contentPadding: EdgeInsets.all(18),
              ),
              items: options.map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          BuildField(
            controller: anneeComptage,
            focusNode: focusAnneeComptage,
            nextFocus: focusTjmaMin,
            label: label1,
            icon: Icons.calendar_month,
          ),

          BuildField(
            controller: tjmaMin,
            focusNode: focusTjmaMin,
            nextFocus: focusPl,
            label: label2,
            icon: Icons.directions_car,
          ),

          BuildField(
            controller: pl,
            focusNode: focusPl,
            nextFocus: focusAnneeMiseEnService,
            label: label3,
            icon: Icons.local_shipping,
          ),

          BuildField(
            controller: anneeMiseEnService,
            focusNode: focusAnneeMiseEnService,
            nextFocus: focusTauxAccroissement,
            label: label4,
            icon: Icons.engineering,
          ),

          BuildField(
            controller: tauxAccroissement,
            focusNode: focusTauxAccroissement,
            nextFocus: focusICBR,
            label: label5,
            icon: Icons.trending_up,
          ),

          BuildField(
            controller: iCBR,
            focusNode: focusICBR,
            nextFocus: focusDureeDeVie,
            label: label6,
            icon: Icons.landscape,
          ),

          BuildField(
            controller: dureeDeVie,
            focusNode: focusDureeDeVie,
            label: label7,
            icon: Icons.schedule,
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // couleur bleue iOS
                foregroundColor: Colors.white, // texte blanc
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // coins arrondis
                ),
                elevation: 3, // petite ombre
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                checkInputAndValidate(
                  context: context,
                  anneeComptage: anneeComptage.text,
                  tjmaMin: tjmaMin.text,
                  pl: pl.text,
                  anneeMiseEnService: anneeMiseEnService.text,
                  tauxAccroissement: tauxAccroissement.text,
                  iCBR: iCBR.text,
                  dureeDeVie: dureeDeVie.text,
                  selectedValue: selectedValue,
                  onValidated: widget.onValidated,
                );
              },

              icon: const Icon(Icons.check_circle, size: 20), // icône à gauche
              label: const Text("Valider et voir les résultats"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
