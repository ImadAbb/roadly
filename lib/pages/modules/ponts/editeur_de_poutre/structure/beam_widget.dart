import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/beam_painter.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/classes.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/selection_notifier.dart';

class BeamWidget extends StatefulWidget {
  final Beam beam;
  const BeamWidget({super.key, required this.beam});

  @override
  State<BeamWidget> createState() => _BeamWidgetState();
}

class _BeamWidgetState extends State<BeamWidget> {
  dynamic _selected;
  dynamic _dragging;
  String? _dragMode; // 'move' | 'resizeStart' | 'resizeEnd'
  double? _dragDisplayMeters;
  Offset? _dragDisplayOffset;

  @override
  void initState() {
    super.initState();
    _selected = selectedElementNotifier.value;
    selectedElementNotifier.addListener(_onExternalSelection);
  }

  void _onExternalSelection() {
    setState(() {
      _selected = selectedElementNotifier.value;
    });
  }

  @override
  void dispose() {
    selectedElementNotifier.removeListener(_onExternalSelection);
    super.dispose();
  }

  void _handleTap(BuildContext context, Offset pos) {
    final box = context.findRenderObject() as RenderBox;
    final W = box.size.width;
    final dx = pos.dx;
    final dy = pos.dy;

    dynamic hit;

    for (var s in widget.beam.supports) {
      double cx = s.x / widget.beam.length * W;
      final dist = (Offset(cx, BeamPainter.bY) - pos).distance;
      if (dist < 28) {
        hit = s;
        break;
      }
    }

    if (hit == null) {
      for (var l in widget.beam.loads) {
        double cx = l.x / widget.beam.length * W;
        if (l is PointLoad) {
          const arrowLength = 50;
          final center = Offset(cx, BeamPainter.bY - arrowLength / 2);
          if ((center - pos).distance < 24) {
            hit = l;
            break;
          }
        } else if (l is DistributedLoad) {
          double cx1 = l.x / widget.beam.length * W;
          double cx2 = l.xEnd / widget.beam.length * W;
          if (dx >= cx1 - 6 && dx <= cx2 + 6 && dy < BeamPainter.bY && dy > BeamPainter.bY - 100) {
            hit = l;
            break;
          }
        }
      }
    }

    setState(() {
      _selected = hit;
    });

    selectedElementNotifier.value = hit;
  }

  void _onPanStart(BuildContext context, Offset pos) {
    final box = context.findRenderObject() as RenderBox;
    final W = box.size.width;
    final dx = pos.dx;
    final dy = pos.dy;

    dynamic hit;
    String? mode;

    for (var s in widget.beam.supports) {
      double cx = s.x / widget.beam.length * W;
      final dist = (Offset(cx, BeamPainter.bY) - pos).distance;
      if (dist < 28) {
        hit = s;
        mode = 'move';
        break;
      }
    }

    if (hit == null) {
      for (var l in widget.beam.loads) {
        double cx = l.x / widget.beam.length * W;
        if (l is PointLoad) {
          const arrowLength = 50;
          final center = Offset(cx, BeamPainter.bY - arrowLength / 2);
          if ((center - pos).distance < 24) {
            hit = l;
            mode = 'move';
            break;
          }
        } else if (l is DistributedLoad) {
          double cx1 = l.x / widget.beam.length * W;
          double cx2 = l.xEnd / widget.beam.length * W;
          if (dx >= cx1 - 12 && dx <= cx2 + 12 && dy < BeamPainter.bY && dy > BeamPainter.bY - 100) {
            hit = l;
            if ((dx - cx1).abs() < 12) {
              mode = 'resizeStart';
            } else if ((dx - cx2).abs() < 12) {
              mode = 'resizeEnd';
            } else {
              mode = 'move';
            }
            break;
          }
        }
      }
    }

    setState(() {
      _dragging = hit;
      _dragMode = mode;
      _dragDisplayOffset = pos;
      if (hit != null) {
        _selected = hit;
        selectedElementNotifier.value = hit;
        final meters = (dx / W * widget.beam.length).clamp(0.0, widget.beam.length);
        final snapped = meters.roundToDouble();
        _dragDisplayMeters = snapped;
        double px;
        if (hit is DistributedLoad) {
          px = ((hit.x + hit.xEnd) / 2) / widget.beam.length * W;
        } else {
          px = (snapped / widget.beam.length) * W;
        }
        _dragDisplayOffset = Offset(px, BeamPainter.bY - 60);
      }
    });
  }

  void _onPanUpdate(BuildContext context, Offset pos) {
    if (_dragging == null) return;
    final box = context.findRenderObject() as RenderBox;
    final W = box.size.width;
    final dx = pos.dx;
    final meterPos = (dx / W * widget.beam.length).clamp(0.0, widget.beam.length);
    final snapped = meterPos.roundToDouble();
    _dragDisplayMeters = snapped;
    double px;
    if (_dragging is DistributedLoad) {
      final d = _dragging as DistributedLoad;
      if (_dragMode == 'resizeStart') {
        px = (d.x / widget.beam.length) * W;
      } else if (_dragMode == 'resizeEnd') {
        px = (d.xEnd / widget.beam.length) * W;
      } else {
        px = ((d.x + d.xEnd) / 2) / widget.beam.length * W;
      }
    } else {
      px = (snapped / widget.beam.length) * W;
    }
    _dragDisplayOffset = Offset(px, BeamPainter.bY - 60);

    setState(() {
      if (_dragging is Support || _dragging is PointLoad) {
        final obj = _dragging;
        obj.x = snapped.clamp(0.0, widget.beam.length);
      } else if (_dragging is DistributedLoad) {
        final d = _dragging as DistributedLoad;
        final widthMeters = (d.xEnd - d.x).roundToDouble();
        if (_dragMode == 'resizeStart') {
          d.x = snapped.clamp(0.0, d.xEnd - 1.0);
        } else if (_dragMode == 'resizeEnd') {
          d.xEnd = snapped.clamp(d.x + 1.0, widget.beam.length);
        } else {
          final center = snapped;
          var newStart = (center - (widthMeters / 2)).clamp(0.0, widget.beam.length - widthMeters);
          newStart = newStart.roundToDouble();
          d.x = newStart;
          d.xEnd = (newStart + widthMeters).clamp(0.0, widget.beam.length);
        }
      }
    });
    selectedElementNotifier.value = _selected;
  }

  void _onPanEnd(BuildContext context) {
    setState(() {
      _dragging = null;
      _dragMode = null;
      _dragDisplayMeters = null;
      _dragDisplayOffset = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _handleTap(context, details.localPosition),
          onPanStart: (details) => _onPanStart(context, details.localPosition),
          onPanUpdate: (details) => _onPanUpdate(context, details.localPosition),
          onPanEnd: (details) => _onPanEnd(context),
          child: CustomPaint(
            painter: BeamPainter(widget.beam, _selected),
            size: Size(constraints.maxWidth, 200),
          ),
        ),
        if (_dragDisplayMeters != null && _dragDisplayOffset != null)
          Positioned(
            left: (_dragDisplayOffset!.dx - 36).clamp(4.0, constraints.maxWidth - 80.0),
            top: (_dragDisplayOffset!.dy - 40).clamp(4.0, 160.0),
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
                child: Text('${_dragDisplayMeters?.toStringAsFixed(0)} m', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ]);
    });
  }
}
