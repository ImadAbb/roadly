import '../models/beam_classes.dart';
import '../models/load_classes.dart';
import '../models/support_classes.dart';
import 'hyperstaticity.dart';

/// Résultat du calcul des réactions d'appui.
///
/// verticalReactions contient la réaction verticale de chaque appui
/// avec son ID.
///
/// Exemple :
///
/// {
///   "support_1": 6.0,
///   "support_2": 4.0,
/// }
///
/// Convention :
///
/// réaction positive = vers le haut ↑
/// réaction négative = vers le bas ↓
///
/// mA = moment de réaction d'un encastrement.
class ReactionResult {
  final Map<String, double> verticalReactions;
  final double? mA;

  const ReactionResult({
    this.verticalReactions = const {},
    this.mA,
  });

  /// Retourne la réaction verticale d'un appui.
  double? getReaction(String supportId) {
    return verticalReactions[supportId];
  }
}

/// Calcule les réactions d'une poutre.
///
/// Pour le moment, seules les structures isostatiques
/// (h = 0) sont calculées.
///
/// Convention des charges :
///
/// PointLoad / DistributedLoad :
///   valeur positive = charge vers le bas ↓
///   valeur négative = charge vers le haut ↑
///
/// MomentLoad :
///   valeur positive = moment antihoraire ↺
///   valeur négative = moment horaire ↻
ReactionResult calculateReactions(Beam beam) {
  // ============================================================
  // DEGRÉ D'HYPERSTATICITÉ
  // ============================================================

  final h = calculateDegreeOfHyperstaticity(beam);

  // Pour le moment, uniquement les structures isostatiques.
  if (h != 0) {
    return const ReactionResult();
  }

  final supports = beam.supports;

  // ============================================================
  // 1. ENCASTREMENT
  // ============================================================

  final encastrements = supports
      .where(
        (support) => support.type == SupportType.encastrement_,
      )
      .toList();

  if (encastrements.isNotEmpty) {
    return _calculateEncastrementReaction(
      beam,
      encastrements.first,
    );
  }

  // ============================================================
  // 2. APPUIS VERTICAUX
  // ============================================================

  final verticalSupports = supports
      .where(
        (support) =>
            support.type == SupportType.simple_ ||
            support.type == SupportType.double_,
      )
      .toList()
    ..sort(
      (a, b) => a.position.compareTo(b.position),
    );

  // Deux appuis
  if (verticalSupports.length >= 2) {
    return _calculateTwoSupportReactions(
      beam,
      verticalSupports[0],
      verticalSupports[1],
    );
  }

  // ============================================================
  // 3. UN SEUL APPUI
  // ============================================================

  if (verticalSupports.length == 1) {
    return _calculateSingleSupportReaction(
      beam,
      verticalSupports.first,
    );
  }

  // ============================================================
  // 4. RIEN À CALCULER
  // ============================================================

  return const ReactionResult();
}

// ==================================================================
// ENCASTREMENT
// ==================================================================

ReactionResult _calculateEncastrementReaction(
  Beam beam,
  Support support,
) {
  final xA = support.position;

  double totalForce = 0.0;
  double totalMoment = 0.0;

  for (final load in beam.loads) {
    // ------------------------------------------------------------
    // FORCE PONCTUELLE
    // ------------------------------------------------------------

    if (load is PointLoad) {
      final force = -load.value;

      totalForce += force;

      totalMoment +=
          force * (load.position - xA);
    }

    // ------------------------------------------------------------
    // CHARGE RÉPARTIE
    // ------------------------------------------------------------

    else if (load is DistributedLoad) {
      final length =
          load.positionEnd - load.position;

      final equivalentForce =
          load.value * length;

      final center =
          (load.position + load.positionEnd) / 2;

      final force = -equivalentForce;

      totalForce += force;

      totalMoment +=
          force * (center - xA);
    }

    // ------------------------------------------------------------
    // MOMENT APPLIQUÉ
    // ------------------------------------------------------------

    else if (load is MomentLoad) {
      totalMoment += load.value;
    }
  }

  // Équilibre vertical :
  //
  // RAy + ΣFy = 0

  final rAy = -totalForce;

  // Équilibre des moments :
  //
  // MA + ΣM = 0

  final mA = -totalMoment;

  return ReactionResult(
    verticalReactions: {
      support.id: rAy,
    },
    mA: mA,
  );
}

// ==================================================================
// DEUX APPUIS
// ==================================================================

ReactionResult _calculateTwoSupportReactions(
  Beam beam,
  Support supportA,
  Support supportB,
) {
  final xA = supportA.position;
  final xB = supportB.position;

  final distanceAB = xB - xA;

  // Sécurité : les deux appuis ne peuvent pas être
  // exactement au même endroit.

  if (distanceAB.abs() < 0.000001) {
    return const ReactionResult();
  }

  double totalForce = 0.0;
  double totalMomentA = 0.0;

  for (final load in beam.loads) {
    // ------------------------------------------------------------
    // FORCE PONCTUELLE
    // ------------------------------------------------------------

    if (load is PointLoad) {
      final force = -load.value;

      totalForce += force;

      totalMomentA +=
          force * (load.position - xA);
    }

    // ------------------------------------------------------------
    // CHARGE RÉPARTIE
    // ------------------------------------------------------------

    else if (load is DistributedLoad) {
      final length =
          load.positionEnd - load.position;

      final equivalentForce =
          load.value * length;

      final center =
          (load.position + load.positionEnd) / 2;

      final force = -equivalentForce;

      totalForce += force;

      totalMomentA +=
          force * (center - xA);
    }

    // ------------------------------------------------------------
    // MOMENT APPLIQUÉ
    // ------------------------------------------------------------

    else if (load is MomentLoad) {
      totalMomentA += load.value;
    }
  }

  // ============================================================
  // MOMENTS AUTOUR DE A
  //
  // RBy × (xB - xA) + ΣMA = 0
  //
  // ============================================================

  final rBy =
      -totalMomentA / distanceAB;

  // ============================================================
  // FORCES VERTICALES
  //
  // RAy + RBy + ΣFy = 0
  //
  // ============================================================

  final rAy =
      -totalForce - rBy;

  return ReactionResult(
    verticalReactions: {
      supportA.id: rAy,
      supportB.id: rBy,
    },
  );
}

// ==================================================================
// UN SEUL APPUI
// ==================================================================

ReactionResult _calculateSingleSupportReaction(
  Beam beam,
  Support support,
) {
  double totalForce = 0.0;

  for (final load in beam.loads) {
    // ------------------------------------------------------------
    // FORCE PONCTUELLE
    // ------------------------------------------------------------

    if (load is PointLoad) {
      totalForce += -load.value;
    }

    // ------------------------------------------------------------
    // CHARGE RÉPARTIE
    // ------------------------------------------------------------

    else if (load is DistributedLoad) {
      final length =
          load.positionEnd - load.position;

      final equivalentForce =
          load.value * length;

      totalForce += -equivalentForce;
    }
  }

  // Équilibre vertical :
  //
  // R + ΣFy = 0

  final reaction = -totalForce;

  return ReactionResult(
    verticalReactions: {
      support.id: reaction,
    },
  );
}