import 'dart:math';
import 'package:flutter/material.dart';
import 'package:roadly/componets/button.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_model.dart';

void checkInputAndValidate({
  required BuildContext context,
  required String anneeComptage,
  required String tjmaMin,
  required String pl,
  required String anneeMiseEnService,
  required String tauxAccroissement,
  required String iCBR,
  required String dureeDeVie,
  required String? selectedValue,
  required void Function(CBRResults results)? onValidated,
}) {
  anneeComptage = cleanInput(anneeComptage);
  tjmaMin = cleanInput(tjmaMin);
  pl = cleanInput(pl);
  anneeMiseEnService = cleanInput(anneeMiseEnService);
  tauxAccroissement = cleanInput(tauxAccroissement);
  iCBR = cleanInput(iCBR);
  dureeDeVie = cleanInput(dureeDeVie);
  if (anneeComptage.isEmpty ||
      selectedValue == null ||
      tjmaMin.isEmpty ||
      pl.isEmpty ||
      anneeMiseEnService.isEmpty ||
      tauxAccroissement.isEmpty ||
      iCBR.isEmpty ||
      dureeDeVie.isEmpty) {
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
      !numericRegex.hasMatch(pl) ||
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
            Expanded(child: Text("Tous les champs doivent contenir uniquement des chiffres")),
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

  final parsedAnneeComptage = int.tryParse(anneeComptage);
  final parsedTjmaMin = double.tryParse(tjmaMin);
  final parsedPl = double.tryParse(pl);
  final parsedAnneeMiseEnService = int.tryParse(anneeMiseEnService);
  final parsedTauxAccroissement = double.tryParse(tauxAccroissement);
  final parsedICBR = double.tryParse(iCBR);
  final parsedDureeDeVie = int.tryParse(dureeDeVie);

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
            Expanded(child: Text("Les valeurs doivent être des nombres valides")),
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

  if (parsedTjmaMin <= 0 ||
      parsedPl <= 0 ||
      parsedDureeDeVie <= 0 ||
      parsedICBR <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text("Les champs numériques doivent être supérieurs à zéro")),
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

  // Calculs
  final codeChaussee = {
    "Chaussée unidirectionnelle à 2 voies": 0.9,
    "Chaussée unidirectionnelle à 3 voies": 0.8,
    "Chaussée bidirectionnelle à 2 voies": 0.5,
    "Chaussée bidirectionnelle à 3 voies": 0.5,
  }[selectedValue] ?? 0.0;

  final dureeDeVieTotal =
      parsedDureeDeVie + (parsedAnneeMiseEnService - parsedAnneeComptage);
  final anneeFinDeVie = parsedAnneeMiseEnService + parsedDureeDeVie;
  final tjmaFinDeVie =
      parsedTjmaMin * pow((1 + parsedTauxAccroissement / 100), dureeDeVieTotal);
  final tjmaZero = parsedTjmaMin *
      pow((1 + parsedTauxAccroissement / 100),
          (parsedAnneeMiseEnService - parsedAnneeComptage));
  final nombrePL = tjmaFinDeVie * (parsedPl / 100);
  final traficPoidsLourds = nombrePL * codeChaussee;
  final eppTotalGnt =
      (100 +
              sqrt(13 / 2) *
                  (75 + 50 * (log(traficPoidsLourds / 10) / ln10))) /
          (parsedICBR + 5);

  final results = CBRResults(
    pavementType: selectedValue,
    anneeFinDeVie: anneeFinDeVie,
    tjmaMin: parsedTjmaMin,
    tjmaFinDeVie: tjmaFinDeVie,
    tjmaZero: tjmaZero,
    pl: parsedPl,
    anneeMiseEnService: parsedAnneeMiseEnService,
    tauxAccroissement: parsedTauxAccroissement,
    iCBR: parsedICBR,
    dureeDeVie: parsedDureeDeVie,
    traficPoidsLourds: traficPoidsLourds,
    eppTotalGnt: eppTotalGnt,
    codeChaussee: codeChaussee,
    dureeDeVieTotal: dureeDeVieTotal,
  );

  onValidated?.call(results);
}
