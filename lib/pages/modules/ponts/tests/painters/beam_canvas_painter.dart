// ═══════════════════════════════════════════════════════════════
//  beam_canvas_painter.dart  —  Dessin de la poutre
//  Importer : import '../painters/beam_canvas_painter.dart';
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/beam_models.dart';

// ─── Couleurs ────────────────────────────────────────────────────
const _cBeamFill    = Color(0xFF2D6DB5);
const _cBeamBorder  = Color(0xFF1E3A5F);
const _cSupport     = Color(0xFF1A5C38);
const _cLoad        = Color(0xFFCC3A1A);
const _cDistLoad    = Color(0xFFB84B00);
const _cMoment      = Color(0xFF7B3FA0);
const _cReaction    = Color(0xFF1A7A5E);
const _cDim         = Color(0xFF8090A8);
const _cSelect      = Color(0xFFF59E0B);
const _cDrag        = Color(0xFF0EA5E9);
const _cGround      = Color(0xFF475569);

class BeamCanvasPainter extends CustomPainter {
  final BeamModel beam;
  final String? selectedId;
  final String? draggingId;
  final double dragX;       // position actuelle en pixels pendant drag
  final double scale;
  final double offsetX;
  final double offsetY;
  final bool showReactions;
  final bool showDimensions;

