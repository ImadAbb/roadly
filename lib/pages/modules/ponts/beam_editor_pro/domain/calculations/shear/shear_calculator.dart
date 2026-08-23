import '../../models/beam.dart';
import '../../models/load.dart';
import '../common/calculation_point.dart';
import '../common/calculation_tolerance.dart';
import '../loads/load_positions.dart';
import '../reactions/reaction_calculator.dart';
import '../reactions/reaction_classes.dart';
import 'shear_classes.dart';

/// Calcule l'effort tranchant T(x) de la poutre.
///
/// Convention :
///
/// - réaction verticale positive = vers le haut
/// - PointLoad.value positif = charge vers le bas
/// - DistributedLoad.value positif = charge vers le bas
///
/// Pour une section x :
///
/// T(x) = somme des forces verticales situées à gauche de x
///
/// Une charge ponctuelle crée donc un saut de T.
///
/// Une charge répartie fait varier T progressivement.
ShearResult calculateShear(Beam beam) {
  final reactions = calculateReactions(beam);

  final positions = LoadPositions.importantPositions(beam);

  if (positions.isEmpty) {
    return const ShearResult();
  }

  final points = <CalculationPoint>[];

  for (final x in positions) {
    final value = calculateShearAt(
      beam,
      reactions,
      x,
    );

    points.add(
      CalculationPoint(
        position: x,
        value: value,
      ),
    );
  }

  return ShearResult(points: points);
}

/// Calcule l'effort tranchant T(x) à une position donnée.
///
/// Les actions exactement situées en x ne sont pas encore
/// appliquées.
///
/// Cette fonction reprend exactement la logique utilisée
/// précédemment par _shearAt().
double calculateShearAt(
  Beam beam,
  ReactionResult reactions,
  double x,
) {
  double shear = 0.0;

  // ============================================================
  // RÉACTIONS
  // ============================================================

  for (final support in beam.supports) {
    final reaction = reactions.getReaction(support.id);

    if (reaction == null) {
      continue;
    }

    if (support.position < x &&
        !CalculationTolerance.nearlyEqual(
          support.position,
          x,
        )) {
      shear += reaction;
    }
  }

  // ============================================================
  // CHARGES
  // ============================================================

  for (final load in beam.loads) {
    // ----------------------------------------------------------
    // CHARGE PONCTUELLE
    // ----------------------------------------------------------

    if (load is PointLoad) {
      if (load.position < x &&
          !CalculationTolerance.nearlyEqual(
            load.position,
            x,
          )) {
        shear -= load.value;
      }
    }

    // ----------------------------------------------------------
    // CHARGE RÉPARTIE
    // ----------------------------------------------------------

    else if (load is DistributedLoad) {
      if (x <= load.position) {
        continue;
      }

      final end = x < load.positionEnd
          ? x
          : load.positionEnd;

      final loadedLength = end - load.position;

      if (loadedLength <= 0) {
        continue;
      }

      shear -= load.value * loadedLength;
    }

    // ----------------------------------------------------------
    // MOMENT PONCTUEL
    // ----------------------------------------------------------

    else if (load is MomentLoad) {
      continue;
    }
  }

  return shear;
}