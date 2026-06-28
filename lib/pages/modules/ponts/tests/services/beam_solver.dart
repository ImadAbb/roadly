// ═══════════════════════════════════════════════════════════════
//  beam_solver.dart  —  Calcul V(x) et M(x)
//  Sans calcul de flèche (section supprimée)
//  Importer : import '../services/beam_solver.dart';
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import '../models/beam_models.dart';

class BeamSolver {
  static const int _nPoints = 500;

  // ── Point d'entrée ───────────────────────────────────────────
  static BeamResults solve(BeamModel beam) {
    final supports = List<BeamSupport>.from(beam.supports)
      ..sort((a, b) => a.position.compareTo(b.position));

    // Appuis portants (hinge = articulation interne, pas de réaction externe)
    final bearing = supports
        .where((s) => s.type != SupportType.hinge)
        .toList();

    final dof = _countReactions(bearing) - 3;

    BeamResults res;
    if (dof < 0) {
      res = _empty('Structure instable — ajoutez des appuis portants.');
    } else if (dof == 0) {
      res = _solveIsostatic(beam, bearing);
    } else {
      res = _solveHyperstatic(beam, bearing);
    }

    // Répercuter les réactions sur le modèle
    for (final s in beam.supports) {
      final found = bearing.where((b) => b.id == s.id).firstOrNull;
      if (found != null) {
        s.reactionV = found.reactionV;
        s.reactionH = found.reactionH;
        s.reactionM = found.reactionM;
      }
    }
    return res;
  }

  // ── Comptage des inconnues de réaction ───────────────────────
  static int _countReactions(List<BeamSupport> bearing) {
    int r = 0;
    for (final s in bearing) {
      switch (s.type) {
        case SupportType.simple:  r += 1; break; // RV
        case SupportType.double_: r += 2; break; // RV + RH
        case SupportType.fixed:   r += 3; break; // RV + RH + M
        case SupportType.hinge:   break;          // pas de réaction externe
      }
    }
    return r;
  }

  // ── Résolution isostatique ────────────────────────────────────
  static BeamResults _solveIsostatic(
      BeamModel beam, List<BeamSupport> bearing) {
    double totalV = 0, totalM = 0;
    for (final l in beam.loads) {
      if (l.type == LoadType.pointMoment) {
        totalM += l.magnitude;
      } else {
        totalV += l.resultant;
        totalM += l.resultant * l.resultantPosition;
      }
    }

    // Cas 1 : encastrement seul
    final fixedList = bearing.where((s) => s.type == SupportType.fixed).toList();
    if (fixedList.length == 1 && bearing.length == 1) {
      final s = fixedList.first;
      s.reactionV = totalV;
      s.reactionH = 0;
      s.reactionM = -(totalM - totalV * s.position);
      return _buildDiagrams(beam, bearing);
    }

    // Cas 2 : 2 appuis verticaux
    final vert = bearing.where((s) => s.type != SupportType.hinge).toList();
    if (vert.length == 2) {
      final sA = vert[0], sB = vert[1];
      final L = sB.position - sA.position;
      if (L.abs() < 1e-9) return _empty('Deux appuis à la même position.');
      sB.reactionV = (totalM - totalV * sA.position) / L;
      sA.reactionV = totalV - sB.reactionV;
      sA.reactionH = sB.reactionH = 0;
      return _buildDiagrams(beam, bearing);
    }

    if (bearing.length >= 3) return _solveHyperstatic(beam, bearing);
    return _empty('Configuration d\'appuis non reconnue.');
  }

  // ── Résolution hyperstatique (3 moments — Clapeyron) ─────────
  static BeamResults _solveHyperstatic(
      BeamModel beam, List<BeamSupport> bearing) {
    final pins = bearing
        .where((s) =>
            s.type == SupportType.simple || s.type == SupportType.double_)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    if (pins.length < 3) return _solveIsostatic(beam, bearing);

    final n = pins.length;
    final nSpans = n - 1;
    final L = List<double>.generate(
        nSpans, (i) => pins[i + 1].position - pins[i].position);

    final bLeft  = List<double>.filled(nSpans, 0);
    final bRight = List<double>.filled(nSpans, 0);

    for (final load in beam.loads) {
      if (load.type == LoadType.pointMoment) continue;
      for (int i = 0; i < nSpans; i++) {
        final xL = pins[i].position, xR = pins[i + 1].position;
        final Ls = L[i];
        if (load.isDistributed) {
          final qS = math.max(load.position, xL);
          final qE = math.min(load.endPosition ?? beam.length, xR);
          if (qE <= qS) continue;
          final ratio = (qE - qS) / Ls;
          final q = load.magnitude;
          bLeft[i]  += q * Ls * Ls * Ls / 4 * ratio;
          bRight[i] += q * Ls * Ls * Ls / 4 * ratio;
        } else if (load.type == LoadType.pointForce) {
          if (load.position < xL || load.position > xR) continue;
          final a = load.position - xL;
          final b = Ls - a;
          final P = load.magnitude;
          bLeft[i]  += P * b * (Ls * Ls - b * b) / Ls;
          bRight[i] += P * a * (Ls * Ls - a * a) / Ls;
        }
      }
    }

    final nInt = n - 2;
    if (nInt == 0) return _solveIsostatic(beam, bearing);

    final aT = List<double>.filled(nInt, 0);
    final bT = List<double>.filled(nInt, 0);
    final cT = List<double>.filled(nInt, 0);
    final dT = List<double>.filled(nInt, 0);

    for (int k = 0; k < nInt; k++) {
      final i = k + 1;
      aT[k] = k > 0 ? L[i - 1] : 0;
      bT[k] = 2 * (L[i - 1] + L[i]);
      cT[k] = k < nInt - 1 ? L[i] : 0;
      dT[k] = -6 * (bRight[i - 1] / L[i - 1] + bLeft[i] / L[i]);
    }

    final M = _thomas(aT, bT, cT, dT);
    final allM = [0.0, ...M, 0.0];
    final reactV = List<double>.filled(n, 0);

    for (int i = 0; i < nSpans; i++) {
      final xL = pins[i].position, xR = pins[i + 1].position;
      final Ls = L[i];
      double Vi = 0, sumML = 0;
      for (final load in beam.loads) {
        if (load.type == LoadType.pointMoment) continue;
        if (load.isDistributed) {
          final qS = math.max(load.position, xL);
          final qE = math.min(load.endPosition ?? beam.length, xR);
          if (qE > qS) {
            final F = load.magnitude * (qE - qS);
            Vi += F;
            sumML += F * ((qS + qE) / 2 - xL);
          }
        } else if (load.type == LoadType.pointForce) {
          if (load.position >= xL && load.position <= xR) {
            Vi += load.magnitude;
            sumML += load.magnitude * (load.position - xL);
          }
        }
      }
      final Rright = (sumML + allM[i] - allM[i + 1]) / Ls;
      reactV[i]     += Vi - Rright;
      reactV[i + 1] += Rright;
    }

    for (int i = 0; i < n; i++) {
      pins[i].reactionV = reactV[i];
    }
    return _buildDiagrams(beam, bearing);
  }