  const BeamCanvasPainter({
    required this.beam,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    this.selectedId,
    this.draggingId,
    this.dragX = 0,
    this.showReactions = false,
    this.showDimensions = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    _drawBeam(canvas);
    _drawSupports(canvas);
    _drawLoads(canvas);
    if (showDimensions) _drawDimensions(canvas);
    if (showReactions)  _drawReactions(canvas);
    _drawDragGuide(canvas, size);
  }

  // ── Sol / hachures ───────────────────────────────────────────
  void _drawGround(Canvas canvas, Size size) {
    final gY = offsetY + 32.0;
    canvas.drawRect(
      Rect.fromLTRB(0, gY, size.width, gY + 8),
      Paint()..color = _cGround.withValues(alpha: 0.1),
    );
    final hp = Paint()
      ..color = _cGround.withValues(alpha: 0.22)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (double x = 0; x < size.width + 14; x += 9) {
      canvas.drawLine(Offset(x, gY), Offset(x - 12, gY + 12), hp);
    }
  }

  // ── Corps de la poutre ───────────────────────────────────────
  void _drawBeam(Canvas canvas) {
    final x0 = offsetX;
    final x1 = offsetX + beam.length * scale;
    final y  = offsetY;
    const bH = 18.0;
    final rr = RRect.fromRectAndRadius(
        Rect.fromLTRB(x0, y - bH / 2, x1, y + bH / 2),
        const Radius.circular(3));
    canvas.drawRRect(rr,
        Paint()..color = _cBeamFill..style = PaintingStyle.fill);
    canvas.drawRRect(rr,
        Paint()..color = _cBeamBorder..strokeWidth = 1.5..style = PaintingStyle.stroke);
    _txt(canvas, 'L = ${beam.length.toStringAsFixed(2)} m',
        Offset((x0 + x1) / 2, y + bH / 2 + 14), _cDim, 10);
  }

  // ── Appuis ───────────────────────────────────────────────────
  void _drawSupports(Canvas canvas) {
    for (final s in beam.supports) {
      final isDragging = s.id == draggingId;
      final px = isDragging ? dragX : offsetX + s.position * scale;
      final c  = s.id == selectedId
          ? (isDragging ? _cDrag : _cSelect)
          : _cSupport;

      switch (s.type) {
        case SupportType.simple:
          _drawSimple(canvas, px, offsetY, c);
        case SupportType.double_:
          _drawDouble(canvas, px, offsetY, c);
        case SupportType.hinge:
          _drawHinge(canvas, px, offsetY, c);
        case SupportType.fixed:
          final left = s.position <= beam.length / 2;
          _drawFixed(canvas, px, offsetY, c, left);
      }

      if (!isDragging) {
        _txt(canvas, s.position.toStringAsFixed(2),
            Offset(px, offsetY + 50), _cDim, 9);
      } else {
        // Affichage position live pendant drag
        final livePos = ((dragX - offsetX) / scale)
            .clamp(0.0, beam.length);
        _txt(canvas, livePos.toStringAsFixed(2),
            Offset(dragX, offsetY + 50), _cDrag, 10);
      }
    }
  }

  void _drawSimple(Canvas canvas, double px, double py, Color c) {
    // Triangle simple + ligne de sol
    final fill   = Paint()..color = c..style = PaintingStyle.fill;
    final stroke = Paint()..color = c..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(px, py + 9)
      ..lineTo(px - 10, py + 27)
      ..lineTo(px + 10, py + 27)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawLine(Offset(px - 13, py + 27), Offset(px + 13, py + 27),
        stroke..strokeWidth = 2);
    // Hachures sous la ligne
    final hP = Paint()..color = c.withValues(alpha: 0.4)..strokeWidth = 0.9..style = PaintingStyle.stroke;
    for (double dx = -10; dx <= 10; dx += 5) {
      canvas.drawLine(Offset(px + dx, py + 27), Offset(px + dx - 4, py + 33), hP);
    }
  }

  void _drawDouble(Canvas canvas, double px, double py, Color c) {
    // Triangle + 2 lignes latérales (double)
    final fill   = Paint()..color = c..style = PaintingStyle.fill;
    final stroke = Paint()..color = c..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(px, py + 9)
      ..lineTo(px - 10, py + 27)
      ..lineTo(px + 10, py + 27)
      ..close();
    canvas.drawPath(path, fill);
    // Base avec double trait
    canvas.drawLine(Offset(px - 13, py + 27), Offset(px + 13, py + 27),
        stroke..strokeWidth = 2.5);
    canvas.drawLine(Offset(px - 13, py + 31), Offset(px + 13, py + 31),
        stroke..strokeWidth = 1.5);
    // Petits traits verticaux (symbolise appui double)
    canvas.drawLine(Offset(px - 5, py + 27), Offset(px - 5, py + 33), stroke..strokeWidth = 1.5);
    canvas.drawLine(Offset(px + 5, py + 27), Offset(px + 5, py + 33), stroke..strokeWidth = 1.5);
  }

  void _drawHinge(Canvas canvas, double px, double py, Color c) {
    // Cercle vide = articulation / rotule
    final fill   = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final stroke = Paint()..color = c..strokeWidth = 2.0..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(px, py), 7, fill);
    canvas.drawCircle(Offset(px, py), 7, stroke);
    // Petites lignes diagonales pour indiquer charnière
    canvas.drawLine(Offset(px - 4, py - 4), Offset(px + 4, py + 4), stroke..strokeWidth = 1.5);
    canvas.drawLine(Offset(px + 4, py - 4), Offset(px - 4, py + 4), stroke..strokeWidth = 1.5);
    _txt(canvas, 'R', Offset(px, py + 17), c, 9);
  }

  void _drawFixed(Canvas canvas, double px, double py, Color c, bool left) {
    final fill  = Paint()..color = c.withValues(alpha: 0.9)..style = PaintingStyle.fill;
    final hP    = Paint()..color = c.withValues(alpha: 0.4)..strokeWidth = 1.2..style = PaintingStyle.stroke;
    final w = 9.0;
    canvas.drawRect(
        Rect.fromLTRB(left ? px - w : px, py - 22, left ? px : px + w, py + 22),
        fill);
    for (double dy = -20; dy < 22; dy += 6) {
      canvas.drawLine(
        Offset(left ? px - w : px + w, py + dy),
        Offset(left ? px - w - 7 : px + w + 7, py + dy + 7),
        hP,
      );
    }
  }

  // ── Charges ──────────────────────────────────────────────────
  void _drawLoads(Canvas canvas) {
    for (final l in beam.loads) {
      final isDragging = l.id == draggingId;
      final px = isDragging ? dragX : offsetX + l.position * scale;
      final sel = l.id == selectedId;

      switch (l.type) {
        case LoadType.pointForce:
          _drawPointForce(canvas, l, px, sel, isDragging);
        case LoadType.pointMoment:
          _drawPointMoment(canvas, l, px, sel, isDragging);
        case LoadType.distributedLoad:
        case LoadType.triangularLoad:
          if (!isDragging) _drawDistLoad(canvas, l, sel);
      }
    }
  }

