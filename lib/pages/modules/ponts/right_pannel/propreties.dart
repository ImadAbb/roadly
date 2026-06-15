import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/selection_notifier.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/classes.dart';

class Propreties extends StatefulWidget {
  final Beam beam;
  const Propreties({super.key, required this.beam});

  @override
  State<Propreties> createState() => _PropretiesState();
}

class _PropretiesState extends State<Propreties> {
  dynamic _selected;
  final TextEditingController _beamLengthCtrl = TextEditingController();

  // ── Controllers pour Support ──────────────────────────────────────────────
  final TextEditingController _supportXCtrl = TextEditingController();

  // ── Controllers pour PointLoad ────────────────────────────────────────────
  final TextEditingController _pointXCtrl = TextEditingController();
  final TextEditingController _pointVCtrl = TextEditingController();

  // ── Controllers pour DistributedLoad ─────────────────────────────────────
  final TextEditingController _distXCtrl    = TextEditingController();
  final TextEditingController _distXEndCtrl = TextEditingController();
  final TextEditingController _distVCtrl    = TextEditingController();

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selected = selectedElementNotifier.value;
    _beamLengthCtrl.text = widget.beam.length.toString();
    _syncControllers(_selected);
    selectedElementNotifier.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    selectedElementNotifier.removeListener(_onSelectionChanged);
    // Dispose de tous les controllers pour éviter les memory leaks
    _beamLengthCtrl.dispose();
    _supportXCtrl.dispose();
    _pointXCtrl.dispose();
    _pointVCtrl.dispose();
    _distXCtrl.dispose();
    _distXEndCtrl.dispose();
    _distVCtrl.dispose();
    super.dispose();
  }

  /// Synchronise les controllers avec l'élément sélectionné
  void _syncControllers(dynamic element) {
    if (element is Support) {
      _supportXCtrl.text = element.x.toString();
    } else if (element is DistributedLoad) {
      _distXCtrl.text    = element.x.toString();
      _distXEndCtrl.text = element.xEnd.toString();
      _distVCtrl.text    = element.value.toString();
    } else if (element is PointLoad) {
      _pointXCtrl.text = element.x.toString();
      _pointVCtrl.text = element.value.toString();
    }
  }

  void _onSelectionChanged() {
    setState(() {
      _selected = selectedElementNotifier.value;
      _syncControllers(_selected);
      _beamLengthCtrl.text = widget.beam.length.toString();
    });
  }

  /// Notifie les listeners en forçant un changement réel
  void _notifyChange() {
    // On force la notification en assignant null puis la valeur
    // car ValueNotifier ignore les réassignations identiques
    final current = selectedElementNotifier.value;
    selectedElementNotifier.value = null;
    selectedElementNotifier.value = current;
  }

  // ── Formulaire Support ────────────────────────────────────────────────────

  Widget _buildSupportForm(Support s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Support',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Type
        Row(children: [
          const Text('Type : '),
          const SizedBox(width: 8),
          DropdownButton<SupportType>(
            value: s.type,
            items: SupportType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.toString().split('.').last),
                    ))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => s.type = v);
              _notifyChange();
            },
          ),
        ]),
        const SizedBox(height: 12),

        // Position x
        TextField(
          controller: _supportXCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Position x (m)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (t) {
            final v = double.tryParse(t);
            if (v == null) return;
            setState(() => s.x = v);
            _notifyChange();
          },
        ),
      ],
    );
  }

  // ── Formulaire PointLoad ──────────────────────────────────────────────────

  Widget _buildPointLoadForm(PointLoad p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Charge',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Type (ponctuelle / répartie)
        Row(children: [
          const Text('Type : '),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: 'ponctuelle',
            items: ['ponctuelle', 'repartie']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) {
              if (v == null || v == 'ponctuelle') return;
              // Convertir en DistributedLoad
              final idx = widget.beam.loads.indexOf(p);
              if (idx == -1) return;
              final newLoad = DistributedLoad(p.x, p.x + 2.0, p.value);
              widget.beam.loads[idx] = newLoad;
              setState(() => _selected = newLoad);
              _syncControllers(newLoad);
              selectedElementNotifier.value = newLoad;
            },
          ),
        ]),
        const SizedBox(height: 12),

        // Position x
        TextField(
          controller: _pointXCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Position (m)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (t) {
            final v = double.tryParse(t);
            if (v == null) return;
            setState(() => p.x = v);
            _notifyChange();
          },
        ),
        const SizedBox(height: 12),

        // Valeur
        TextField(
          controller: _pointVCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valeur (kN)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (t) {
            final v = double.tryParse(t);
            if (v == null) return;
            setState(() => p.value = v);
            _notifyChange();
          },
        ),
      ],
    );
  }

  // ── Formulaire DistributedLoad ────────────────────────────────────────────

  Widget _buildDistributedLoadForm(DistributedLoad d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Charge',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Type (répartie / ponctuelle)
        Row(children: [
          const Text('Type : '),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: 'repartie',
            items: ['repartie', 'ponctuelle']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) {
              if (v == null || v == 'repartie') return;
              // Convertir en PointLoad
              final idx = widget.beam.loads.indexOf(d);
              if (idx == -1) return;
              final newLoad = PointLoad(d.x, d.value);
              widget.beam.loads[idx] = newLoad;
              setState(() => _selected = newLoad);
              _syncControllers(newLoad);
              selectedElementNotifier.value = newLoad;
            },
          ),
        ]),
        const SizedBox(height: 12),

        // Début x
        TextField(
          controller: _distXCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Début (m)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (t) {
            final v = double.tryParse(t);
            if (v == null) return;
            setState(() => d.x = v);
            _notifyChange();
          },
        ),
        const SizedBox(height: 12),

        // Fin xEnd
        TextField(
          controller: _distXEndCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Fin (m)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (t) {
            final v = double.tryParse(t);
            if (v == null) return;
            setState(() => d.xEnd = v);
            _notifyChange();
          },
        ),
        const SizedBox(height: 12),

        // Valeur
        TextField(
          controller: _distVCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valeur (kN/m)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (t) {
            final v = double.tryParse(t);
            if (v == null) return;
            setState(() => d.value = v);
            _notifyChange();
          },
        ),
      ],
    );
  }

  // ── Build principal ───────────────────────────────────────────────────────

  Widget _buildBeamForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'POUTRE',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        const Text('Longueur :'),
        const SizedBox(height: 8),
        TextField(
          controller: _beamLengthCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixText: 'm',
          ),
          onSubmitted: (t) {
            final v = double.tryParse(t);
            if (v == null) return;
            setState(() {
              widget.beam.length = v;
              _beamLengthCtrl.text = v.toString();
            });
            _notifyChange();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_selected == null) {
      content = Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sélectionnez un élément\nsur le dessin',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildBeamForm(),
          ],
        ),
      );
    } else if (_selected is DistributedLoad) {
      // DistributedLoad AVANT PointLoad car DistributedLoad étend PointLoad
      content = Padding(
        padding: const EdgeInsets.all(12.0),
        child: _buildDistributedLoadForm(_selected as DistributedLoad),
      );
    } else if (_selected is PointLoad) {
      content = Padding(
        padding: const EdgeInsets.all(12.0),
        child: _buildPointLoadForm(_selected as PointLoad),
      );
    } else if (_selected is Support) {
      content = Padding(
        padding: const EdgeInsets.all(12.0),
        child: _buildSupportForm(_selected as Support),
      );
    } else {
      content = const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text("Type d'élément non pris en charge"),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: content,
      ),
    );
  }
}
