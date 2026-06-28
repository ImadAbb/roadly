// ═══════════════════════════════════════════════════════════════
//  beam_editor_screen.dart  —  Écran principal
//
//  Nouveautés v2 :
//    • Toutes orientations acceptées (SystemChrome dans initState)
//    • Drag & drop des appuis et charges sur le canvas
//    • Focus conservé dans les champs (controllers stables)
//    • Layout landscape optimisé
//    • Mode plein écran canvas (bouton dédié)
//    • Mode plein écran diagrammes
//    • Tap sur diagramme → valeur V ou M au point cliqué
//    • Section supprimée, calcul V et M uniquement
//
//  Importer : import '../screens/beam_editor_screen.dart';
//  Usage    : Navigator.push(context,
//               MaterialPageRoute(builder: (_) => const BeamEditorScreen()));
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/beam_models.dart';
import '../services/beam_solver.dart';
import '../painters/beam_canvas_painter.dart';
import '../painters/diagram_painter.dart';
import '../widgets/beam_widgets.dart';

class BeamEditorScreen extends StatefulWidget {
  final BeamModel? initialModel;
  const BeamEditorScreen({super.key, this.initialModel});

  @override
  State<BeamEditorScreen> createState() => _BeamEditorScreenState();
}

class _BeamEditorScreenState extends State<BeamEditorScreen>
    with SingleTickerProviderStateMixin {
  // ── Modèle ────────────────────────────────────────────────────
  late BeamModel _beam;
  List<String> _errors = [];

  // ── Sélection / Drag ──────────────────────────────────────────
  String? _selectedId;
  String? _draggingId;
  double  _dragX = 0;

  // ── UI ────────────────────────────────────────────────────────
  int  _sideTab     = 0;   // 0=Appuis 1=Charges 2=Résultats
  bool _showReact   = false;
  bool _canvasFullscreen  = false;
  bool _diagramFullscreen = false;

  // ── Diagramme actif ───────────────────────────────────────────
  DiagramType _activeDiagram = DiagramType.shear;
  double? _cursorXShear;
  double? _cursorXMoment;

  // ── Tabs (layout narrow) ─────────────────────────────────────
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    // ↓ Accepter TOUTES les orientations
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    _beam = widget.initialModel ?? BeamModel.simplySupported();
    _tabCtrl = TabController(length: 3, vsync: this);
    _solve();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    // ↓ Remettre portrait uniquement si le reste de l'app le requiert
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  CALCUL
  // ══════════════════════════════════════════════════════════════
  void _solve() {
    _errors = _beam.validate();
    if (_errors.isNotEmpty) { setState(() {}); return; }
    setState(() {});
    Future.microtask(() {
      final r = BeamSolver.solve(_beam);
      if (mounted) setState(() => _beam.results = r);
    });
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _canvasFullscreen || _diagramFullscreen ? null : _buildAppBar(),
      body: OrientationBuilder(builder: (ctx, orientation) {
        if (_canvasFullscreen)   return _buildFullscreenCanvas();
        if (_diagramFullscreen)  return _buildFullscreenDiagram();
        return orientation == Orientation.landscape
            ? _buildLandscape()
            : _buildPortrait();
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  APP BAR
  // ══════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: GestureDetector(
        onTap: _renameBeam,
        child: Row(children: [
          const Icon(Icons.architecture, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(_beam.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.edit, size: 13, color: Colors.white54),
        ]),
      ),
      backgroundColor: BC.primary,
      foregroundColor: Colors.white,
      actions: [
        // Exemples
        PopupMenuButton<String>(
          icon: const Icon(Icons.library_books_outlined, size: 20),
          tooltip: 'Exemples',
          onSelected: (v) {
            setState(() {
              _beam = switch (v) {
                'simple'   => BeamModel.simplySupported(),
                'console'  => BeamModel.cantilever(),
                'continue' => BeamModel.continuous(),
                _ => _beam,
              };
            });
            _solve();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'simple',   child: Text('Poutre bi-appuyée')),
            PopupMenuItem(value: 'console',  child: Text('Console')),
            PopupMenuItem(value: 'continue', child: Text('Poutre continue')),
          ],
        ),
        // Export JSON
        IconButton(
          icon: const Icon(Icons.download_outlined, size: 20),
          tooltip: 'Exporter JSON',
          onPressed: _exportJson,
        ),
        // Calculer
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilledButton.icon(
            onPressed: _solve,
            icon: const Icon(Icons.calculate_outlined, size: 17),
            label: const Text('Calculer'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: BC.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LAYOUT PORTRAIT
  // ══════════════════════════════════════════════════════════════
  Widget _buildPortrait() {
    return Column(children: [
      // Canvas poutre
      SizedBox(height: 190, child: _buildCanvas()),
      // Erreurs
      if (_errors.isNotEmpty) _buildErrorBanner(),
      // Résumé résultats
      if (_beam.results != null && _beam.results!.isValid)
        _buildResultsBar(),
      const Divider(height: 1),
      // Tabs
      _buildTabBar(),
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildSidePanel(),
            _buildDiagramsPanel(),
            _buildResultsPanel(),
          ],
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  LAYOUT LANDSCAPE
  // ══════════════════════════════════════════════════════════════
  Widget _buildLandscape() {
    return Row(children: [
      // Panneau gauche (plus étroit en landscape)
      Container(
        width: 260,
        color: Colors.white,
        child: Column(children: [
          _buildSideTabs(),
          Expanded(child: _buildSidePanel()),
        ]),
      ),
      const VerticalDivider(width: 1),
      // Zone droite : canvas + diagrammes empilés
      Expanded(
        child: Column(children: [
          // Canvas
          Expanded(flex: 2, child: _buildCanvas()),
          if (_errors.isNotEmpty) _buildErrorBanner(),
          const Divider(height: 1),
          // Résumé résultats
          if (_beam.results != null && _beam.results!.isValid)
            _buildResultsBar(),
          const Divider(height: 1),
          // Diagrammes côte à côte
          Expanded(flex: 3, child: _buildDiagramsPanel()),
        ]),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  CANVAS PLEIN ÉCRAN
  // ══════════════════════════════════════════════════════════════
  Widget _buildFullscreenCanvas() {
    return Stack(children: [
      _buildCanvas(fullscreen: true),
      // Bouton fermer
      Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        right: 12,
        child: _fsBtn(Icons.fullscreen_exit, 'Quitter plein écran',
            () => setState(() => _canvasFullscreen = false)),
      ),
      // Erreurs
      if (_errors.isNotEmpty)
        Positioned(bottom: 16, left: 16, child: _buildErrorBanner()),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  DIAGRAMME PLEIN ÉCRAN
  // ══════════════════════════════════════════════════════════════
  Widget _buildFullscreenDiagram() {
    return SafeArea(
      child: Column(children: [
        // Toggle V/M + bouton fermer
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            _diagramToggle(DiagramType.shear,  'V (kN)',   BC.shear),
            const SizedBox(width: 8),
            _diagramToggle(DiagramType.moment, 'M (kN·m)', BC.moment),
            const Spacer(),
            _fsBtn(Icons.fullscreen_exit, 'Fermer',
                () => setState(() => _diagramFullscreen = false)),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: _buildSingleDiagramInteractive(_activeDiagram)),
        if (_beam.results != null && _beam.results!.isValid)
          _buildResultsBar(),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  CANVAS INTERACTIF
  // ══════════════════════════════════════════════════════════════
  Widget _buildCanvas({bool fullscreen = false}) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: LayoutBuilder(builder: (ctx, box) {
        final W = box.maxWidth, H = box.maxHeight;
        final scale   = (W - 100) / _beam.length;
        const offsetX = 52.0;
        final offsetY = H * 0.50;

        return Stack(children: [
          // ── GestureDetector principal ──────────────────────
          GestureDetector(
            // Tap simple = sélection
            onTapDown: (d) {
              final hit = CanvasHitTest.hitTest(
                  _beam, d.localPosition, scale, offsetX, offsetY);
              setState(() => _selectedId = hit);
            },
            // Appui long = début de drag
            onLongPressStart: (d) {
              final hit = CanvasHitTest.hitTest(
                  _beam, d.localPosition, scale, offsetX, offsetY);
              if (hit != null) {
                setState(() {
                  _draggingId = hit;
                  _dragX = d.localPosition.dx;
                  _selectedId = hit;
                });
              }
            },
            onLongPressMoveUpdate: (d) {
              if (_draggingId == null) return;
              setState(() => _dragX = d.localPosition.dx.clamp(offsetX, offsetX + _beam.length * scale));
            },
            onLongPressEnd: (d) {
              if (_draggingId == null) return;
              final newPos = ((_dragX - offsetX) / scale)
                  .clamp(0.0, _beam.length);
              _applyDrag(_draggingId!, newPos);
              setState(() => _draggingId = null);
            },
            onLongPressCancel: () => setState(() => _draggingId = null),
            child: CustomPaint(
              size: Size(W, H),
              painter: BeamCanvasPainter(
                beam: _beam,
                scale: scale,
                offsetX: offsetX,
                offsetY: offsetY,
                selectedId: _selectedId,
                draggingId: _draggingId,
                dragX: _dragX,
                showReactions: _showReact && _beam.results != null,
                showDimensions: true,
              ),
            ),
          ),

          // ── Boutons canvas ────────────────────────────────
          Positioned(
            top: 8, right: 8,
            child: Wrap(
              spacing: 5,
              children: [
                _canvasChip(
                  _showReact ? Icons.visibility_off : Icons.visibility,
                  _showReact ? 'Masquer R' : 'Réactions',
                  active: _showReact,
                  onTap: () => setState(() => _showReact = !_showReact),
                ),
                _canvasChip(Icons.add_circle_outline, 'Appui',
                    onTap: _addSupport),
                _canvasChip(Icons.arrow_downward, 'Charge',
                    onTap: _addLoad),
                _canvasChip(
                  fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  fullscreen ? 'Fermer' : 'Plein écran',
                  onTap: () => setState(
                      () => _canvasFullscreen = !_canvasFullscreen),
                ),
              ],
            ),
          ),

          // ── Hint drag ─────────────────────────────────────
          if (_beam.supports.isNotEmpty || _beam.loads.isNotEmpty)
            Positioned(
              bottom: 6, left: 8,
              child: Text('Appui long pour déplacer un élément',
                  style: TextStyle(
                      fontSize: 9.5,
                      color: BC.textM.withValues(alpha: 0.8))),
            ),
        ]);
      }),
    );
  }

  void _applyDrag(String id, double newPos) {
    final sIdx = _beam.supports.indexWhere((s) => s.id == id);
    if (sIdx >= 0) {
      _beam.supports[sIdx] = _beam.supports[sIdx].copyWith(position: newPos);
      _solve();
      return;
    }
    final lIdx = _beam.loads.indexWhere((l) => l.id == id);
    if (lIdx >= 0) {
      _beam.loads[lIdx] = _beam.loads[lIdx].copyWith(position: newPos);
      _solve();
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  PANNEAU LATÉRAL
  // ══════════════════════════════════════════════════════════════
  Widget _buildSideTabs() {
    final tabs = ['Appuis', 'Charges', 'Géométrie'];
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final sel = e.key == _sideTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _sideTab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? BC.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(e.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : BC.textS)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSidePanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: switch (_sideTab) {
        0 => _buildSupportsPanel(),
        1 => _buildLoadsPanel(),
        2 => _buildGeoPanel(),
        _ => const SizedBox(),
      },
    );
  }

  // ── Géométrie ────────────────────────────────────────────────
  Widget _buildGeoPanel() {
    // Controller stable créé une fois — pas dans build()
    final ctrl = TextEditingController(text: _beam.length.toStringAsFixed(2));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sLabel('Longueur de la poutre'),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          decoration: InputDecoration(
            suffixText: 'm',
            suffixStyle: const TextStyle(color: BC.textS),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: BC.primary, width: 1.5)),
            filled: true, fillColor: Colors.white,
          ),
          onChanged: (v) {
            final d = double.tryParse(v);
            if (d != null && d >= 0.5 && d <= 200) {
              setState(() => _beam.length = d);
            }
          },
          onSubmitted: (_) => _solve(),
        ),
        const SizedBox(height: 14),
        _sLabel('Nom du projet'),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: _beam.name,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true, fillColor: Colors.white,
          ),
          onChanged: (v) => _beam.name = v,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BC.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Convention de signes',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: BC.primary)),
              SizedBox(height: 6),
              Text(
                '• x = 0 : extrémité gauche\n'
                '• Force positive ↓ vers le bas\n'
                '• Moment positif ↻ sens horaire\n'
                '• Appui long sur un élément pour le déplacer',
                style: TextStyle(fontSize: 11, color: BC.textS, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Appuis ───────────────────────────────────────────────────
  Widget _buildSupportsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_beam.supports.length} appui(s)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: BC.primary)),
            TextButton.icon(
              onPressed: _addSupport,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(
                  foregroundColor: BC.support,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (_beam.supports.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: StatusChip(message: 'Aucun appui défini', isError: true),
          ),
        ..._beam.supports.map((s) => SupportTile(
              support: s,
              selected: _selectedId == s.id,
              onTap: () => setState(
                  () => _selectedId = s.id == _selectedId ? null : s.id),
              onEdit: () => _editSupport(s),
              onDelete: () => _removeSupport(s),
            )),
      ],
    );
  }

  // ── Charges ──────────────────────────────────────────────────
  Widget _buildLoadsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_beam.loads.length} charge(s)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: BC.primary)),
            TextButton.icon(
              onPressed: _addLoad,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(
                  foregroundColor: BC.load,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (_beam.loads.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: StatusChip(message: 'Aucune charge définie', isError: true),
          ),
        ..._beam.loads.map((l) => LoadTile(
              load: l,
              selected: _selectedId == l.id,
              onTap: () => setState(
                  () => _selectedId = l.id == _selectedId ? null : l.id),
              onEdit: () => _editLoad(l),
              onDelete: () => _removeLoad(l),
            )),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  DIAGRAMMES
  // ══════════════════════════════════════════════════════════════
  Widget _buildDiagramsPanel() {
    if (_beam.results == null || !_beam.results!.isValid) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calculate_outlined, size: 36, color: BC.textM),
            const SizedBox(height: 8),
            const Text('Appuyez sur "Calculer"',
                style: TextStyle(color: BC.textS, fontSize: 13)),
            if (_errors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: StatusChip(message: _errors.first, isError: true),
              ),
          ],
        ),
      );
    }

    return Column(children: [
      // Toggle + plein écran
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(children: [
          _diagramToggle(DiagramType.shear,  'V (kN)',   BC.shear),
          const SizedBox(width: 6),
          _diagramToggle(DiagramType.moment, 'M (kN·m)', BC.moment),
          const Spacer(),
          _fsBtn(Icons.fullscreen, 'Plein écran',
              () => setState(() => _diagramFullscreen = true)),
        ]),
      ),
      // Diagramme actif avec tap
      Expanded(child: _buildSingleDiagramInteractive(_activeDiagram)),
    ]);
  }

  /// Diagramme unique interactif (tap → curseur)
  Widget _buildSingleDiagramInteractive(DiagramType type) {
    if (_beam.results == null) return const SizedBox();
    final cursorX = type == DiagramType.shear ? _cursorXShear : _cursorXMoment;

    return GestureDetector(
      // Tap = placer le curseur
      onTapDown: (d) => setState(() {
        if (type == DiagramType.shear) {
          _cursorXShear = d.localPosition.dx;
        } else {
          _cursorXMoment = d.localPosition.dx;
        }
      }),
      // Drag horizontal = déplacer le curseur
      onHorizontalDragUpdate: (d) => setState(() {
        if (type == DiagramType.shear) {
          _cursorXShear = (_cursorXShear ?? d.localPosition.dx) + d.delta.dx;
        } else {
          _cursorXMoment = (_cursorXMoment ?? d.localPosition.dx) + d.delta.dx;
        }
      }),
      // Double tap = effacer le curseur
      onDoubleTap: () => setState(() {
        if (type == DiagramType.shear) {
          _cursorXShear = null;
        } else {
          _cursorXMoment = null;
        }
      }),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BC.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [
            CustomPaint(
              size: Size.infinite,
              painter: DiagramPainter(
                results: _beam.results!,
                type: type,
                beamLength: _beam.length,
                color: type == DiagramType.shear ? BC.shear : BC.moment,
                cursorX: cursorX,
              ),
            ),
            // Hint
            if (cursorX == null)
              Positioned(
                bottom: 6, right: 8,
                child: Text('Touchez pour inspecter · Double tap pour effacer',
                    style: TextStyle(
                        fontSize: 9, color: BC.textM.withValues(alpha: 0.7))),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _diagramToggle(DiagramType t, String label, Color color) {
    final sel = _activeDiagram == t;
    return GestureDetector(
      onTap: () => setState(() => _activeDiagram = t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: sel ? color : BC.border, width: sel ? 1.5 : 1),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? color : BC.textS)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  PANNEAU RÉSULTATS
  // ══════════════════════════════════════════════════════════════
  Widget _buildResultsPanel() {
    final r = _beam.results;
    if (r == null || !r.isValid) {
      return const Center(
          child: Text('Pas de résultats — calculez d\'abord.',
              style: TextStyle(color: BC.textS)));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sLabel('Réactions d\'appui'),
        const SizedBox(height: 8),
        ..._beam.supports.map(_reactionTile),
        const SizedBox(height: 16),
        _sLabel('Valeurs caractéristiques'),
        const SizedBox(height: 8),
        _resultRow('V max', '${r.maxShear.toStringAsFixed(2)} kN', BC.shear),
        _resultRow('V min', '${r.minShear.toStringAsFixed(2)} kN', BC.shear),
        _resultRow('M max', '${r.maxMoment.toStringAsFixed(2)} kN·m', BC.moment),
        _resultRow('M min', '${r.minMoment.toStringAsFixed(2)} kN·m', BC.moment),
        _resultRow('Position M max', '${r.posMaxMoment.toStringAsFixed(2)} m', BC.moment),
      ],
    );
  }

  Widget _reactionTile(BeamSupport s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BC.border),
      ),
      child: Row(children: [
        const Icon(Icons.arrow_upward, color: BC.support, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${s.label} · x = ${s.position.toStringAsFixed(2)} m',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(
                'RV = ${s.reactionV.toStringAsFixed(2)} kN'
                '${s.reactionH.abs() > 0.01 ? '  RH = ${s.reactionH.toStringAsFixed(2)} kN' : ''}'
                '${s.reactionM.abs() > 0.01 ? '  RM = ${s.reactionM.toStringAsFixed(2)} kN·m' : ''}',
                style: const TextStyle(fontSize: 11, color: BC.textS, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: BC.textS)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  BARRE DE RÉSULTATS (résumé compact)
  // ══════════════════════════════════════════════════════════════
  Widget _buildResultsBar() {
    final r = _beam.results!;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(children: [
        ResultChip(
            label: 'V max',
            value: '${r.maxShear.abs().toStringAsFixed(1)} kN',
            color: BC.shear),
        const SizedBox(width: 6),
        ResultChip(
            label: 'M max',
            value: '${r.maxMoment.abs().toStringAsFixed(1)} kN·m',
            color: BC.moment),
        const SizedBox(width: 6),
        ResultChip(
            label: 'M min',
            value: '${r.minMoment.toStringAsFixed(1)} kN·m',
            color: BC.moment.withValues(alpha: 0.7)),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  BANNIÈRE D'ERREURS
  // ══════════════════════════════════════════════════════════════
  Widget _buildErrorBanner() {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _errors
            .map((e) => Row(children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(e,
                        style: const TextStyle(fontSize: 11, color: Colors.red)),
                  ),
                ]))
            .toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  TAB BAR (portrait uniquement)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabCtrl,
      labelColor: BC.primary,
      unselectedLabelColor: BC.textM,
      indicatorColor: BC.primary,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      tabs: const [
        Tab(text: 'Propriétés'),
        Tab(text: 'Diagrammes'),
        Tab(text: 'Résultats'),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  ACTIONS
  // ══════════════════════════════════════════════════════════════
  Future<void> _addSupport() async {
    final res = await showDialog<BeamSupport>(
      context: context,
      builder: (_) => SupportDialog(beamLength: _beam.length),
    );
    if (res != null) {
      setState(() => _beam.supports.add(res));
      _solve();
    }
  }

  Future<void> _editSupport(BeamSupport s) async {
    final res = await showDialog<BeamSupport>(
      context: context,
      builder: (_) => SupportDialog(existing: s, beamLength: _beam.length),
    );
    if (res != null) {
      final i = _beam.supports.indexWhere((x) => x.id == s.id);
      if (i >= 0) { setState(() => _beam.supports[i] = res); _solve(); }
    }
  }

  Future<void> _removeSupport(BeamSupport s) async {
    final ok = await confirmDelete(context, 'l\'appui "${s.label}"');
    if (ok == true) {
      setState(() => _beam.supports.removeWhere((x) => x.id == s.id));
      _solve();
    }
  }

  Future<void> _addLoad() async {
    final res = await showDialog<BeamLoad>(
      context: context,
      builder: (_) => LoadDialog(beamLength: _beam.length),
    );
    if (res != null) {
      setState(() => _beam.loads.add(res));
      _solve();
    }
  }

  Future<void> _editLoad(BeamLoad l) async {
    final res = await showDialog<BeamLoad>(
      context: context,
      builder: (_) => LoadDialog(existing: l, beamLength: _beam.length),
    );
    if (res != null) {
      final i = _beam.loads.indexWhere((x) => x.id == l.id);
      if (i >= 0) { setState(() => _beam.loads[i] = res); _solve(); }
    }
  }

  Future<void> _removeLoad(BeamLoad l) async {
    final ok = await confirmDelete(context, 'cette charge');
    if (ok == true) {
      setState(() => _beam.loads.removeWhere((x) => x.id == l.id));
      _solve();
    }
  }

  Future<void> _renameBeam() async {
    final ctrl = TextEditingController(text: _beam.name);
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renommer la poutre'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: BC.primary),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) setState(() => _beam.name = res);
  }

  Future<void> _exportJson() async {
    try {
      final data = const JsonEncoder.withIndent('  ').convert({
        'version': '2.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'model': _beam.toJson(),
        if (_beam.results != null) 'results': _beam.results!.toJson(),
      });
      final dir  = await getTemporaryDirectory();
      final name = _beam.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final file = File('${dir.path}/$name.json');
      await file.writeAsString(data);
      if (!mounted) return;
      _showJsonPreview(data, file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur export : $e'),
              backgroundColor: Colors.red));
    }
  }

  void _showJsonPreview(String json, String path) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export JSON'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(path,
                  style: const TextStyle(fontSize: 11, color: BC.textS)),
              const SizedBox(height: 10),
              Container(
                height: 200,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    json.substring(0, json.length.clamp(0, 900)) +
                        (json.length > 900 ? '\n...' : ''),
                    style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer')),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HELPERS UI
  // ══════════════════════════════════════════════════════════════
  Widget _canvasChip(IconData icon, String label,
      {required VoidCallback onTap, bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: active ? BC.primary : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
              color: active ? BC.primary : BC.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14,
                color: active ? Colors.white : BC.textS),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10.5,
                    color: active ? Colors.white : BC.textS,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _fsBtn(IconData icon, String tooltip, VoidCallback onTap) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: BC.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: BC.textS),
          ),
        ),
      );

  Widget _sLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: BC.primary));
}
