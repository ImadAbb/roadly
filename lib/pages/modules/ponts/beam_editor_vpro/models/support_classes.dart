enum SupportType {
  simple_,
  double_,
  encastrement_,
  rotule_,
}

class Support {
  final String id;
  final double position;
  final SupportType type;
  final bool? isEncastrementRightSide;

  Support({
    required this.id,
    required this.position,
    required this.type,
    this.isEncastrementRightSide,
  });
}

String supportLabel(Support support) {
  switch (support.type) {
    case SupportType.simple_:
      return "Appui simple";
    case SupportType.double_:
      return "Appui double";
    case SupportType.encastrement_:
      return support.isEncastrementRightSide == true
          ? "Encastrement à droite"
          : "Encastrement à gauche";
    case SupportType.rotule_:
      return "Appui rotule";
  }
}
