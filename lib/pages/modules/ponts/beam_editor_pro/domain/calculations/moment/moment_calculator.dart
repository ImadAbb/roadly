import '../../models/beam.dart';
import '../../models/load.dart';
import '../../models/support.dart';
import '../common/calculation_point.dart';
import '../loads/load_positions.dart';
import '../reactions/reaction_calculator.dart';
import '../reactions/reaction_classes.dart';
import 'moment_classes.dart';

/// Calcule le moment fléchissant M(x).
///
/// Convention :
///
/// - réaction verticale vers le haut = positive
/// - PointLoad.value positif = charge vers le bas
/// - DistributedLoad.value positif = charge vers le bas
/// - MomentLoad.value positif = antihoraire
///
/// Pour une section x, on écrit l'équilibre de la partie gauche.
MomentResult calculateMoment(Beam beam) {
  final reactions = calculateReactions(beam);

  final positions = LoadPositions.importantPositions(beam);

  if (positions.isEmpty) {
    return const MomentResult();
  }

  final points = <CalculationPoint>[];

  for (final x in positions) {
    final value = calculateMomentAt(
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

  return MomentResult(points: points);
}

/// Calcule le moment fléchissant M(x) à une position donnée.
///
/// Cette fonction utilise exactement la même logique que
/// le calcul du diagramme complet.
/// Elle permet notamment de tester M(x) à une position qui
/// n'est pas forcément présente dans `importantPositions`.
double calculateMomentAt(
  Beam beam,
  ReactionResult reactions,
  double x,
) {
  double moment = 0.0;

  // ============================================================
  // RÉACTIONS VERTICALES
  // ============================================================

  for (final support in beam.supports) {
    final reaction = reactions.getReaction(support.id);

    if (reaction == null) {
      continue;
    }

    if (support.position <= x) {
      moment += reaction * (x - support.position);
    }
  }

  // ============================================================
  // MOMENT DE RÉACTION D'UN ENCASTREMENT
  //
  // Le moment d'encastrement MA doit être RETRANCHÉ (et non
  // ajouté) pour être cohérent avec la convention utilisée pour
  // les réactions verticales et les charges ci-dessous. Sans ce
  // signe, le moment ne revient pas à zéro à l'extrémité libre
  // d'une console et ne varie plus correctement le long de la
  // poutre (voir tests "encastrement").
  // ============================================================

  if (reactions.mA != null) {
    final encastrements = beam.supports.where(
      (support) => support.type == SupportType.encastrement_,
    );

    if (encastrements.isNotEmpty) {
      final support = encastrements.first;

      if (support.position <= x) {
        moment -= reactions.mA!;
      }
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
      if (load.position <= x) {
        moment -= load.value * (x - load.position);
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

      final equivalentForce =
          load.value * loadedLength;

      final center =
          load.position + loadedLength / 2;

      moment -=
          equivalentForce * (x - center);
    }

    // ----------------------------------------------------------
    // MOMENT APPLIQUÉ
    // ----------------------------------------------------------

    else if (load is MomentLoad) {
      if (load.position <= x) {
        moment -= load.value;
      }
    }
  }

  return moment;
}