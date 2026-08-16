enum SupportType { simple, double_, rotule, encastrement }

class BeamSupport {
  final String id;
  final SupportType type;
  final double position;
  final bool? encastrementSide;

  BeamSupport({
    required this.id,
    required this.type,
    required this.position,
    this.encastrementSide,
  });

  String get label {
    switch (type) {
      case SupportType.simple:
        return 'Appui simple';
      case SupportType.double_:
        return 'Appui double';
      case SupportType.rotule:
        return 'Rotule';
      case SupportType.encastrement:
        return encastrementSide == true ? "Encastrement droite" : "Encastrement gauche";
    }
  }

  BeamSupport copyWith({String? id, SupportType? type, double? position}) {
    return BeamSupport(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
    );
  }
}
