import '../models/beam.dart';
import '../models/support.dart';

int calculateDegreeOfHyperstaticity(Beam beam) {
  final externalUnknowns = _countExternalSupportUnknowns(beam);
  final internalHinges = _countInternalHinges(beam);

  return externalUnknowns - 3 - internalHinges;
}

int _countExternalSupportUnknowns(Beam beam) {
  var unknowns = 0;

  for (final support in beam.supports) {
    switch (support.type) {
      case SupportType.simple_:
        unknowns += 1;
        break;

      case SupportType.double_:
        unknowns += 2;
        break;

      case SupportType.rotule_:
        break;

      case SupportType.encastrement_:
        unknowns += 3;
        break;
    }
  }

  return unknowns;
}

int _countInternalHinges(Beam beam) {
  var hinges = 0;

  for (final support in beam.supports) {
    if (support.type == SupportType.rotule_) {
      hinges++;
    }
  }

  return hinges;
}

enum StaticSystemType {
  isostatique,
  hyperstatique,
  hypostatique,
}

StaticSystemType getStaticSystemType(Beam beam) {
  final h = calculateDegreeOfHyperstaticity(beam);

  if (h == 0) {
    return StaticSystemType.isostatique;
  }

  if (h > 0) {
    return StaticSystemType.hyperstatique;
  }

  return StaticSystemType.hypostatique;
}