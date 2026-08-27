import '../../models/beam.dart';
import '../../models/load.dart';
import '../common/calculation_point.dart';
import '../common/calculation_tolerance.dart';
import '../critical_positions/extract_critical_positions.dart';
import '../reactions/reaction_calculator.dart';
import '../reactions/reaction_classes.dart';
import 'shear_classes.dart';

/// Calcule l'effort tranchant T(x) sur toute la poutre.
///
/// Principe : on avance de gauche à droite, position critique par
/// position critique. À chaque position on "coupe" la poutre et on
/// calcule T par équilibre de tout ce qui est à gauche de la coupe.
///
/// Aux positions de Support et PointLoad, T fait un SAUT (force
/// concentrée) → on calcule 2 valeurs : juste avant et juste après.
/// Ailleurs (bornes, début/fin de DistributedLoad), T est continu
/// → une seule valeur suffit.
ShearResult calculateShear(Beam beam) {
  final reactions = calculateReactions(beam);
  final positions = extractCriticalPositions(beam);

  if (positions.isEmpty) {
    return const ShearResult();
  }

  final points = <CalculationPoint>[];

  for (final x in positions) {
    if (_hasJumpAt(beam, x)) {
      // Coupe juste AVANT x : le support/la charge à x n'est
      // pas encore compté comme "à gauche".
      points.add(CalculationPoint(
        position: x,
        value: _shearAt(beam, reactions, x, includeAt: false),
      ));

      // Coupe juste APRÈS x : le support/la charge à x est
      // maintenant inclus dans "à gauche".
      points.add(CalculationPoint(
        position: x,
        value: _shearAt(beam, reactions, x, includeAt: true),
      ));
    } else {
      // Pas de saut ici : une seule valeur.
      points.add(CalculationPoint(
        position: x,
        value: _shearAt(beam, reactions, x, includeAt: true),
      ));
    }
  }

  return ShearResult(points: points);
}

/// Un saut de T n'existe qu'aux positions où une force verticale
/// concentrée est appliquée : un Support (réaction) ou un PointLoad.
/// Une DistributedLoad ne crée jamais de saut, seulement un
/// changement de pente à son début/sa fin.
bool _hasJumpAt(Beam beam, double x) {
  final hasSupport = beam.supports.any(
    (support) => CalculationTolerance.nearlyEqual(support.position, x),
  );

  final hasPointLoad = beam.loads.any(
    (load) =>
        load is PointLoad &&
        CalculationTolerance.nearlyEqual(load.position, x),
  );

  return hasSupport || hasPointLoad;
}

/// T(x) par équilibre de la partie gauche de la coupe :
///
///   T(x) = Σ réactions à gauche
///        − Σ PointLoad.value à gauche
///        − Σ forces équivalentes des DistributedLoad traversées
///
/// [includeAt] distingue "juste avant" (false, strict <) de
/// "juste après" (true, <=) la position x — c'est ce qui produit
/// les deux valeurs différentes à une position de saut.
double _shearAt(
  Beam beam,
  ReactionResult reactions,
  double x, {
  required bool includeAt,
}) {
  double shear = 0.0;

  // ---- Réactions d'appuis à gauche de la coupe ----
  for (final support in beam.supports) {
    final isLeft = includeAt ? support.position <= x : support.position < x;

    if (isLeft) {
      final r = reactions.getReaction(support.id);
      if (r != null) shear += r;
    }
  }

  // ---- Charges à gauche de la coupe ----
  for (final load in beam.loads) {
    if (load is PointLoad) {
      final isLeft = includeAt ? load.position <= x : load.position < x;
      if (isLeft) shear -= load.value;
    } else if (load is DistributedLoad) {
      // Rien de la charge n'est encore traversé.
      if (x <= load.position) continue;

      // Portion de la charge répartie déjà traversée (partielle
      // ou totale, selon si la coupe tombe avant ou après la fin).
      final end = x < load.positionEnd ? x : load.positionEnd;
      final loadedLength = end - load.position;
      if (loadedLength <= 0) continue;

      shear -= load.value * loadedLength;
    }
    // MomentLoad : aucune composante verticale -> pas de contribution à T(x).
  }

  return shear;
}