// ═══════════════════════════════════════════════════════════════
//  beam_editor_screen.dart  —  Écran principal (assemblage)
//
//  Corrections v4 :
//    - Crash drag → guard null sur _draggingId
//    - Bouton fermer plein écran affiché UNE SEULE FOIS
//    - Safe zone iPhone landscape via SafeArea
//    - withValues() partout (plus de withOpacity)
//    - Virgule acceptée dans tous les champs
//    - onTapOutside sur tous les TextFields
//    - Page théorèmes accessible depuis Géométrie
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'core/beam_colors.dart';
import 'core/beam_models.dart';
import 'core/beam_solver.dart';
import 'canvas/canvas_widget.dart';
import 'diagram/diagram_painter.dart';
import 'diagram/diagram_widget.dart';
import 'diagram/diagram_fullscreen.dart';
import 'panels/side_panel.dart';
import 'results/results_panel.dart';
import 'dialogs/support_dialog.dart';
import 'dialogs/load_dialog.dart';
import 'widgets/status_chip.dart';
import 'theory/theory_page.dart';

class BeamEditorScreen extends StatefulWidget {
  final BeamModel? initialModel;
  const BeamEditorScreen({super.key, this.initialModel});

  @override
  State<BeamEditorScreen> createState() => _BeamEditorScreenState();
}

