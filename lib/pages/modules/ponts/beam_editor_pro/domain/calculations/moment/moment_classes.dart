import '../common/calculation_point.dart';

/// Résultat du calcul du moment fléchissant.
///
/// Convention :
///
/// - moment fléchissant positif = moment positif/sagissant
/// - réaction verticale vers le haut = positive
/// - charge verticale vers le bas = négative
/// - moment appliqué positif = antihoraire
class MomentResult {
  final List<CalculationPoint> points;

  const MomentResult({
    this.points = const [],
  });

  /// Retourne le moment à une position donnée.
  double valueAt(double position) {
    for (final point in points) {
      if ((point.position - position).abs() < 1e-9) {
        return point.value;
      }
    }

    return 0.0;
  }
}