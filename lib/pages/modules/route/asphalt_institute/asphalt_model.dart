class AsphaltResults {
  final String pavementType;
  final double tjmaPLzero;
  final double traficEquivalentTe;
  final double coeffAccroissement;
  final double truckFactorTf;
  final double dtn;

  AsphaltResults({
    required this.pavementType,
    required this.tjmaPLzero,
    required this.traficEquivalentTe,
    required this.coeffAccroissement,
    required this.dtn,
    required this.truckFactorTf,
  });
}
