import '../common/calculation_point.dart';

/// Résultat du calcul de l'effort tranchant.
///
/// Convention :
/// - réaction vers le haut = positive
/// - charge vers le bas = négative
/// - moment ponctuel = n'influence pas directement T
///
/// V(x) représente la somme algébrique des forces verticales
/// situées à gauche de la section x.
class ShearResult {
  final List<CalculationPoint> points;

  const ShearResult({
    this.points = const [],
  });

  /// Retourne l'effort tranchant calculé à une position donnée.
  double valueAt(double position) {
    for (final point in points) {
      if ((point.position - position).abs() < 1e-9) {
        return point.value;
      }
    }

    return 0.0;
  }
}