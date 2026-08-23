// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/beam.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/load.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/support.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/calculations/loads/load_positions.dart';

void main() {
  test('Positions - poutre vide', () {
    final beam = Beam(
      beamLength: 10,
      supports: [],
      loads: [],
    );

    final positions =
        LoadPositions.importantPositions(beam);

    expect(
      positions,
      equals([0, 10]),
    );
  });

  test('Positions - charge ponctuelle', () {
    final beam = Beam(
      beamLength: 10,
      supports: [],
      loads: [
        PointLoad('P1', 5, 10),
      ],
    );

    final positions =
        LoadPositions.importantPositions(beam);

    expect(
      positions,
      equals([0, 5, 10]),
    );
  });

  test('Positions - charge répartie', () {
    final beam = Beam(
      beamLength: 10,
      supports: [],
      loads: [
        DistributedLoad('Q1', 2, 7, 2),
      ],
    );

    final positions =
        LoadPositions.importantPositions(beam);

    expect(
      positions,
      equals([0, 2, 7, 10]),
    );
  });

  test('Positions - moment ponctuel', () {
    final beam = Beam(
      beamLength: 10,
      supports: [],
      loads: [
        MomentLoad('M1', 5, 10),
      ],
    );

    final positions =
        LoadPositions.importantPositions(beam);

    expect(
      positions,
      equals([0, 5, 10]),
    );
  });

  test('Positions - appuis inclus', () {
    final beam = Beam(
      beamLength: 10,
      supports: [
        Support(
          id: 'A',
          position: 2,
          type: SupportType.double_,
        ),
        Support(
          id: 'B',
          position: 8,
          type: SupportType.simple_,
        ),
      ],
      loads: [],
    );

    final positions =
        LoadPositions.importantPositions(beam);

    expect(
      positions,
      equals([0, 2, 8, 10]),
    );
  });

  test('Positions - doublons supprimés', () {
    final beam = Beam(
      beamLength: 10,
      supports: [
        Support(
          id: 'A',
          position: 5,
          type: SupportType.double_,
        ),
      ],
      loads: [
        PointLoad('P1', 5, 10),
        DistributedLoad('Q1', 5, 8, 2),
        MomentLoad('M1', 5, 10),
      ],
    );

    final positions =
        LoadPositions.importantPositions(beam);

    expect(
      positions,
      equals([0, 5, 8, 10]),
    );
  });
}