  void _drawPointForce(Canvas canvas, BeamLoad l, double px,
      bool sel, bool drag) {
    final c = drag ? _cDrag : (sel ? _cSelect : _cLoad);
    const aLen = 38.0;
    final y    = offsetY - 9;
    final down = l.magnitude > 0;
    final yTip  = y;
    final yTail = down ? y - aLen : y + aLen;
    canvas.drawLine(Offset(px, yTail), Offset(px, yTip),
        Paint()..color = c..strokeWidth = 2..style = PaintingStyle.stroke);
    final tip = down
        ? (Path()..moveTo(px, yTip)..lineTo(px - 5, yTip - 10)..lineTo(px + 5, yTip - 10)..close())
        : (Path()..moveTo(px, yTip)..lineTo(px - 5, yTip + 10)..lineTo(px + 5, yTip + 10)..close());
    canvas.drawPath(tip, Paint()..color = c..style = PaintingStyle.fill);
    final lbl = l.label.isNotEmpty ? l.label : '${l.magnitude.abs().toStringAsFixed(1)} kN';
    _txt(canvas, lbl, Offset(px + 6, yTail + 8), c, 10);
  }

  void _drawPointMoment(Canvas canvas, BeamLoad l, double px,
      bool sel, bool drag) {
    final c = drag ? _cDrag : (sel ? _cSelect : _cMoment);
    const r = 18.0;
    final cw = l.magnitude > 0;
    canvas.drawArc(
        Rect.fromCircle(center: Offset(px, offsetY), radius: r),
        cw ? 0.3 : 3.44, 5.0, false,
        Paint()..color = c..strokeWidth = 2..style = PaintingStyle.stroke);
    final aa = cw ? 5.3 : 0.3;
    final ax = px + r * math.cos(aa);
    final ay = offsetY + r * math.sin(aa);
    canvas.drawPath(
      Path()
        ..moveTo(ax, ay)
        ..lineTo(ax + (cw ? -5 : 5), ay - 5)
        ..lineTo(ax + (cw ? -5 : 5), ay + 5)
        ..close(),
      Paint()..color = c..style = PaintingStyle.fill,
    );
    final lbl = l.label.isNotEmpty ? l.label : '${l.magnitude.abs().toStringAsFixed(1)} kN·m';
    _txt(canvas, lbl, Offset(px + 24, offsetY - 8), c, 10);
  }