class _BeamEditorScreenState extends State<BeamEditorScreen>
    with SingleTickerProviderStateMixin {

  late BeamModel _beam;
  List<String>   _errors = [];

  // Sélection / Drag
  String? _selectedId;
  String? _draggingId;
  double  _dragX = 0;

  // UI
  bool        _showReact        = false;
  bool        _canvasFullscreen = false;
  DiagramType _activeDiagram    = DiagramType.shear;

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _beam    = widget.initialModel ?? BeamModel.simplySupported();
    _tabCtrl = TabController(length: 3, vsync: this);
    _solve();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  CALCUL
  // ══════════════════════════════════════════════════════════════
  void _solve() {
    _errors = _beam.validate();
    if (_errors.isNotEmpty) { setState(() {}); return; }
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
    // Plein écran canvas : pas d'AppBar, pas de double bouton
    if (_canvasFullscreen) return _buildCanvasFullscreen();

    return Scaffold(
      backgroundColor: BC.surface,
      appBar: _buildAppBar(),
      body: OrientationBuilder(
        builder: (_, orientation) => orientation == Orientation.landscape
            ? _buildLandscape()
            : _buildPortrait(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  APP BAR
  // ══════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: BC.primary,
    foregroundColor: Colors.white,
    title: GestureDetector(
      onTap: _renameBeam,
      child: Row(children: [
        const Icon(Icons.architecture, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(_beam.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.edit, size: 13, color: Colors.white54),
      ]),
    ),
    actions: [
      PopupMenuButton<String>(
        icon: const Icon(Icons.library_books_outlined, size: 20),
        tooltip: 'Exemples',
        onSelected: (v) {
          setState(() {
            _beam = switch (v) {
              'simple'   => BeamModel.simplySupported(),
              'console'  => BeamModel.cantilever(),
              'continue' => BeamModel.continuous(),
              _          => _beam,
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
      IconButton(
        icon: const Icon(Icons.download_outlined, size: 20),
        tooltip: 'Export JSON',
        onPressed: _exportJson,
      ),
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
            textStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ],
  );

  // ══════════════════════════════════════════════════════════════
  //  LAYOUT PORTRAIT
  // ══════════════════════════════════════════════════════════════
  Widget _buildPortrait() => Column(children: [
    SizedBox(height: 190, child: _buildCanvas()),
    if (_errors.isNotEmpty) _buildErrorBanner(),
    if (_beam.results != null && _beam.results!.isValid)
      ResultsSummaryBar(results: _beam.results!),
    const Divider(height: 1),
    _buildPortraitTabBar(),
    Expanded(
      child: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildSidePanel(),
          _buildDiagramsArea(),
          ResultsPanel(beam: _beam),
        ],
      ),
    ),
  ]);

  // ══════════════════════════════════════════════════════════════
  //  LAYOUT LANDSCAPE  (safe zone iPhone via SafeArea dans les enfants)
  // ══════════════════════════════════════════════════════════════
  Widget _buildLandscape() => SafeArea(
    // SafeArea globale gère le notch / Dynamic Island en landscape
    child: Row(children: [
      SizedBox(
        width: 260,
        child: Container(
          color: Colors.white,
          child: _buildSidePanel(),
        ),
      ),
      const VerticalDivider(width: 1),
      Expanded(
        child: Column(children: [
          Expanded(flex: 2, child: _buildCanvas()),
          if (_errors.isNotEmpty) _buildErrorBanner(),
          if (_beam.results != null && _beam.results!.isValid) ...[
            ResultsSummaryBar(results: _beam.results!),
            const Divider(height: 1),
          ],
          Expanded(flex: 3, child: _buildDiagramsArea()),
        ]),
      ),
    ]),
  );

  // ══════════════════════════════════════════════════════════════
  //  CANVAS PLEIN ÉCRAN
  //  Bouton fermer affiché UNE SEULE FOIS ici (pas dans canvas_widget)
  // ══════════════════════════════════════════════════════════════
  Widget _buildCanvasFullscreen() => Scaffold(
    body: SafeArea(
      child: Stack(children: [
        // Canvas occupe tout l'écran (isFullscreen=true désactive
        // le bouton plein écran DANS le widget)
        _buildCanvas(fullscreenMode: true),

        // ── Bouton fermer (unique) ────────────────────────────
        Positioned(
          top: 8,
          right: MediaQuery.of(context).padding.right + 8,
          child: FilledButton.icon(
            onPressed: () => setState(() => _canvasFullscreen = false),
            icon: const Icon(Icons.fullscreen_exit, size: 16),
            label: const Text('Fermer'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: BC.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
            ),
          ),
        ),

        // Erreurs éventuelles
        if (_errors.isNotEmpty)
          Positioned(
              bottom: 16, left: 16,
              child: _buildErrorBanner()),
      ]),
    ),
  );

  // ══════════════════════════════════════════════════════════════
  //  CANVAS WIDGET
  // ══════════════════════════════════════════════════════════════
  Widget _buildCanvas({bool fullscreenMode = false}) => BeamCanvasWidget(
    beam:              _beam,
    selectedId:        _selectedId,
    draggingId:        _draggingId,
    dragX:             _dragX,
    showReactions:     _showReact && _beam.results != null,
    // En mode plein écran, on passe false pour cacher le bouton
    // "plein écran" dans le widget (le bouton fermer est géré ici)
    isFullscreen:      false,
    onSelect:          (id) => setState(() => _selectedId = id),
    onDragStart: (id) => setState(() {
      _draggingId = id;
      _selectedId = id;
    }),
    onDragUpdate: (px) {
      // Guard : uniquement si un drag est en cours
      if (_draggingId == null) return;
      setState(() => _dragX = px);
    },
    onDragEnd: (pos) {
      // Guard : évite le crash si _draggingId est null
      final id = _draggingId;
      if (id == null) return;
      _applyDrag(id, pos);
      setState(() => _draggingId = null);
    },
    onDragCancel:       () => setState(() => _draggingId = null),
    onAddSupport:       _addSupport,
    onAddLoad:          _addLoad,
    onToggleReactions:  () => setState(() => _showReact = !_showReact),
    // Basculer plein écran canvas
    onToggleFullscreen: fullscreenMode
        ? () => setState(() => _canvasFullscreen = false)
        : () => setState(() => _canvasFullscreen = true),
  );

  // ══════════════════════════════════════════════════════════════
  //  PANNEAU LATÉRAL
  // ══════════════════════════════════════════════════════════════
  Widget _buildSidePanel() => SidePanel(
    beam:             _beam,
    selectedId:       _selectedId,
    onAddSupport:     _addSupport,
    onSelectSupport:  (id) => setState(() => _selectedId = id),
    onEditSupport:    _editSupport,
    onDeleteSupport:  _removeSupport,
    onAddLoad:        _addLoad,
    onSelectLoad:     (id) => setState(() => _selectedId = id),
    onEditLoad:       _editLoad,
    onDeleteLoad:     _removeLoad,
    onLengthChanged:  (v) => setState(() => _beam.length = v),
    onNameChanged:    (v) => _beam.name = v,
    onLengthSubmitted: _solve,
    onOpenTheory:     _openTheory,
  );

  // ══════════════════════════════════════════════════════════════
  //  DIAGRAMMES
  // ══════════════════════════════════════════════════════════════
  Widget _buildDiagramsArea() {
    final r = _beam.results;
    if (r == null || !r.isValid) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calculate_outlined, size: 36, color: BC.textM),
          const SizedBox(height: 8),
          const Text('Appuyez sur "Calculer"',
              style: TextStyle(color: BC.textS, fontSize: 13)),
          if (_errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            StatusChip(message: _errors.first, isError: true),
          ],
        ]),
      );
    }
    return Column(children: [
      DiagramToggleBar(
        active:       _activeDiagram,
        onChanged:    (t) => setState(() => _activeDiagram = t),
        onFullscreen: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => DiagramFullscreenPage(
            results:    r,
            beamLength: _beam.length,
          ),
        )),
      ),
      Expanded(
        child: DiagramWidget(
          results:    r,
          type:       _activeDiagram,
          beamLength: _beam.length,
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  TAB BAR PORTRAIT
  // ══════════════════════════════════════════════════════════════
  Widget _buildPortraitTabBar() => TabBar(
    controller:            _tabCtrl,
    labelColor:            BC.primary,
    unselectedLabelColor:  BC.textM,
    indicatorColor:        BC.primary,
    labelStyle:            const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle:  const TextStyle(fontSize: 12),
    tabs: const [
      Tab(text: 'Propriétés'),
      Tab(text: 'Diagrammes'),
      Tab(text: 'Résultats'),
    ],
  );

  // ══════════════════════════════════════════════════════════════
  //  BANNIÈRE D'ERREURS
  // ══════════════════════════════════════════════════════════════
  Widget _buildErrorBanner() => Container(
    color: Colors.red.shade50,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _errors.map((e) => Row(children: [
        const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
        const SizedBox(width: 6),
        Flexible(child: Text(e,
            style: const TextStyle(fontSize: 11, color: Colors.red))),
      ])).toList(),
    ),
  );

  // ══════════════════════════════════════════════════════════════
  //  ACTIONS — APPUIS
  // ══════════════════════════════════════════════════════════════
  Future<void> _addSupport() async {
    final res = await showDialog<BeamSupport>(
      context: context,
      builder: (_) => SupportDialog(beamLength: _beam.length),
    );
    if (res != null) { setState(() => _beam.supports.add(res)); _solve(); }
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
    final ok = await confirmDelete(context, '"${s.label}"');
    if (ok == true) {
      setState(() => _beam.supports.removeWhere((x) => x.id == s.id));
      _solve();
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  ACTIONS — CHARGES
  // ══════════════════════════════════════════════════════════════
  Future<void> _addLoad() async {
    final res = await showDialog<BeamLoad>(
      context: context,
      builder: (_) => LoadDialog(beamLength: _beam.length),
    );
    if (res != null) { setState(() => _beam.loads.add(res)); _solve(); }
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

  // ══════════════════════════════════════════════════════════════
  //  DRAG & DROP
  // ══════════════════════════════════════════════════════════════
  void _applyDrag(String id, double newPos) {
    final si = _beam.supports.indexWhere((s) => s.id == id);
    if (si >= 0) {
      setState(() =>
          _beam.supports[si] = _beam.supports[si].copyWith(position: newPos));
      _solve();
      return;
    }
    final li = _beam.loads.indexWhere((l) => l.id == id);
    if (li >= 0) {
      setState(() =>
          _beam.loads[li] = _beam.loads[li].copyWith(position: newPos));
      _solve();
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  RENOMMER
  // ══════════════════════════════════════════════════════════════
  Future<void> _renameBeam() async {
    final ctrl  = TextEditingController(text: _beam.name);
    final focus = FocusNode();
    final res   = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renommer la poutre'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        content: TextField(
          controller:   ctrl,
          focusNode:    focus,
          autofocus:    true,
          decoration:   const InputDecoration(labelText: 'Nom'),
          onTapOutside: (_) => focus.unfocus(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
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

  // ══════════════════════════════════════════════════════════════
  //  PAGE THÉORÈMES
  // ══════════════════════════════════════════════════════════════
  void _openTheory() => Navigator.push(context, MaterialPageRoute(
    builder: (_) => const TheoryPage(),
  ));

  // ══════════════════════════════════════════════════════════════
  //  EXPORT JSON
  // ══════════════════════════════════════════════════════════════
  Future<void> _exportJson() async {
    try {
      final json = const JsonEncoder.withIndent('  ').convert({
        'version':    '4.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'model':      _beam.toJson(),
        if (_beam.results != null) 'results': _beam.results!.toJson(),
      });
      final dir  = await getTemporaryDirectory();
      final name = _beam.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      await File('${dir.path}/$name.json').writeAsString(json);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Export JSON'),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          content: SizedBox(
            width: 400,
            child: Container(
              height: 220,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10)),
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
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer')),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'),
              backgroundColor: Colors.red));
    }
  }
}
