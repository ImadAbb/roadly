// ═══════════════════════════════════════════════════════════════
//  core/beam_models.dart
//  Modèles de données : BeamModel, BeamSupport, BeamLoad, BeamResults
// ═══════════════════════════════════════════════════════════════

// ─── Enums ──────────────────────────────────────────────────────

enum SupportType {
  simple,   // Appui simple  → RV uniquement (triangle + roues)
  double_,  // Appui double  → RV + RH       (triangle + double ligne)
  hinge,    // Rotule interne → articulation (cercle avec croix)
  fixed,    // Encastrement  → RV + RH + M   (rectangle hachuré)
}

enum LoadType {
  pointForce,
  pointMoment,
  distributedLoad,
  triangularLoad,
}

// ─── Appui ──────────────────────────────────────────────────────

class BeamSupport {
  final String id;
  SupportType type;
  double position;

  double reactionV = 0;
  double reactionH = 0;
  double reactionM = 0;

  BeamSupport({
    required this.id,
    required this.type,
    required this.position,
  });

  String get label {
    switch (type) {
      case SupportType.simple:  return 'Appui simple';
      case SupportType.double_: return 'Appui double';
      case SupportType.hinge:   return 'Rotule';
      case SupportType.fixed:   return 'Encastrement';
    }
  }

  String get reactionDescription {
    switch (type) {
      case SupportType.simple:  return 'RV';
      case SupportType.double_: return 'RV + RH';
      case SupportType.hinge:   return 'Articulation';
      case SupportType.fixed:   return 'RV + RH + M';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'position': position,
  };

  factory BeamSupport.fromJson(Map<String, dynamic> j) => BeamSupport(
    id: j['id'],
    type: SupportType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => SupportType.simple,
    ),
    position: (j['position'] as num).toDouble(),
  );

  BeamSupport copyWith({SupportType? type, double? position}) {
    final s = BeamSupport(
      id: id,
      type: type ?? this.type,
      position: position ?? this.position,
    );
    s.reactionV = reactionV;
    s.reactionH = reactionH;
    s.reactionM = reactionM;
    return s;
  }
}

// ─── Charge ─────────────────────────────────────────────────────

class BeamLoad {
  final String id;
  LoadType type;
  double position;
  double magnitude;
  double? endPosition;
  double? endMagnitude;
  String label;

  BeamLoad({
    required this.id,
    required this.type,
    required this.position,
    required this.magnitude,
    this.endPosition,
    this.endMagnitude,
    this.label = '',
  });

  bool get isDistributed =>
      type == LoadType.distributedLoad || type == LoadType.triangularLoad;

  double get resultant {
    if (!isDistributed) return magnitude;
    final len = (endPosition ?? position) - position;
    if (type == LoadType.distributedLoad) return magnitude * len;
    return 0.5 * (magnitude + (endMagnitude ?? 0)) * len;
  }

  double get resultantPosition {
    if (!isDistributed) return position;
    final len = (endPosition ?? position) - position;
    if (type == LoadType.distributedLoad) return position + len / 2;
    final q1 = magnitude, q2 = endMagnitude ?? 0;
    if ((q1 + q2) == 0) return position + len / 2;
    return position + len * (q1 + 2 * q2) / (3 * (q1 + q2));
  }

  /// Centre visuel de la charge pour la hitbox
  double get visualCenter {
    if (!isDistributed) return position;
    return (position + (endPosition ?? position)) / 2;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'position': position,
    'magnitude': magnitude,
    'endPosition': endPosition,
    'endMagnitude': endMagnitude,
    'label': label,
  };

  factory BeamLoad.fromJson(Map<String, dynamic> j) => BeamLoad(
    id: j['id'],
    type: LoadType.values.firstWhere(
      (e) => e.name == j['type'],
      orElse: () => LoadType.pointForce,
    ),
    position: (j['position'] as num).toDouble(),
    magnitude: (j['magnitude'] as num).toDouble(),
    endPosition: j['endPosition'] != null
        ? (j['endPosition'] as num).toDouble() : null,
    endMagnitude: j['endMagnitude'] != null
        ? (j['endMagnitude'] as num).toDouble() : null,
    label: j['label'] ?? '',
  );

  BeamLoad copyWith({
    LoadType? type,
    double? position,
    double? magnitude,
    double? endPosition,
    double? endMagnitude,
    String? label,
  }) => BeamLoad(
    id: id,
    type: type ?? this.type,
    position: position ?? this.position,
    magnitude: magnitude ?? this.magnitude,
    endPosition: endPosition ?? this.endPosition,
    endMagnitude: endMagnitude ?? this.endMagnitude,
    label: label ?? this.label,
  );
}

// ─── Point de diagramme ─────────────────────────────────────────

class DiagramPoint {
  final double x;
  final double v;
  final double m;

  const DiagramPoint({required this.x, required this.v, required this.m});
}

// ─── Résultats ──────────────────────────────────────────────────

class BeamResults {
  final List<DiagramPoint> points;
  final double maxShear;
  final double minShear;
  final double maxMoment;
  final double minMoment;
  final double posMaxMoment;
  final double posMaxShear;
  final bool   isValid;
  final String? warningMessage;

