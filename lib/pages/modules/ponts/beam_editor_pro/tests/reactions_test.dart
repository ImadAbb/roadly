// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/beam.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/load.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/support.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/calculations/reactions/reaction_calculator.dart';

void main() {
  group('Réactions', () {
    test('Charge ponctuelle centrée', () {
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

      final result = calculateReactions(beam);

      expect(result.getReaction('A'), closeTo(5, 1e-9));
      expect(result.getReaction('B'), closeTo(5, 1e-9));
    });

    test('Charge ponctuelle non centrée', () {
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
          PointLoad('P1', 3, 10),
        ],
      );

      final result = calculateReactions(beam);

      expect(result.getReaction('A'), closeTo(7, 1e-9));
      expect(result.getReaction('B'), closeTo(3, 1e-9));
    });

    test('Charge répartie uniforme sur toute la poutre', () {
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

      final result = calculateReactions(beam);

      expect(result.getReaction('A'), closeTo(10, 1e-9));
      expect(result.getReaction('B'), closeTo(10, 1e-9));
    });

    test('Charge répartie partielle', () {
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
          DistributedLoad('Q1', 2, 6, 2),
        ],
      );

      final result = calculateReactions(beam);

      // Charge totale = 2 × 4 = 8
      //
      // Résultante à x = 4
      //
      // RB × 10 = 8 × 4
      // RB = 3.2
      //
      // RA = 8 - 3.2 = 4.8

      expect(result.getReaction('A'), closeTo(4.8, 1e-9));
      expect(result.getReaction('B'), closeTo(3.2, 1e-9));
    });

    test('Moment appliqué', () {
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
          MomentLoad('M1', 10, 5),
        ],
      );

      final result = calculateReactions(beam);

      // M0 = 5 kN.m, distanceAB = 10
      // RB × 10 + M0 = 0 => RB = -0.5
      // RA = -RB = 0.5

      expect(result.getReaction('A'), closeTo(0.5, 1e-9));
      expect(result.getReaction('B'), closeTo(-0.5, 1e-9));
    });
  });
}