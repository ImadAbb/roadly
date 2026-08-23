// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/beam.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/load.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/support.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/calculations/shear/shear_calculator.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/calculations/reactions/reaction_calculator.dart';

void main() {
  group('Effort tranchant', () {
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

      final reactions = calculateReactions(beam);

      expect(
        calculateShearAt(beam, reactions, 2),
        closeTo(5, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 5),
        closeTo(5, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 7),
        closeTo(-5, 1e-9),
      );
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

      final reactions = calculateReactions(beam);

      expect(
        calculateShearAt(beam, reactions, 2),
        closeTo(7, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 4),
        closeTo(-3, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 8),
        closeTo(-3, 1e-9),
      );
    });

    test('Charge répartie uniforme', () {
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

      final reactions = calculateReactions(beam);

      expect(
        calculateShearAt(beam, reactions, 2),
        closeTo(6, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 5),
        closeTo(0, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 8),
        closeTo(-6, 1e-9),
      );
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

      final reactions = calculateReactions(beam);

      expect(
        calculateShearAt(beam, reactions, 1),
        closeTo(4.8, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 3),
        closeTo(2.8, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 5),
        closeTo(-1.2, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 8),
        closeTo(-3.2, 1e-9),
      );
    });

    test('Un moment ponctuel ne modifie pas directement T(x)', () {
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

      final reactions = calculateReactions(beam);

      // RA = 0.5, RB = -0.5 (voir reactions_test.dart)
      // Un moment ponctuel ne crée pas de discontinuité dans
      // l'effort tranchant : T(x) reste constant = RA sur
      // toute la travée.

      expect(
        calculateShearAt(beam, reactions, 2),
        closeTo(0.5, 1e-9),
      );

      expect(
        calculateShearAt(beam, reactions, 8),
        closeTo(0.5, 1e-9),
      );
    });
  });
}