  const BeamResults({
    required this.points,
    required this.maxShear,
    required this.minShear,
    required this.maxMoment,
    required this.minMoment,
    required this.posMaxMoment,
    required this.posMaxShear,
    required this.isValid,
    this.warningMessage,
  });

  double shearAt(double x) => _interpolate(x, (p) => p.v);
  double momentAt(double x) => _interpolate(x, (p) => p.m);

  double _interpolate(double x, double Function(DiagramPoint) getter) {
    if (points.isEmpty) return 0;
    if (x <= points.first.x) return getter(points.first);
    if (x >= points.last.x)  return getter(points.last);
    int lo = 0, hi = points.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) ~/ 2;
      if (points[mid].x <= x) { lo = mid; } else { hi = mid; }
    }
    final t = (x - points[lo].x) / (points[hi].x - points[lo].x);
    return getter(points[lo]) + t * (getter(points[hi]) - getter(points[lo]));
  }

  Map<String, dynamic> toJson() => {
    'maxShear': maxShear, 'minShear': minShear,
    'maxMoment': maxMoment, 'minMoment': minMoment,
    'posMaxMoment': posMaxMoment, 'posMaxShear': posMaxShear,
    'isValid': isValid, 'warningMessage': warningMessage,
  };
}

// ─── Modèle principal ────────────────────────────────────────────

class BeamModel {
  String name;
  double length;
  List<BeamSupport> supports;
  List<BeamLoad> loads;
  BeamResults? results;

  BeamModel({
    this.name = 'Nouvelle poutre',
    this.length = 6.0,
    List<BeamSupport>? supports,
    List<BeamLoad>? loads,
    this.results,
  })  : supports = supports ?? [],
        loads = loads ?? [];

  List<String> validate() {
    final errors = <String>[];
    if (supports.isEmpty) {
      errors.add('Aucun appui défini.');
    }
    final hasFixed = supports.any((s) => s.type == SupportType.fixed);
    final countBearing = supports.where((s) => s.type != SupportType.hinge).length;
    if (!hasFixed && countBearing < 2) {
      errors.add('Au moins 2 appuis portants (ou 1 encastrement) nécessaires.');
    }
    for (final s in supports) {
      if (s.position < 0 || s.position > length) {
        errors.add('Appui "${s.label}" hors de la poutre.');
      }
    }
    for (final l in loads) {
      if (l.position < 0 || l.position > length) {
        errors.add('Une charge est hors de la poutre.');
      }
      if (l.isDistributed) {
        final end = l.endPosition ?? length;
        if (end > length + 1e-6) {
          errors.add('Charge répartie dépasse la longueur.');
        }
      }
    }
    if (loads.isEmpty) {
      errors.add('Aucune charge appliquée.');
    }
    return errors;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'length': length,
    'supports': supports.map((s) => s.toJson()).toList(),
    'loads': loads.map((l) => l.toJson()).toList(),
  };

  factory BeamModel.fromJson(Map<String, dynamic> j) => BeamModel(
    name: j['name'] ?? 'Poutre',
    length: (j['length'] as num).toDouble(),
    supports: (j['supports'] as List)
        .map((s) => BeamSupport.fromJson(s)).toList(),
    loads: (j['loads'] as List)
        .map((l) => BeamLoad.fromJson(l)).toList(),
  );

  // ── Modèles prédéfinis ────────────────────────────────────────

  /// Poutre bi-appuyée : appui SIMPLE à gauche + appui DOUBLE à droite
  static BeamModel simplySupported() => BeamModel(
    name: 'Poutre bi-appuyée',
    length: 6.0,
    supports: [
      BeamSupport(id: 's1', type: SupportType.simple,  position: 0),
      BeamSupport(id: 's2', type: SupportType.double_,  position: 6.0),
    ],
    loads: [
      BeamLoad(
        id: 'l1', type: LoadType.pointForce,
        position: 3.0, magnitude: 50, label: 'P = 50 kN',
      ),
    ],
  );

  static BeamModel cantilever() => BeamModel(
    name: 'Console',
    length: 4.0,
    supports: [
      BeamSupport(id: 's1', type: SupportType.fixed, position: 0),
    ],
    loads: [
      BeamLoad(
        id: 'l1', type: LoadType.distributedLoad,
        position: 0, endPosition: 4.0,
        magnitude: 20, label: 'q = 20 kN/m',
      ),
    ],
  );

  static BeamModel continuous() => BeamModel(
    name: 'Poutre continue',
    length: 10.0,
    supports: [
      BeamSupport(id: 's1', type: SupportType.double_, position: 0),
      BeamSupport(id: 's2', type: SupportType.simple,  position: 5.0),
      BeamSupport(id: 's3', type: SupportType.simple,  position: 10.0),
    ],
    loads: [
      BeamLoad(
        id: 'l1', type: LoadType.distributedLoad,
        position: 0, endPosition: 10.0,
        magnitude: 15, label: 'q = 15 kN/m',
      ),
    ],
  );
}
