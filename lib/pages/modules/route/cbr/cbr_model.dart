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