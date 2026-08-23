// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/beam.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/load.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/models/support.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/calculations/moment/moment_calculator.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_pro/domain/calculations/reactions/reaction_calculator.dart';

void main() {
  // ============================================================
  // OUTIL
  // ============================================================

  Beam simplySupportedBeam({
    required double length,
    List<Load> loads = const [],
  }) {
    return Beam(
      beamLength: length,
      supports: [
        Support(id: 'A', position: 0.0, type: SupportType.double_),
        Support(id: 'B', position: length, type: SupportType.simple_),
      ],
      loads: loads,
    );
  }

  // ============================================================
  // 1. AUCUNE CHARGE
  // ============================================================

  test('Moment - aucune charge', () {
    final beam = simplySupportedBeam(length: 10.0);
    final reactions = calculateReactions(beam);

    expect(calculateMomentAt(beam, reactions, 0.0), closeTo(0.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 5.0), closeTo(0.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 10.0), closeTo(0.0, 1e-9));
  });

  // ============================================================
  // 2. CHARGE PONCTUELLE CENTRÉE
  // ============================================================

  test('Moment - charge ponctuelle centrée', () {
    final beam = simplySupportedBeam(
      length: 10.0,
      loads: [PointLoad('P1', 5.0, 10.0)],
    );

    final reactions = calculateReactions(beam);

    expect(calculateMomentAt(beam, reactions, 0.0), closeTo(0.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 5.0), closeTo(25.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 10.0), closeTo(0.0, 1e-9));
  });

  // ============================================================
  // 3. CHARGE PONCTUELLE NON CENTRÉE
  // ============================================================

  test('Moment - charge ponctuelle non centrée', () {
    final beam = simplySupportedBeam(
      length: 10.0,
      loads: [PointLoad('P1', 4.0, 10.0)],
    );

    final reactions = calculateReactions(beam);

    // RA = 6 kN, RB = 4 kN
    expect(calculateMomentAt(beam, reactions, 0.0), closeTo(0.0, 1e-9));

    // M(4) = RA × 4 = 6 × 4 = 24 kN.m
    expect(calculateMomentAt(beam, reactions, 4.0), closeTo(24.0, 1e-9));

    expect(calculateMomentAt(beam, reactions, 10.0), closeTo(0.0, 1e-9));
  });

  // ============================================================
  // 4. CHARGE RÉPARTIE UNIFORME SUR TOUTE LA POUTRE
  // ============================================================

  test('Moment - charge répartie uniforme sur toute la poutre', () {
    final beam = simplySupportedBeam(
      length: 10.0,
      loads: [DistributedLoad('Q1', 0.0, 10.0, 2.0)],
    );

    final reactions = calculateReactions(beam);

    // Mmax = qL² / 8 = 2 × 100 / 8 = 25 kN.m
    expect(calculateMomentAt(beam, reactions, 0.0), closeTo(0.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 5.0), closeTo(25.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 10.0), closeTo(0.0, 1e-9));
  });

  // ============================================================
  // 5. CHARGE RÉPARTIE PARTIELLE
  // ============================================================

  test('Moment - charge répartie partielle', () {
    final beam = simplySupportedBeam(
      length: 10.0,
      loads: [DistributedLoad('Q1', 2.0, 6.0, 2.0)],
    );

    final reactions = calculateReactions(beam);

    // W = 8 kN, centre = 4 m, RB = 3.2 kN, RA = 4.8 kN
    expect(calculateMomentAt(beam, reactions, 0.0), closeTo(0.0, 1e-9));

    // M(2) = RA × 2 = 9.6 kN.m
    expect(calculateMomentAt(beam, reactions, 2.0), closeTo(9.6, 1e-9));

    // M(4) = RA×4 - 4×(4-3) = 19.2 - 4 = 15.2 kN.m
    expect(calculateMomentAt(beam, reactions, 4.0), closeTo(15.2, 1e-9));

    // M(6) = RA×6 - 8×(6-4) = 28.8 - 16 = 12.8 kN.m
    expect(calculateMomentAt(beam, reactions, 6.0), closeTo(12.8, 1e-9));

    expect(calculateMomentAt(beam, reactions, 10.0), closeTo(0.0, 1e-9));
  });

  // ============================================================
  // 6. CHARGE RÉPARTIE PARTIELLE - AVANT LA ZONE CHARGÉE
  // ============================================================

  test('Moment - avant une charge répartie partielle', () {
    final beam = simplySupportedBeam(
      length: 10.0,
      loads: [DistributedLoad('Q1', 4.0, 8.0, 2.0)],
    );

    final reactions = calculateReactions(beam);

    // W = 8 kN, centre = 6 m, RB = 4.8 kN, RA = 3.2 kN
    // M(2) = RA × 2 = 6.4
    expect(calculateMomentAt(beam, reactions, 2.0), closeTo(6.4, 1e-9));
  });

  // ============================================================
  // 7. MOMENT PONCTUEL APPLIQUÉ
  // ============================================================
  //
  // M0 = +10 kN.m à x = 5, poutre simplement appuyée (0-10).
  //
  // Équilibre (moments autour de A) :
  //   RB × 10 + M0 = 0 => RB = -1 kN
  //   RA = -RB = +1 kN  (pas de charge verticale, ΣFy=0)
  //
  // Avant x=5 : M(x) = RA × x
  //   M(4.999) ≈ 4.999
  //
  // Après x=5 : M(x) = RA × x - M0
  //   M(5.001) ≈ 5.001 - 10 = -4.999
  //
  // Saut au point d'application = -M0 = -10

  test('Moment - moment ponctuel appliqué', () {
    final beam = simplySupportedBeam(
      length: 10.0,
      loads: [MomentLoad('M1', 5.0, 10.0)],
    );

    final reactions = calculateReactions(beam);

    final m0 = calculateMomentAt(beam, reactions, 0.0);
    final mBefore = calculateMomentAt(beam, reactions, 4.999);
    final mAfter = calculateMomentAt(beam, reactions, 5.001);
    final m10 = calculateMomentAt(beam, reactions, 10.0);

    expect(m0, closeTo(0.0, 1e-9));
    expect(mBefore, closeTo(4.999, 1e-3));
    expect(mAfter, closeTo(-4.999, 1e-3));
    expect(m10, closeTo(0.0, 1e-9));

    // Le saut au point d'application doit être égal à -M0 = -10 kN.m
    expect(mAfter - mBefore, closeTo(-10.0, 1e-2));
  });

  // ============================================================
  // 8. CHARGE PONCTUELLE VERS LE HAUT
  // ============================================================

  test('Moment - charge ponctuelle vers le haut', () {
    final beam = simplySupportedBeam(
      length: 10.0,
      loads: [PointLoad('P1', 5.0, -10.0)],
    );

    final reactions = calculateReactions(beam);

    expect(calculateMomentAt(beam, reactions, 0.0), closeTo(0.0, 1e-9));

    // RA = RB = -5 kN, M(5) = RA×5 = -25 kN.m
    expect(calculateMomentAt(beam, reactions, 5.0), closeTo(-25.0, 1e-9));

    expect(calculateMomentAt(beam, reactions, 10.0), closeTo(0.0, 1e-9));
  });

  // ============================================================
  // 9. ENCASTREMENT - CHARGE PONCTUELLE
  // ============================================================
  //
  // Console encastrée en x=0, charge P=10 kN (vers le bas) à x=5.
  //
  // RAy = 10, mA = 50 (voir reaction_calculator).
  //
  // M(x) = RAy×x - mA - Σ(charges à gauche)
  //   M(0) = 0 - 50 = -50
  //   M(5) = 50 - 50 - 0 = 0   (juste avant la charge)
  //   M(10) = 100 - 50 - 10×5 = 0

  test('Moment - encastrement avec charge ponctuelle', () {
    final beam = Beam(
      beamLength: 10.0,
      supports: [
        Support(id: 'A', position: 0.0, type: SupportType.encastrement_),
      ],
      loads: [PointLoad('P1', 5.0, 10.0)],
    );

    final reactions = calculateReactions(beam);

    expect(calculateMomentAt(beam, reactions, 0.0), closeTo(-50.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 5.0), closeTo(0.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 10.0), closeTo(0.0, 1e-9));
  });

  // ============================================================
  // 10. ENCASTREMENT - CHARGE RÉPARTIE
  // ============================================================
  //
  // Console encastrée en x=0, charge répartie q=2 kN/m sur 0-10.
  //
  // RAy = 20, mA = 100.
  //
  // M(0) = 0 - 100 = -100
  // M(5) = 100 - 100 - 2×5×2.5 = -25
  // M(10) = 200 - 100 - 2×10×5 = 0

  test('Moment - encastrement avec charge répartie', () {
    final beam = Beam(
      beamLength: 10.0,
      supports: [
        Support(id: 'A', position: 0.0, type: SupportType.encastrement_),
      ],
      loads: [DistributedLoad('Q1', 0.0, 10.0, 2.0)],
    );

    final reactions = calculateReactions(beam);

    expect(calculateMomentAt(beam, reactions, 0.0), closeTo(-100.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 5.0), closeTo(-25.0, 1e-9));
    expect(calculateMomentAt(beam, reactions, 10.0), closeTo(0.0, 1e-9));
  });
}