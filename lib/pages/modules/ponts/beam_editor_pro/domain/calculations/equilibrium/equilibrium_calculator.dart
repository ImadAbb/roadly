import '../../models/beam.dart';
import '../../models/load.dart';
import '../reactions/reaction_calculator.dart';

/// Résultat de la vérification de l'équilibre global.
///
/// Les valeurs doivent être proches de zéro pour une structure
/// correctement équilibrée.
class EquilibriumResult {
  /// Somme des forces verticales.
  final double verticalForce;

  /// Somme des moments autour de x = 0.
  final double moment;

  const EquilibriumResult({
    required this.verticalForce,
    required this.moment,
  });

  bool get isBalanced =>
      verticalForce.abs() < 1e-9 &&
      moment.abs() < 1e-9;
}

/// Vérifie l'équilibre global de la poutre.
///
/// Équations vérifiées :
///
/// ΣFy = 0
///
/// ΣM(0) = 0
EquilibriumResult calculateEquilibrium(Beam beam) {
  final reactions = calculateReactions(beam);

  double verticalForce = 0.0;
  double moment = 0.0;

  // ============================================================
  // RÉACTIONS
  // ============================================================

  for (final support in beam.supports) {
    final reaction = reactions.getReaction(support.id);

    if (reaction == null) {
      continue;
    }

    verticalForce += reaction;

    moment += reaction * support.position;
  }

  // Moment de réaction d'un encastrement.
  if (reactions.mA != null) {
    moment += reactions.mA!;
  }

  // ============================================================
  // CHARGES
  // ============================================================

  for (final load in beam.loads) {
    // ----------------------------------------------------------
    // CHARGE PONCTUELLE
    // ----------------------------------------------------------

    if (load is PointLoad) {
      final force = -load.value;

      verticalForce += force;

      moment += force * load.position;
    }

    // ----------------------------------------------------------
    // CHARGE RÉPARTIE
    // ----------------------------------------------------------

    else if (load is DistributedLoad) {
      final length =
          load.positionEnd - load.position;

      if (length <= 0) {
        continue;
      }

      final force =
          -(load.value * length);

      final center =
          (load.position + load.positionEnd) / 2;

      verticalForce += force;

      moment += force * center;
    }

    // ----------------------------------------------------------
    // MOMENT APPLIQUÉ
    // ----------------------------------------------------------

    else if (load is MomentLoad) {
      moment += load.value;
    }
  }

  return EquilibriumResult(
    verticalForce: verticalForce,
    moment: moment,
  );
}