// ═══════════════════════════════════════════════════════════════
//  core/beam_solver.dart
//  Calcul V(x) et M(x) — isostatique + Clapeyron hyperstatique
//  Nommage corrigé : spanLen, shearSpan, rRight (camelCase)
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'beam_models.dart';

class BeamSolver {
  static const int _nPoints = 500;

  static BeamResults solve(BeamModel beam) {
    final supports = List<BeamSupport>.from(beam.supports)
      ..sort((a, b) => a.position.compareTo(b.position));

    final bearing = supports
        .where((s) => s.type != SupportType.hinge)
        .toList();

    final dof = _countReactions(bearing) - 3;

    final BeamResults res;
    if (dof < 0) {
      res = _empty('Structure instable — ajoutez des appuis portants.');
    } else if (dof == 0) {
      res = _solveIsostatic(beam, bearing);
    } else {
      res = _solveHyperstatic(beam, bearing);
    }

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

  static int _countReactions(List<BeamSupport> bearing) {
    int r = 0;
    for (final s in bearing) {
      switch (s.type) {
        case SupportType.simple:  r += 1;
        case SupportType.double_: r += 2;
        case SupportType.fixed:   r += 3;
        case SupportType.hinge:   break;
      }
    }
    return r;
  }

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

    final fixedList = bearing.where((s) => s.type == SupportType.fixed).toList();
    if (fixedList.length == 1 && bearing.length == 1) {
      final s = fixedList.first;
      s.reactionV = totalV;
      s.reactionH = 0;
      s.reactionM = -(totalM - totalV * s.position);
      return _buildDiagrams(beam, bearing);
    }

    final vert = bearing.where((s) => s.type != SupportType.hinge).toList();
    if (vert.length == 2) {
      final sA = vert[0], sB = vert[1];
      final spanL = sB.position - sA.position;
      if (spanL.abs() < 1e-9) {
        return _empty('Deux appuis à la même position.');
      }
      sB.reactionV = (totalM - totalV * sA.position) / spanL;
      sA.reactionV = totalV - sB.reactionV;
      sA.reactionH = sB.reactionH = 0;
      return _buildDiagrams(beam, bearing);
    }

    if (bearing.length >= 3) return _solveHyperstatic(beam, bearing);
    return _empty('Configuration d\'appuis non reconnue.');
  }

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
    final spanLengths = List<double>.generate(
        nSpans, (i) => pins[i + 1].position - pins[i].position);

    final bLeft  = List<double>.filled(nSpans, 0);
    final bRight = List<double>.filled(nSpans, 0);

    for (final load in beam.loads) {
      if (load.type == LoadType.pointMoment) continue;
      for (int i = 0; i < nSpans; i++) {
        final xL = pins[i].position;
        final xR = pins[i + 1].position;
        final spanLen = spanLengths[i];

        if (load.isDistributed) {
          final qStart = math.max(load.position, xL);
          final qEnd   = math.min(load.endPosition ?? beam.length, xR);
          if (qEnd <= qStart) continue;
          final ratio = (qEnd - qStart) / spanLen;
          bLeft[i]  += load.magnitude * spanLen * spanLen * spanLen / 4 * ratio;
          bRight[i] += load.magnitude * spanLen * spanLen * spanLen / 4 * ratio;
        } else if (load.type == LoadType.pointForce) {
          if (load.position < xL || load.position > xR) continue;
          final a = load.position - xL;
          final b = spanLen - a;
          final p = load.magnitude;
          bLeft[i]  += p * b * (spanLen * spanLen - b * b) / spanLen;
          bRight[i] += p * a * (spanLen * spanLen - a * a) / spanLen;
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
      aT[k] = k > 0 ? spanLengths[i - 1] : 0;
      bT[k] = 2 * (spanLengths[i - 1] + spanLengths[i]);
      cT[k] = k < nInt - 1 ? spanLengths[i] : 0;
      dT[k] = -6 * (bRight[i - 1] / spanLengths[i - 1] +
                    bLeft[i]  / spanLengths[i]);
    }

    final moments = _thomas(aT, bT, cT, dT);
    final allM    = [0.0, ...moments, 0.0];
    final reactV  = List<double>.filled(n, 0);

    for (int i = 0; i < nSpans; i++) {
      final xL = pins[i].position;
      final xR = pins[i + 1].position;
      final spanLen = spanLengths[i];
      double shearSpan = 0, sumMloads = 0;

      for (final load in beam.loads) {
        if (load.type == LoadType.pointMoment) continue;
        if (load.isDistributed) {
          final qStart = math.max(load.position, xL);
          final qEnd   = math.min(load.endPosition ?? beam.length, xR);
          if (qEnd > qStart) {
            final f = load.magnitude * (qEnd - qStart);
            shearSpan += f;
            sumMloads += f * ((qStart + qEnd) / 2 - xL);
          }
        } else if (load.type == LoadType.pointForce) {
          if (load.position >= xL && load.position <= xR) {
            shearSpan += load.magnitude;
            sumMloads += load.magnitude * (load.position - xL);
          }
        }
      }
      final rRight = (sumMloads + allM[i] - allM[i + 1]) / spanLen;
      reactV[i]     += shearSpan - rRight;
      reactV[i + 1] += rRight;
    }

    for (int i = 0; i < n; i++) {
      pins[i].reactionV = reactV[i];
    }
    return _buildDiagrams(beam, bearing);
  }

  static List<double> _thomas(
      List<double> a, List<double> b, List<double> c, List<double> d) {
    final n  = b.length;
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

  static BeamResults _buildDiagrams(
      BeamModel beam, List<BeamSupport> bearing) {
    final l = beam.length;
    final dx = l / _nPoints;
    final pts = <DiagramPoint>[];

    double maxV = 0, minV = 0, maxM = 0, minM = 0;
    double posMaxM = 0, posMaxV = 0;

    double v = 0, m = 0;
    final leftS = bearing.where((s) => s.position.abs() < 1e-6).firstOrNull;
    if (leftS != null) v = -leftS.reactionV;

    for (int i = 0; i <= _nPoints; i++) {
      final x = i * dx;

      for (final s in bearing) {
        if ((s.position - x).abs() < dx * 0.5 && s.position > dx * 0.25) {
          v -= s.reactionV;
          m -= s.reactionM;
        }
      }

      for (final load in beam.loads) {
        if (load.type == LoadType.pointForce) {
          if ((load.position - x).abs() < dx * 0.5) v += load.magnitude;
        } else if (load.type == LoadType.pointMoment) {
          if ((load.position - x).abs() < dx * 0.5) m += load.magnitude;
        }
      }

      for (final load in beam.loads) {
        if (load.isDistributed) {
          final xEnd = load.endPosition ?? l;
          if (x >= load.position && x < xEnd) {
            double q = load.magnitude;
            if (load.type == LoadType.triangularLoad) {
              final t = (x - load.position) / (xEnd - load.position);
              q = load.magnitude +
                  t * ((load.endMagnitude ?? 0) - load.magnitude);
            }
            v += q * dx;
          }
        }
      }

      m += v * dx;
      pts.add(DiagramPoint(x: x, v: v, m: m));

      if (v > maxV) { maxV = v; posMaxV = x; }
      if (v < minV) { minV = v; }
      if (m > maxM) { maxM = m; posMaxM = x; }
      if (m < minM) { minM = m; }
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
