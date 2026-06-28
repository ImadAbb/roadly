// ═══════════════════════════════════════════════════════════════
//  diagram_painter.dart  —  Diagrammes V et M avec curseur
//  Importer : import '../painters/diagram_painter.dart';
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/beam_models.dart';

enum DiagramType { shear, moment }

class DiagramPainter extends CustomPainter {
  final BeamResults results;
  final DiagramType type;
  final double beamLength;
  final Color color;
  final bool showGrid;
  // Curseur d'inspection (null = pas affiché)
  final double? cursorX; // position en pixels dans le widget

  const DiagramPainter({
    required this.results,
    required this.type,
    required this.beamLength,
    required this.color,
    this.showGrid = true,
    this.cursorX,
  });

  static const _padL = 54.0;
  static const _padR = 16.0;
  static const _padT = 24.0;
  static const _padB = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (results.points.isEmpty) return;

    final plotW = size.width  - _padL - _padR;
    final plotH = size.height - _padT - _padB;
    final zeroY = _padT + plotH / 2;

    final maxAbs = _maxAbs();
    if (maxAbs < 1e-9) return;

    final scale = (plotH / 2) / (maxAbs * 1.15);

    if (showGrid) _drawGrid(canvas, size, plotW, plotH, zeroY);
    _drawZeroAxis(canvas, size, plotW, zeroY);
    _drawCurve(canvas, plotW, plotH, zeroY, scale);
    _drawExtrema(canvas, plotW, zeroY, scale);
    _drawAxesLabels(canvas, size, plotW, plotH, zeroY, maxAbs);
    if (cursorX != null) _drawCursor(canvas, size, plotW, zeroY, scale);
  }

  double _maxAbs() {
    switch (type) {
      case DiagramType.shear:
        return math.max(results.maxShear.abs(), results.minShear.abs());
      case DiagramType.moment:
        return math.max(results.maxMoment.abs(), results.minMoment.abs());
    }
  }

  double _getVal(DiagramPoint pt) =>
      type == DiagramType.shear ? pt.v : pt.m;

  double _xToPx(double x, double plotW) =>
      _padL + (x / beamLength) * plotW;

  double _valToPy(double val, double zeroY, double scale) =>
      zeroY - val * scale;

  // ── Grille ───────────────────────────────────────────────────
  void _drawGrid(Canvas canvas, Size size, double plotW, double plotH,
      double zeroY) {
    final gP = Paint()
      ..color = const Color(0xFFE8ECF2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (int i = -2; i <= 2; i++) {
      final y = zeroY - (i / 2) * (plotH / 2);
      canvas.drawLine(Offset(_padL, y), Offset(_padL + plotW, y), gP);
    }
    for (int i = 0; i <= 5; i++) {
      final x = _padL + (i / 5) * plotW;
      canvas.drawLine(Offset(x, _padT), Offset(x, _padT + plotH), gP);
    }
  }

  // ── Axe zéro ─────────────────────────────────────────────────
  void _drawZeroAxis(Canvas canvas, Size size, double plotW, double zeroY) {
    canvas.drawLine(
      Offset(_padL, zeroY),
      Offset(_padL + plotW, zeroY),
      Paint()
        ..color = const Color(0xFFB0BAC8)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Courbe remplie ───────────────────────────────────────────
  void _drawCurve(Canvas canvas, double plotW, double plotH,
      double zeroY, double scale) {
    final fill   = Path();
    final stroke = Path();
    bool first = true;

    for (final pt in results.points) {
      final px = _xToPx(pt.x, plotW);
      final py = _valToPy(_getVal(pt), zeroY, scale);
      if (first) {
        fill..moveTo(px, zeroY)..lineTo(px, py);
        stroke.moveTo(px, py);
        first = false;
      } else {
        fill.lineTo(px, py);
        stroke.lineTo(px, py);
      }
    }
    fill..lineTo(_xToPx(beamLength, plotW), zeroY)..close();

    canvas.drawPath(fill,
        Paint()..color = color.withValues(alpha: 0.18)..style = PaintingStyle.fill);
    canvas.drawPath(stroke,
        Paint()
          ..color = color
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  // ── Valeurs extrema ──────────────────────────────────────────
  void _drawExtrema(Canvas canvas, double plotW, double zeroY, double scale) {
    DiagramPoint? maxPt, minPt;
    for (final pt in results.points) {
      final v = _getVal(pt);
      if (maxPt == null || v > _getVal(maxPt)) maxPt = pt;
      if (minPt == null || v < _getVal(minPt)) minPt = pt;
    }
    if (maxPt != null && _getVal(maxPt).abs() > 1e-6) {
      _drawMarker(canvas, maxPt, plotW, zeroY, scale, isMax: true);
    }
    if (minPt != null && _getVal(minPt).abs() > 1e-6 && minPt != maxPt) {
      _drawMarker(canvas, minPt, plotW, zeroY, scale, isMax: false);
    }
  }

  void _drawMarker(Canvas canvas, DiagramPoint pt, double plotW,
      double zeroY, double scale, {required bool isMax}) {
    final val = _getVal(pt);
    final px  = _xToPx(pt.x, plotW);
    final py  = _valToPy(val, zeroY, scale);

    // Ligne pointillée
    _dashedLine(canvas, Offset(px, zeroY), Offset(px, py),
        Paint()..color = color.withValues(alpha: 0.4)..strokeWidth = 0.8..style = PaintingStyle.stroke);

    // Point
    canvas.drawCircle(Offset(px, py), 4,
        Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(px, py), 4,
        Paint()..color = Colors.white..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // Label
    final unit = type == DiagramType.shear ? 'kN' : 'kN·m';
    final txt = '${val.toStringAsFixed(1)} $unit';
    final tp = TextPainter(
      text: TextSpan(
        text: txt,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          backgroundColor: Colors.white.withValues(alpha: 0.9),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final lx = (px + tp.width + 4 > _padL + plotW)
        ? px - tp.width - 4
        : px + 4;
    final ly = isMax ? py - tp.height - 3 : py + 3;
    tp.paint(canvas, Offset(lx, ly));
  }

  // ── Curseur d'inspection ──────────────────────────────────────
  void _drawCursor(Canvas canvas, Size size, double plotW,
      double zeroY, double scale) {
    final cx = cursorX!.clamp(_padL, _padL + plotW);
    // Ligne verticale du curseur
    canvas.drawLine(
      Offset(cx, _padT),
      Offset(cx, size.height - _padB),
      Paint()
        ..color = Colors.orange.withValues(alpha: 0.85)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Valeur interpolée
    final xPos = (cx - _padL) / plotW * beamLength;
    final val = type == DiagramType.shear
        ? results.shearAt(xPos)
        : results.momentAt(xPos);
    final py = _valToPy(val, zeroY, scale).clamp(_padT, size.height - _padB);

    // Cercle sur la courbe
    canvas.drawCircle(Offset(cx, py), 5,
        Paint()..color = Colors.orange..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, py), 5,
        Paint()..color = Colors.white..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // Bulle de valeur
    final unit = type == DiagramType.shear ? 'kN' : 'kN·m';
    final label = 'x=${xPos.toStringAsFixed(2)} m\n${val.toStringAsFixed(2)} $unit';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const pad = 6.0;
    final bW = tp.width + pad * 2;
    final bH = tp.height + pad * 2;
    double bx = cx + 10;
    double by = py - bH / 2;
    if (bx + bW > size.width - _padR) bx = cx - bW - 10;
    by = by.clamp(_padT, size.height - _padB - bH);

    final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bW, bH), const Radius.circular(7));
    canvas.drawRRect(rr,
        Paint()..color = Colors.orange.shade700..style = PaintingStyle.fill);
    tp.paint(canvas, Offset(bx + pad, by + pad));
  }

  // ── Axes et labels ───────────────────────────────────────────
  void _drawAxesLabels(Canvas canvas, Size size, double plotW,
      double plotH, double zeroY, double maxAbs) {
    final unit = type == DiagramType.shear ? 'kN' : 'kN·m';
    final title = type == DiagramType.shear ? 'V ($unit)' : 'M ($unit)';

    _paintTxt(canvas, title, Offset(_padL, _padT - 10), color, 10, bold: true);

    // Labels Y
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final y = zeroY - (i / 2) * (plotH / 2);
      final v = (i / 2) * maxAbs;
      _paintTxt(canvas, v.toStringAsFixed(0), Offset(_padL - 4, y),
          const Color(0xFF8090A8), 8, right: true);
    }

    // Labels X
    for (int i = 0; i <= 5; i++) {
      final x = _padL + (i / 5) * plotW;
      final v = (i / 5) * beamLength;
      _paintTxt(canvas, v.toStringAsFixed(1), Offset(x, size.height - _padB + 6),
          const Color(0xFF8090A8), 8);
    }
  }

  // ── Ligne pointillée ─────────────────────────────────────────
  void _dashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dLen = 4.0, gLen = 3.0;
    final dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final nx = dx / dist, ny = dy / dist;
    final steps = (dist / (dLen + gLen)).floor();
    for (int i = 0; i < steps; i++) {
      final s = i * (dLen + gLen);
      final e = math.min(s + dLen, dist);
      canvas.drawLine(
        Offset(p1.dx + nx * s,  p1.dy + ny * s),
        Offset(p1.dx + nx * e,  p1.dy + ny * e),
        paint,
      );
    }
  }

  void _paintTxt(Canvas canvas, String text, Offset pos, Color color,
      double size, {bool right = false, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final ox = right ? pos.dx - tp.width : pos.dx - tp.width / 2;
    tp.paint(canvas, Offset(ox, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(DiagramPainter old) =>
      old.results != results ||
      old.type != type ||
      old.color != color ||
      old.cursorX != cursorX;
}
