import 'dart:math';

import 'package:flutter/material.dart';
import 'package:roadly/componets/button.dart';
import 'package:roadly/pages/modules/route/asphalt_institute/asphalt_model.dart';

void asphaltCheckInputAndValidate({
  required BuildContext context,
  required String anneeComptage,
  required String tjmaMin,
  required String plPercent,
  required List<List<String>> pl,
  required String anneeMiseEnService,
  required String tauxAccroissement,
  required String iCBR,
  required String dureeDeVie,
  required String? selectedValue,
  required void Function(AsphaltResults results)? onValidated,
}) {
  //cleanInput
  anneeComptage = cleanInput(anneeComptage);
  tjmaMin = cleanInput(tjmaMin);
  plPercent = cleanInput(plPercent);
  pl = pl.map((e) => e.map((e) => cleanInput(e)).toList()).toList();
  anneeMiseEnService = cleanInput(anneeMiseEnService);
  tauxAccroissement = cleanInput(tauxAccroissement);
  iCBR = cleanInput(iCBR);
  dureeDeVie = cleanInput(dureeDeVie);
  if (anneeComptage.isEmpty ||
      tjmaMin.isEmpty ||
      plPercent.isEmpty ||
      pl.any((e) => e.any((e) => e.isEmpty)) ||
      anneeMiseEnService.isEmpty ||
      tauxAccroissement.isEmpty ||
      iCBR.isEmpty ||
      dureeDeVie.isEmpty ||
      selectedValue == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text("Veuillez remplir tous les champs")),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }

  final numericRegex = RegExp(r'^[0-9]+(\.[0-9]+)?$');
  if (!numericRegex.hasMatch(anneeComptage) ||
      !numericRegex.hasMatch(tjmaMin) ||
      !numericRegex.hasMatch(plPercent) ||
      pl.any((e) => e.any((e) => !numericRegex.hasMatch(e))) ||
      !numericRegex.hasMatch(anneeMiseEnService) ||
      !numericRegex.hasMatch(tauxAccroissement) ||
      !numericRegex.hasMatch(iCBR) ||
      !numericRegex.hasMatch(dureeDeVie)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Tous les champs doivent contenir uniquement des chiffres valides",
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }

  final parsedAnneeComptage = double.tryParse(anneeComptage);
  final parsedTjmaMin = double.tryParse(tjmaMin);
  final parsedPlPercent = double.tryParse(plPercent);
  final parsedPl = pl
      .map((e) => e.map((e) => double.tryParse(e)).toList())
      .toList();
  final parsedAnneeMiseEnService = double.tryParse(anneeMiseEnService);
  final parsedTauxAccroissement = double.tryParse(tauxAccroissement);
  final parsedICBR = double.tryParse(iCBR);
  final parsedDureeDeVie = double.tryParse(dureeDeVie);

  if (parsedAnneeComptage == null ||
      parsedTjmaMin == null ||
      parsedPlPercent == null ||
      parsedPl.any((e) => e.any((e) => e == null)) ||
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
              child: Text("Les valeurs doivent être des nombres valides"),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }
  // Vérification des bornes pour essieux simples et tandems
  final invalidValues = parsedPl.any((row) {
    final essieuSimple = row[1]; // deuxième colonne
    final essieuTandem = row[2]; // troisième colonne

    // null check déjà fait avant, donc on force avec !
    return (essieuSimple! < 0 || essieuSimple > 26) ||
        (essieuTandem! < 0 || essieuTandem > 46);
  });

  if (invalidValues) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Les essieux simples doivent être entre 0 et 26, et les tandems entre 0 et 46",
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }

  final totalPourcentage = parsedPl
      .map((row) => row[0]!)
      .reduce((a, b) => a + b);
  if ((totalPourcentage - 100).abs() > 0.0001) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text("Le pourcentage de charge doit être égal à 100"),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }
  if (parsedTjmaMin < 0 ||
      parsedPl.any((e) => e.any((e) => e! < 0)) ||
      parsedTauxAccroissement < 0 ||
      parsedICBR < 0 ||
      parsedDureeDeVie < 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Les champs numériques doivent être supérieurs ou égaux à zéro",
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 10),
          Expanded(child: Text("SAUVGARDER ✅")),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ),
  );

  //calculs
  final codeChaussee =
      {
        "Chaussée unidirectionnelle à 2 voies": 0.9,
        "Chaussée unidirectionnelle à 3 voies": 0.8,
        "Chaussée bidirectionnelle à 2 voies": 0.5,
        "Chaussée bidirectionnelle à 3 voies": 0.5,
      }[selectedValue] ??
      0.0;

  //Trafic à la premiere annee de mise en service PL
  final tjmaZero =
      parsedTjmaMin *
      pow(
        (1 + parsedTauxAccroissement / 100),
        (parsedAnneeMiseEnService - parsedAnneeComptage),
      );
  final tjmaPLzero = tjmaZero * parsedPlPercent / 100;

  //Trafic equivalent Te
  double getFacteurEquivalence(String typeEssieu, double fi) {
    if (typeEssieu == "simple") {
      if (fi >= 0 && fi < 8) return 0;
      if (fi >= 8 && fi < 12) return 0.11;
      if (fi >= 12 && fi < 16) return 0.34;
      if (fi >= 16 && fi < 18) return 0.76;
      if (fi >= 18 && fi < 20) return 1.31;
      if (fi >= 20 && fi < 22) return 2.26;
      if (fi >= 22 && fi < 24) return 3.91;
      if (fi >= 24 && fi < 26) return 6.74;
    } else if (typeEssieu == "tandem") {
      if (fi >= 0 && fi < 14) return 0;
      if (fi >= 14 && fi < 20) return 0.11;
      if (fi >= 20 && fi < 26) return 0.27;
      if (fi >= 26 && fi < 30) return 0.57;
      if (fi >= 30 && fi < 32) return 0.92;
      if (fi >= 32 && fi < 34) return 1.25;
      if (fi >= 34 && fi < 36) return 1.70;
      if (fi >= 36 && fi < 38) return 2.33;
      if (fi >= 38 && fi < 40) return 3.15;
      if (fi >= 40 && fi < 42) return 4.35;
      if (fi >= 42 && fi < 44) return 5.88;
      if (fi >= 44 && fi < 46) return 8.15;
    }
    return 0.0;
  }

  // Calcul du trafic équivalent Te
  double fe = 0.0;

  for (var row in parsedPl) {
    final pourcentage = row[0]!; // première colonne (%)
    final fiSimple = row[1]!; // charge essieu simple
    final fiTandem = row[2]!; // charge essieu tandem

    // Facteurs d’équivalence selon les intervalles
    final diSimple = getFacteurEquivalence("simple", fiSimple);
    final diTandem = getFacteurEquivalence("tandem", fiTandem);

    // Contribution de la ligne
    fe += (pourcentage / 100) * (diSimple + diTandem);
  }

  // Application de la loi : trafic PL * somme pondérée
  final traficEquivalentTe = tjmaPLzero * fe;

  //calcul Truck factor Tf
  final truckFactorTf = traficEquivalentTe / tjmaPLzero;

  // coeff d'accroissement k
  final coeffAccroissement = (pow(1 + parsedTauxAccroissement / 100,parsedDureeDeVie ) - 1) / (parsedDureeDeVie * parsedTauxAccroissement/100);

  // calcul de DTN
  final dtn = truckFactorTf * codeChaussee * coeffAccroissement * tjmaPLzero;

  final results = AsphaltResults(pavementType: selectedValue, tjmaPLzero: tjmaPLzero, traficEquivalentTe: traficEquivalentTe, coeffAccroissement: coeffAccroissement, dtn: dtn, truckFactorTf: truckFactorTf);

  onValidated!.call(results);
}