  // ── Algorithme de Thomas ─────────────────────────────────────
  static List<double> _thomas(
      List<double> a, List<double> b, List<double> c, List<double> d) {
    final n = b.length;
    final c2 = List<double>.from(c);
    final d2 = List<double>.from(d);
    final bm = List<double>.from(b);
    for (int i = 1; i < n; i++) {
      if (bm[i - 1].abs() < 1e-12) continue;
      final m = a[i] / bm[i - 1];
      bm[i] -= m * c2[i - 1];
      d2[i] -= m * d2[i - 1];
    }
    final x = List<double>.filled(n, 0);
    x[n - 1] = d2[n - 1] / (bm[n - 1].abs() < 1e-12 ? 1 : bm[n - 1]);
    for (int i = n - 2; i >= 0; i--) {
      x[i] = (d2[i] - c2[i] * x[i + 1]) /
          (bm[i].abs() < 1e-12 ? 1 : bm[i]);
    }
    return x;
  }

  // ── Construction des diagrammes V(x) et M(x) ─────────────────
  static BeamResults _buildDiagrams(
      BeamModel beam, List<BeamSupport> bearing) {
    final L = beam.length;
    final dx = L / _nPoints;
    final pts = <DiagramPoint>[];

    double maxV = 0, minV = 0, maxM = 0, minM = 0;
    double posMaxM = 0, posMaxV = 0;

    // V initial = − réaction de l'appui en x=0
    double V = 0;
    final leftS = bearing
        .where((s) => s.position.abs() < 1e-6)
        .firstOrNull;
    if (leftS != null) V = -leftS.reactionV;

    double M = 0;

    for (int i = 0; i <= _nPoints; i++) {
      final x = i * dx;

      // Sauts dus aux réactions (appuis sauf x=0 déjà pris)
      for (final s in bearing) {
        if ((s.position - x).abs() < dx * 0.5 && s.position > dx * 0.25) {
          V -= s.reactionV;
          M -= s.reactionM;
        }
      }

      // Sauts dus aux charges ponctuelles
      for (final load in beam.loads) {
        if (load.type == LoadType.pointForce) {
          if ((load.position - x).abs() < dx * 0.5) V += load.magnitude;
        } else if (load.type == LoadType.pointMoment) {
          if ((load.position - x).abs() < dx * 0.5) M += load.magnitude;
        }
      }

      // Charges réparties sur ce pas
      for (final load in beam.loads) {
        if (load.isDistributed) {
          final xEnd = load.endPosition ?? L;
          if (x >= load.position && x < xEnd) {
            double q = load.magnitude;
            if (load.type == LoadType.triangularLoad) {
              final t = (x - load.position) / (xEnd - load.position);
              q = load.magnitude +
                  t * ((load.endMagnitude ?? 0) - load.magnitude);
            }
            V += q * dx;
          }
        }
      }

      // Intégration M = ∫V dx
      M += V * dx;

      pts.add(DiagramPoint(x: x, v: V, m: M));

      if (V > maxV) { maxV = V; posMaxV = x; }
      if (V < minV)   minV = V;
      if (M > maxM) { maxM = M; posMaxM = x; }
      if (M < minM)   minM = M;
    }

    return BeamResults(
      points: pts,
      maxShear: maxV, minShear: minV,
      maxMoment: maxM, minMoment: minM,
      posMaxMoment: posMaxM, posMaxShear: posMaxV,
      isValid: true,
    );
  }

  static BeamResults _empty(String msg) => BeamResults(
    points: [],
    maxShear: 0, minShear: 0,
    maxMoment: 0, minMoment: 0,
    posMaxMoment: 0, posMaxShear: 0,
    isValid: false,
    warningMessage: msg,
  );
}
