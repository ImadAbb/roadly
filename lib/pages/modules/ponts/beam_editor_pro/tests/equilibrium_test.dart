// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/beam.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/load.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/support.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/calculations/equilibrium/equilibrium_calculator.dart';

void main() {
  test('Équilibre - charge ponctuelle centrée', () {
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
      loads: [
        PointLoad('P1', 5, 10),
      ],
    );

    final result = calculateEquilibrium(beam);

    expect(result.verticalForce, closeTo(0, 1e-9));
    expect(result.moment, closeTo(0, 1e-9));
    expect(result.isBalanced, isTrue);
  });

  test('Équilibre - charge répartie', () {
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
      loads: [
        DistributedLoad('Q1', 0, 10, 2),
      ],
    );

    final result = calculateEquilibrium(beam);

    expect(result.verticalForce, closeTo(0, 1e-9));
    expect(result.moment, closeTo(0, 1e-9));
    expect(result.isBalanced, isTrue);
  });

  test('Équilibre - plusieurs charges', () {
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
      loads: [
        PointLoad('P1', 2, 10),
        PointLoad('P2', 8, 10),
        DistributedLoad('Q1', 3, 7, 2),
      ],
    );

    final result = calculateEquilibrium(beam);

    expect(result.verticalForce, closeTo(0, 1e-9));
    expect(result.moment, closeTo(0, 1e-9));
    expect(result.isBalanced, isTrue);
  });

  test('Équilibre - encastrement', () {
    final beam = Beam(
      beamLength: 10,
      supports: [
        Support(
          id: 'A',
          position: 0,
          type: SupportType.encastrement_,
        ),
      ],
      loads: [
        PointLoad('P1', 5, 10),
      ],
    );

    final result = calculateEquilibrium(beam);

    expect(result.verticalForce, closeTo(0, 1e-9));
    expect(result.moment, closeTo(0, 1e-9));
    expect(result.isBalanced, isTrue);
  });

  test('Équilibre - aucune charge', () {
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

    final result = calculateEquilibrium(beam);

    expect(result.verticalForce, closeTo(0, 1e-9));
    expect(result.moment, closeTo(0, 1e-9));
    expect(result.isBalanced, isTrue);
  });
}