  void _drawDistLoad(Canvas canvas, BeamLoad l, bool sel) {
    final c = sel ? _cSelect : _cDistLoad;
    final x0 = offsetX + l.position * scale;
    final x1 = offsetX + (l.endPosition ?? beam.length) * scale;
    final y  = offsetY - 9;

    final isTriang = l.type == LoadType.triangularLoad;
    const maxH = 38.0;

    final h0 = maxH;
    final h1 = isTriang
        ? maxH * (l.endMagnitude ?? 0).abs() /
              (l.magnitude.abs() > 0 ? l.magnitude.abs() : 1)
        : maxH;

    // Zone remplie
    canvas.drawPath(
      Path()
        ..moveTo(x0, y)
        ..lineTo(x0, y - h0)
        ..lineTo(x1, y - h1)
        ..lineTo(x1, y)
        ..close(),
      Paint()..color = c.withValues(alpha: 0.15)..style = PaintingStyle.fill,
    );
    canvas.drawLine(Offset(x0, y - h0), Offset(x1, y - h1),
        Paint()..color = c..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // Flèches
    final n = ((x1 - x0) / 16).floor().clamp(2, 25);
    for (int i = 0; i <= n; i++) {
      final ax = x0 + (x1 - x0) * i / n;
      final aH = isTriang ? h0 + (h1 - h0) * i / n : h0;
      canvas.drawLine(Offset(ax, y - aH), Offset(ax, y),
          Paint()..color = c..strokeWidth = 1.2..style = PaintingStyle.stroke);
      canvas.drawPath(
        Path()..moveTo(ax, y)..lineTo(ax - 3.5, y - 7)..lineTo(ax + 3.5, y - 7)..close(),
        Paint()..color = c..style = PaintingStyle.fill,
      );
    }
    final lbl = l.label.isNotEmpty
        ? l.label
        : '${l.magnitude.toStringAsFixed(1)} kN/m';
    _txt(canvas, lbl, Offset((x0 + x1) / 2, y - maxH - 10), c, 10);
  }

  // ── Réactions ────────────────────────────────────────────────
  void _drawReactions(Canvas canvas) {
    for (final s in beam.supports) {
      if (s.reactionV.abs() < 0.01) continue;
      final px  = offsetX + s.position * scale;
      final y   = offsetY + 9;
      const aL  = 34.0;
      final up  = s.reactionV > 0;
      canvas.drawLine(Offset(px, y + aL), Offset(px, y),
          Paint()..color = _cReaction..strokeWidth = 2..style = PaintingStyle.stroke);
      canvas.drawPath(
        up
          ? (Path()..moveTo(px, y)..lineTo(px - 5, y + 9)..lineTo(px + 5, y + 9)..close())
          : (Path()..moveTo(px, y + aL)..lineTo(px - 5, y + aL - 9)..lineTo(px + 5, y + aL - 9)..close()),
        Paint()..color = _cReaction..style = PaintingStyle.fill,
      );
      _txt(canvas, 'R=${s.reactionV.toStringAsFixed(1)} kN',
          Offset(px + 8, y + aL / 2), _cReaction, 9);
    }
  }

  // ── Cotation ─────────────────────────────────────────────────
  void _drawDimensions(Canvas canvas) {
    final sorted = List<BeamSupport>.from(beam.supports)
      ..sort((a, b) => a.position.compareTo(b.position));
    if (sorted.length < 2) return;
    const dY = -58.0;
    final dp = Paint()..color = _cDim..strokeWidth = 0.8..style = PaintingStyle.stroke;
    for (int i = 0; i < sorted.length - 1; i++) {
      final x0 = offsetX + sorted[i].position * scale;
      final x1 = offsetX + sorted[i + 1].position * scale;
      final y  = offsetY + dY;
      canvas.drawLine(Offset(x0, y), Offset(x1, y), dp);
      canvas.drawLine(Offset(x0, y - 4), Offset(x0, y + 4), dp);
      canvas.drawLine(Offset(x1, y - 4), Offset(x1, y + 4), dp);
      final span = sorted[i + 1].position - sorted[i].position;
      _txt(canvas, '${span.toStringAsFixed(2)} m',
          Offset((x0 + x1) / 2, y - 8), _cDim, 9);
    }
  }

  // ── Guide de drag ────────────────────────────────────────────
  void _drawDragGuide(Canvas canvas, Size size) {
    if (draggingId == null) return;
    canvas.drawLine(
      Offset(dragX, 0),
      Offset(dragX, size.height),
      Paint()
        ..color = _cDrag.withValues(alpha: 0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Helper texte ─────────────────────────────────────────────
  void _txt(Canvas canvas, String text, Offset pos, Color color, double size,
      {bool bold = false}) {
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
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(BeamCanvasPainter old) =>
      old.beam != beam ||
      old.selectedId != selectedId ||
      old.draggingId != draggingId ||
      old.dragX != dragX ||
      old.showReactions != showReactions ||
      old.scale != scale;
}

// ─── Utilitaire : trouver l'élément sous un point ───────────────
class CanvasHitTest {
  static String? hitTest(
    BeamModel beam,
    Offset tapPos,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    const hitRadius = 22.0;
    String? best;
    double bestDist = hitRadius;

    for (final s in beam.supports) {
      final px = offsetX + s.position * scale;
      final d  = (tapPos - Offset(px, offsetY)).distance;
      if (d < bestDist) { bestDist = d; best = s.id; }
    }
    for (final l in beam.loads) {
      final px = offsetX + l.position * scale;
      final d  = (tapPos - Offset(px, offsetY - 9)).distance;
      if (d < bestDist) { bestDist = d; best = l.id; }
    }
    return best;
  }
}
