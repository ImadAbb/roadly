/// Tolérances utilisées par les calculs numériques.
///
/// On évite ainsi de disperser des valeurs comme
/// 0.000001 dans tout le code.
class CalculationTolerance {
  const CalculationTolerance._();

  /// Tolérance générale pour comparer deux valeurs.
  static const double position = 1e-9;

  /// Tolérance utilisée pour considérer une valeur comme nulle.
  static const double zero = 1e-9;

  /// Vérifie si deux valeurs sont suffisamment proches.
  static bool nearlyEqual(
    double a,
    double b, {
    double tolerance = zero,
  }) {
    return (a - b).abs() <= tolerance;
  }

  /// Vérifie si une valeur est considérée comme nulle.
  static bool isZero(
    double value, {
    double tolerance = zero,
  }) {
    return value.abs() <= tolerance;
  }
}