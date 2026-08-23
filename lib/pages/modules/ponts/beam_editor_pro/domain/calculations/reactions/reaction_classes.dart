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