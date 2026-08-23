// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/beam.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/support.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/calculations/common/hyperstaticity.dart';

void main() {
  test('Hyperstaticité - poutre isostatique', () {
    final beam = Beam(
      beamLength: 10,
      supports: [
        Support(
          id: 'A',
          position: 0,
          type: SupportType.double_,
        ),
        Support(
          id: 'B',
          position: 10,
          type: SupportType.simple_,
        ),
      ],
      loads: [],
    );

    expect(
      calculateDegreeOfHyperstaticity(beam),
      equals(0),
    );

    expect(
      getStaticSystemType(beam),
      equals(StaticSystemType.isostatique),
    );
  });

  test('Hyperstaticité - poutre hyperstatique', () {
    final beam = Beam(
      beamLength: 10,
      supports: [
        Support(
          id: 'A',
          position: 0,
          type: SupportType.double_,
        ),
        Support(
          id: 'B',
          position: 5,
          type: SupportType.simple_,
        ),
        Support(
          id: 'C',
          position: 10,
          type: SupportType.simple_,
        ),
      ],
      loads: [],
    );

    expect(
      calculateDegreeOfHyperstaticity(beam),
      greaterThan(0),
    );

    expect(
      getStaticSystemType(beam),
      equals(StaticSystemType.hyperstatique),
    );
  });

  test('Hyperstaticité - poutre hypostatique', () {
    final beam = Beam(
      beamLength: 10,
      supports: [
        Support(
          id: 'A',
          position: 0,
          type: SupportType.simple_,
        ),
      ],
      loads: [],
    );

    expect(
      calculateDegreeOfHyperstaticity(beam),
      lessThan(0),
    );

    expect(
      getStaticSystemType(beam),
      equals(StaticSystemType.hypostatique),
    );
  });

  test('Hyperstaticité - encastrement seul', () {
    final beam = Beam(
      beamLength: 10,
      supports: [
        Support(
          id: 'A',
          position: 0,
          type: SupportType.encastrement_,
        ),
      ],
      loads: [],
    );

    expect(
      calculateDegreeOfHyperstaticity(beam),
      equals(0),
    );

    expect(
      getStaticSystemType(beam),
      equals(StaticSystemType.isostatique),
    );
  });
}