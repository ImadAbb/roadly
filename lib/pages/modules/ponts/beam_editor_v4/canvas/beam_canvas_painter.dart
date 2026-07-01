// ═══════════════════════════════════════════════════════════════
//  canvas/beam_canvas_painter.dart
//  CustomPainter : dessin de la poutre
//  Corrections :
//    - withValues() au lieu de withOpacity()
//    - Sol clampé à la zone canvas (ne dépasse pas à gauche)
//    - Appui simple → triangle + roues (roulettes)
//    - Appui double → triangle + double ligne verticales (ancien dessin)
//    - Position affichée pour charges réparties en drag
// ═══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';

class BeamCanvasPainter extends CustomPainter {
  final BeamModel beam;
  final String?   selectedId;
  final String?   draggingId;
  final double    dragX;
  final double    scale;
  final double    offsetX;
  final double    offsetY;
  final bool      showReactions;
  final bool      showDimensions;

  const BeamCanvasPainter({
    required this.beam,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    this.selectedId,
    this.draggingId,
    this.dragX = 0,
    this.showReactions  = false,
    this.showDimensions = true,
  });

  Paint get _fill   => Paint()..style = PaintingStyle.fill;
  Paint get _stroke => Paint()..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    _drawBeam(canvas);
    _drawSupports(canvas);
    _drawLoads(canvas);
    if (showDimensions) _drawDimensions(canvas);
    if (showReactions)  _drawReactions(canvas);
    if (draggingId != null) _drawDragGuide(canvas, size);
  }

  // ── Sol (clampé à offsetX pour ne pas déborder à gauche) ────
  void _drawGround(Canvas canvas, Size size) {
    final gY   = offsetY + 32.0;
    // Le sol commence à offsetX, pas à 0
    final xMin = offsetX;
    final xMax = size.width;

    canvas.drawRect(
      Rect.fromLTRB(xMin, gY, xMax, gY + 8),
      _fill..color = BC.ground.wo(0.10),
    );
    final hp = _stroke
      ..color = BC.ground.wo(0.22)
      ..strokeWidth = 1.0;
    for (double x = xMin; x < xMax + 14; x += 9) {
      canvas.drawLine(Offset(x, gY), Offset(x - 12, gY + 12), hp);
    }
  }

  // ── Poutre ───────────────────────────────────────────────────
  void _drawBeam(Canvas canvas) {
    final x0 = offsetX;
    final x1 = offsetX + beam.length * scale;
    final y  = offsetY;
    const bH = 18.0;
    final rr = RRect.fromRectAndRadius(
        Rect.fromLTRB(x0, y - bH / 2, x1, y + bH / 2),
        const Radius.circular(3));
    canvas
      ..drawRRect(rr, _fill..color = BC.beamFill)
      ..drawRRect(rr, _stroke..color = BC.beamBorder..strokeWidth = 1.5);
    _label(canvas, 'L = ${beam.length.toStringAsFixed(2)} m',
        Offset((x0 + x1) / 2, y + bH / 2 + 14), BC.dimLine, 10);
  }

  // ── Appuis ───────────────────────────────────────────────────
  void _drawSupports(Canvas canvas) {
    for (final s in beam.supports) {
      final isDrag = s.id == draggingId;
      final px = isDrag ? dragX : offsetX + s.position * scale;
      final c  = isDrag
          ? BC.drag
          : (s.id == selectedId ? BC.selected : BC.support);

      switch (s.type) {
        case SupportType.simple:  _drawSimple(canvas, px, c);
        case SupportType.double_: _drawDouble(canvas, px, c);
        case SupportType.hinge:   _drawHinge(canvas, px, c);
        case SupportType.fixed:
          _drawFixed(canvas, px, c, s.position <= beam.length / 2);
      }

      final posStr = isDrag
          ? _dragPosStr(dragX)
          : s.position.toStringAsFixed(2);
      _label(canvas, posStr,
          Offset(px, offsetY + 52),
          isDrag ? BC.drag : BC.dimLine, 9);
    }
  }

  // ── Appui simple : triangle + 3 roues (cercles) ─────────────
  void _drawSimple(Canvas canvas, double px, Color c) {
    final y = offsetY;
    // Triangle
    final path = Path()
      ..moveTo(px, y + 9)
      ..lineTo(px - 10, y + 26)
      ..lineTo(px + 10, y + 26)
      ..close();
    canvas.drawPath(path, _fill..color = c);
    canvas.drawPath(path, _stroke..color = c..strokeWidth = 1.2);
    // Ligne intermédiaire
    canvas.drawLine(Offset(px - 12, y + 26), Offset(px + 12, y + 26),
        _stroke..color = c..strokeWidth = 1.5);
    // 3 roues (roulettes)
    const r = 3.0;
    for (final dx in [-6.0, 0.0, 6.0]) {
      canvas.drawCircle(
          Offset(px + dx, y + 26 + r + 1), r, _fill..color = c);
      canvas.drawCircle(
          Offset(px + dx, y + 26 + r + 1), r,
          _stroke..color = c.wo(0.5)..strokeWidth = 0.8);
    }
    // Ligne de sol sous les roues
    canvas.drawLine(
        Offset(px - 14, y + 26 + 2 * r + 2),
        Offset(px + 14, y + 26 + 2 * r + 2),
        _stroke..color = c..strokeWidth = 1.5);
  }

  // ── Appui double : triangle + double ligne + barres ─────────
  void _drawDouble(Canvas canvas, double px, Color c) {
    final y = offsetY;
    // Triangle
    final path = Path()
      ..moveTo(px, y + 9)
      ..lineTo(px - 10, y + 26)
      ..lineTo(px + 10, y + 26)
      ..close();
    canvas.drawPath(path, _fill..color = c);
    canvas.drawPath(path, _stroke..color = c..strokeWidth = 1.2);
    // Double trait horizontal
    canvas.drawLine(Offset(px - 13, y + 26), Offset(px + 13, y + 26),
        _stroke..color = c..strokeWidth = 2.5);
    canvas.drawLine(Offset(px - 13, y + 31), Offset(px + 13, y + 31),
        _stroke..color = c..strokeWidth = 1.5);
    // Petites barres verticales (symbolise blocage horizontal)
    canvas.drawLine(Offset(px - 5, y + 26), Offset(px - 5, y + 34),
        _stroke..color = c..strokeWidth = 1.5);
    canvas.drawLine(Offset(px + 5, y + 26), Offset(px + 5, y + 34),
        _stroke..color = c..strokeWidth = 1.5);
  }

  // ── Rotule interne : cercle + croix ─────────────────────────
  void _drawHinge(Canvas canvas, double px, Color c) {
    final y = offsetY;
    canvas
      ..drawCircle(Offset(px, y), 7, _fill..color = Colors.white)
      ..drawCircle(Offset(px, y), 7, _stroke..color = c..strokeWidth = 2.0)
      ..drawLine(Offset(px - 4, y - 4), Offset(px + 4, y + 4),
          _stroke..color = c..strokeWidth = 1.5)
      ..drawLine(Offset(px + 4, y - 4), Offset(px - 4, y + 4),
          _stroke..color = c..strokeWidth = 1.5);
    _label(canvas, 'R', Offset(px, y + 18), c, 9);
  }

  // ── Encastrement : rectangle hachuré ─────────────────────────
  void _drawFixed(Canvas canvas, double px, Color c, bool left) {
    final y = offsetY;
    const w = 9.0;
    canvas.drawRect(
      Rect.fromLTRB(
          left ? px - w : px, y - 22, left ? px : px + w, y + 22),
      _fill..color = c.wo(0.9),
    );
    final hp = _stroke..color = c.wo(0.4)..strokeWidth = 1.2;
    for (double dy = -20; dy < 22; dy += 6) {
      canvas.drawLine(
        Offset(left ? px - w : px + w, y + dy),
        Offset(left ? px - w - 7 : px + w + 7, y + dy + 7),
        hp,
      );
    }
  }

  // ── Charges ──────────────────────────────────────────────────
  void _drawLoads(Canvas canvas) {
    for (final l in beam.loads) {
      final isDrag = l.id == draggingId;
      final px  = isDrag ? dragX : offsetX + l.position * scale;
      final sel = l.id == selectedId;

      switch (l.type) {
        case LoadType.pointForce:
          _drawPointForce(canvas, l, px, sel, isDrag);
        case LoadType.pointMoment:
          _drawPointMoment(canvas, l, px, sel, isDrag);
        case LoadType.distributedLoad:
        case LoadType.triangularLoad:
          _drawDistLoad(canvas, l, sel, isDrag);
      }
    }
  }

  void _drawPointForce(Canvas canvas, BeamLoad l, double px,
      bool sel, bool drag) {
    final c    = drag ? BC.drag : (sel ? BC.selected : BC.load);
    const aLen = 38.0;
    final y    = offsetY - 9;
    final down = l.magnitude > 0;
    final yTip  = y;
    final yTail = down ? y - aLen : y + aLen;
    canvas.drawLine(Offset(px, yTail), Offset(px, yTip),
        _stroke..color = c..strokeWidth = 2);
    canvas.drawPath(
      down
          ? (Path()..moveTo(px, yTip)..lineTo(px - 5, yTip - 10)..lineTo(px + 5, yTip - 10)..close())
          : (Path()..moveTo(px, yTip)..lineTo(px - 5, yTip + 10)..lineTo(px + 5, yTip + 10)..close()),
      _fill..color = c,
    );
    if (drag) {
      _label(canvas, _dragPosStr(px), Offset(px, yTail - 10), BC.drag, 10);
    } else {
      final lbl = l.label.isNotEmpty
          ? l.label : '${l.magnitude.abs().toStringAsFixed(1)} kN';
      _label(canvas, lbl, Offset(px + 6, yTail + 8), c, 10);
    }
  }

  void _drawPointMoment(Canvas canvas, BeamLoad l, double px,
      bool sel, bool drag) {
    final c  = drag ? BC.drag : (sel ? BC.selected : BC.momentClr);
    const r  = 18.0;
    final cw = l.magnitude > 0;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(px, offsetY), radius: r),
      cw ? 0.3 : 3.44, 5.0, false,
      _stroke..color = c..strokeWidth = 2,
    );
    final aa = cw ? 5.3 : 0.3;
    canvas.drawPath(
      Path()
        ..moveTo(px + r * math.cos(aa), offsetY + r * math.sin(aa))
        ..lineTo(px + r * math.cos(aa) + (cw ? -5 : 5),
            offsetY + r * math.sin(aa) - 5)
        ..lineTo(px + r * math.cos(aa) + (cw ? -5 : 5),
            offsetY + r * math.sin(aa) + 5)
        ..close(),
      _fill..color = c,
    );
    if (drag) {
      _label(canvas, _dragPosStr(px), Offset(px, offsetY - 30), BC.drag, 10);
    } else {
      final lbl = l.label.isNotEmpty
          ? l.label : '${l.magnitude.abs().toStringAsFixed(1)} kN·m';
      _label(canvas, lbl, Offset(px + 24, offsetY - 8), c, 10);
    }
  }

  void _drawDistLoad(Canvas canvas, BeamLoad l, bool sel, bool drag) {
    final c  = drag ? BC.drag : (sel ? BC.selected : BC.distLoad);
    // En drag, décaler tout le bloc
    final offset = drag
        ? dragX - (offsetX + l.visualCenter * scale)
        : 0.0;
    final x0 = offsetX + l.position * scale + offset;
    final x1 = offsetX + (l.endPosition ?? beam.length) * scale + offset;
    final xCenter = (x0 + x1) / 2;
    final y  = offsetY - 9;
    final isTriang = l.type == LoadType.triangularLoad;
    const maxH = 38.0;
    final h0 = maxH;
    final h1 = isTriang
        ? maxH * (l.endMagnitude ?? 0).abs() /
              (l.magnitude.abs() > 0 ? l.magnitude.abs() : 1)
        : maxH;

    canvas.drawPath(
      Path()
        ..moveTo(x0, y)..lineTo(x0, y - h0)
        ..lineTo(x1, y - h1)..lineTo(x1, y)
        ..close(),
      _fill..color = c.wo(0.15),
    );
    canvas.drawLine(Offset(x0, y - h0), Offset(x1, y - h1),
        _stroke..color = c..strokeWidth = 1.5);

    final n = ((x1 - x0) / 16).floor().clamp(2, 25);
    for (int i = 0; i <= n; i++) {
      final ax = x0 + (x1 - x0) * i / n;
      final aH = isTriang ? h0 + (h1 - h0) * i / n : h0;
      canvas
        ..drawLine(Offset(ax, y - aH), Offset(ax, y),
            _stroke..color = c..strokeWidth = 1.2)
        ..drawPath(
          Path()..moveTo(ax, y)..lineTo(ax - 3.5, y - 7)..lineTo(ax + 3.5, y - 7)..close(),
          _fill..color = c,
        );
    }

    if (drag) {
      // Afficher la nouvelle position pendant le drag
      _label(canvas, _dragPosStr(xCenter), Offset(xCenter, y - maxH - 10),
          BC.drag, 10);
    } else {
      final lbl = l.label.isNotEmpty
          ? l.label : '${l.magnitude.toStringAsFixed(1)} kN/m';
      _label(canvas, lbl, Offset(xCenter, y - maxH - 10), c, 10);
    }
  }

  // ── Réactions ────────────────────────────────────────────────
  void _drawReactions(Canvas canvas) {
    for (final s in beam.supports) {
      if (s.reactionV.abs() < 0.01) continue;
      final px = offsetX + s.position * scale;
      final y  = offsetY + 9;
      const aL = 34.0;
      final up = s.reactionV > 0;
      canvas
        ..drawLine(Offset(px, y + aL), Offset(px, y),
            _stroke..color = BC.reaction..strokeWidth = 2)
        ..drawPath(
          up
            ? (Path()..moveTo(px, y)..lineTo(px - 5, y + 9)..lineTo(px + 5, y + 9)..close())
            : (Path()..moveTo(px, y + aL)..lineTo(px - 5, y + aL - 9)..lineTo(px + 5, y + aL - 9)..close()),
          _fill..color = BC.reaction,
        );
      _label(canvas, 'R=${s.reactionV.toStringAsFixed(1)} kN',
          Offset(px + 8, y + aL / 2), BC.reaction, 9);
    }
  }

  // ── Cotation ─────────────────────────────────────────────────
  void _drawDimensions(Canvas canvas) {
    final sorted = List<BeamSupport>.from(beam.supports)
      ..sort((a, b) => a.position.compareTo(b.position));
    if (sorted.length < 2) return;
    const dY = -58.0;
    final dp = _stroke..color = BC.dimLine..strokeWidth = 0.8;
    for (int i = 0; i < sorted.length - 1; i++) {
      final x0   = offsetX + sorted[i].position * scale;
      final x1   = offsetX + sorted[i + 1].position * scale;
      final y    = offsetY + dY;
      final span = sorted[i + 1].position - sorted[i].position;
      canvas
        ..drawLine(Offset(x0, y), Offset(x1, y), dp)
        ..drawLine(Offset(x0, y - 4), Offset(x0, y + 4), dp)
        ..drawLine(Offset(x1, y - 4), Offset(x1, y + 4), dp);
      _label(canvas, '${span.toStringAsFixed(2)} m',
          Offset((x0 + x1) / 2, y - 8), BC.dimLine, 9);
    }
  }

  // ── Guide drag ───────────────────────────────────────────────
  void _drawDragGuide(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(dragX, 0), Offset(dragX, size.height),
      _stroke
        ..color = BC.drag.wo(0.3)
        ..strokeWidth = 1.0,
    );
  }

  // ── Position live pendant drag ───────────────────────────────
  String _dragPosStr(double px) {
    final pos = ((px - offsetX) / scale).clamp(0.0, beam.length);
    return '${pos.toStringAsFixed(2)} m';
  }

  // ── Texte ─────────────────────────────────────────────────────
  void _label(Canvas canvas, String text, Offset pos, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(text: text,
          style: TextStyle(color: color, fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(BeamCanvasPainter old) =>
      old.beam       != beam       ||
      old.selectedId != selectedId ||
      old.draggingId != draggingId ||
      old.dragX      != dragX      ||
      old.showReactions  != showReactions ||
      old.scale      != scale;
}
