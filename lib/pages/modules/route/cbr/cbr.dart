import 'package:flutter/material.dart';
import 'package:roadly/assets/widgets/build_field.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_checkinput.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_model.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_result.dart';

class CBR extends StatefulWidget {
  final void Function(CBRResults results)? onValidated;

  const CBR({super.key, this.onValidated});

  @override
  State<CBR> createState() => _CBRState();
}

class _CBRState extends State<CBR> with SingleTickerProviderStateMixin {
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

  // Ordre correct des FocusNode
  final FocusNode focusTypeVoies = FocusNode();
  final FocusNode focusAnneeComptage = FocusNode();
  final FocusNode focusTjmaMin = FocusNode();
  final FocusNode focusPl = FocusNode();
  final FocusNode focusAnneeMiseEnService = FocusNode();
  final FocusNode focusTauxAccroissement = FocusNode();
  final FocusNode focusICBR = FocusNode();
  final FocusNode focusDureeDeVie = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;
  CBRResults? _results;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Démarrer l'animation après un court délai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    focusTypeVoies.dispose();
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

  // Widget pour le titre avec container bleu
  Widget _buildTitleContainer(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 36, 118, 184),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le contenu du groupe
  Widget _buildGroupContent(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }

  // Widget pour un groupe complet
  Widget _buildGroup({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleContainer(title, icon),
            _buildGroupContent(content),
          ],
        ),
      ),
    );
  }

  // Widget pour les champs de type BuildField
  Widget _buildFieldGroupWidgets(List<Widget> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields,
    );
  }

  void _handleValidated(CBRResults results) {
    setState(() {
      _results = results;
      _selectedIndex = 1;
    });

    widget.onValidated?.call(results);
  }

  Widget _buildFormContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner avec animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "La méthode CBR permet de déterminer l'épaisseur d'une chaussée à partir du trafic et de la portance du sol.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Titre principal
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calculate, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                const Expanded(
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
          ),

          const SizedBox(height: 8),

          // Sous-titre avec animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              "Données du projet",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ),

          const SizedBox(height: 24),

          // Groupe 1 : Type de voies
          _buildGroup(
            title: "Type de voies",
            icon: Icons.route,
            content: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
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
          ),

          const SizedBox(height: 20),

          // Groupe 2 : Données trafic
          _buildGroup(
            title: "Données trafic",
            icon: Icons.directions_car,
            content: _buildFieldGroupWidgets([
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
            ]),
          ),

          const SizedBox(height: 20),

          // Groupe 3 : Données techniques
          _buildGroup(
            title: "Données techniques",
            icon: Icons.settings,
            content: _buildFieldGroupWidgets([
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
                controller: dureeDeVie,
                focusNode: focusDureeDeVie,
                nextFocus: focusICBR,
                label: label7,
                icon: Icons.schedule,
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // Groupe 4 : Données sol
          _buildGroup(
            title: "Données sol",
            icon: Icons.landscape,
            content: _buildFieldGroupWidgets([
              BuildField(
                controller: iCBR,
                focusNode: focusICBR,
                label: label6,
                icon: Icons.landscape,
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // Bouton avec animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
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
                    onValidated: _handleValidated,
                  );
                },
                icon: const Icon(Icons.check_circle, size: 20),
                label: const Text("Valider et voir les résultats"),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _selectedIndex == 0
              ? SingleChildScrollView(child: _buildFormContent())
              : ResultPageCbr(results: _results),
        ),
        SafeArea(
          child: BottomNavigationBar(
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
          ),
        ),
      ],
    );
  }
}
