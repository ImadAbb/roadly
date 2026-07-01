// ═══════════════════════════════════════════════════════════════
//  dialogs/load_dialog.dart
//  Dialogue charge — virgule acceptée, onTapOutside, withValues
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';

class LoadDialog extends StatefulWidget {
  final BeamLoad? existing;
  final double    beamLength;

  const LoadDialog({super.key, this.existing, required this.beamLength});

  @override
  State<LoadDialog> createState() => _LoadDialogState();
}

class _LoadDialogState extends State<LoadDialog> {
  late LoadType _type;
  late final TextEditingController _posCtrl;
  late final TextEditingController _magCtrl;
  late final TextEditingController _endPosCtrl;
  late final TextEditingController _endMagCtrl;
  late final TextEditingController _lblCtrl;

  bool get _isDist =>
      _type == LoadType.distributedLoad ||
      _type == LoadType.triangularLoad;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type       = e?.type ?? LoadType.pointForce;
    _posCtrl    = TextEditingController(
        text: (e?.position ?? 3.0).toStringAsFixed(2));
    _magCtrl    = TextEditingController(
        text: (e?.magnitude ?? 50.0).toStringAsFixed(1));
    _endPosCtrl = TextEditingController(
        text: (e?.endPosition ?? widget.beamLength).toStringAsFixed(2));
    _endMagCtrl = TextEditingController(
        text: (e?.endMagnitude ?? 0.0).toStringAsFixed(1));
    _lblCtrl    = TextEditingController(text: e?.label ?? '');
  }

  @override
  void dispose() {
    _posCtrl.dispose(); _magCtrl.dispose();
    _endPosCtrl.dispose(); _endMagCtrl.dispose();
    _lblCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final magLabel = _type == LoadType.pointMoment
        ? 'Valeur' : _isDist ? 'Intensité début' : 'Intensité';
    final magSuffix = _type == LoadType.pointMoment
        ? 'kN·m' : _isDist ? 'kN/m' : 'kN';

    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Ajouter une charge' : 'Modifier la charge',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type de charge',
                  style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w600, color: BC.textS)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: LoadType.values
                    .map((t) => _LoadTypeChip(
                          type:     t,
                          selected: _type == t,
                          onTap:    () => setState(() => _type = t),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _NumField(
                    label: 'Position', ctrl: _posCtrl,
                    suffix: 'm', allowNeg: false)),
                const SizedBox(width: 8),
                Expanded(child: _NumField(
                    label: magLabel, ctrl: _magCtrl, suffix: magSuffix)),
              ]),
              if (_isDist) ...[
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _NumField(
                      label: 'Position fin', ctrl: _endPosCtrl,
                      suffix: 'm', allowNeg: false)),
                  if (_type == LoadType.triangularLoad) ...[
                    const SizedBox(width: 8),
                    Expanded(child: _NumField(
                        label: 'Intensité fin',
                        ctrl: _endMagCtrl, suffix: 'kN/m')),
                  ] else
                    const Expanded(child: SizedBox()),
                ]),
              ],
              const SizedBox(height: 10),
              _TextField(label: 'Étiquette (optionnel)', ctrl: _lblCtrl),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BC.warning.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '↓ positif = vers le bas  ·  Moment positif = horaire ↻',
                  style: TextStyle(fontSize: 11, color: BC.textS),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: BC.load),
          child: Text(widget.existing == null ? 'Ajouter' : 'Enregistrer'),
        ),
      ],
    );
  }

  void _submit() {
    double parse(TextEditingController c) =>
        double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

    Navigator.pop(context, BeamLoad(
      id:          widget.existing?.id ??
                   DateTime.now().millisecondsSinceEpoch.toString(),
      type:        _type,
      position:    parse(_posCtrl),
      magnitude:   parse(_magCtrl),
      endPosition: _isDist
          ? parse(_endPosCtrl).clamp(0, widget.beamLength).toDouble()
          : null,
      endMagnitude: _type == LoadType.triangularLoad
          ? parse(_endMagCtrl) : null,
      label: _lblCtrl.text.trim(),
    ));
  }
}

// ─── Chip type de charge ──────────────────────────────────────────
class _LoadTypeChip extends StatelessWidget {
  final LoadType     type;
  final bool         selected;
  final VoidCallback onTap;

  static const _labels = {
    LoadType.pointForce:      'Force P',
    LoadType.pointMoment:     'Moment M',
    LoadType.distributedLoad: 'Répartie q',
    LoadType.triangularLoad:  'Triangulaire',
  };

  const _LoadTypeChip({
    required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? BC.load.withValues(alpha: 0.09) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? BC.load : BC.border,
              width: selected ? 1.5 : 1),
        ),
        child: Text(_labels[type]!,
            style: TextStyle(
                fontSize: 12,
                color:      selected ? BC.load : BC.textS,
                fontWeight: selected
                    ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

// ─── Champ numérique — virgule + point + onTapOutside ────────────
class _NumField extends StatefulWidget {
  final String                label;
  final TextEditingController ctrl;
  final String?               suffix;
  final bool                  allowNeg;

  const _NumField({
    required this.label,
    required this.ctrl,
    this.suffix,
    this.allowNeg = true,
  });

  @override
  State<_NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<_NumField> {
  final _focus = FocusNode();

  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextField(
        controller:      widget.ctrl,
        focusNode:       _focus,
        keyboardType:    TextInputType.numberWithOptions(
            decimal: true, signed: widget.allowNeg),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              RegExp(widget.allowNeg ? r'[-\d.,]' : r'[\d.,]')),
          _CommaToPointFormatter(),
        ],
        decoration:   BC.fieldDeco(widget.label, suffix: widget.suffix),
        style:        const TextStyle(fontSize: 14),
        onTapOutside: (_) => _focus.unfocus(),
      ),
    );
  }
}

// ─── Champ texte simple ───────────────────────────────────────────
class _TextField extends StatefulWidget {
  final String                label;
  final TextEditingController ctrl;
  const _TextField({required this.label, required this.ctrl});

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  final _focus = FocusNode();
  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => TextField(
        controller:   widget.ctrl,
        focusNode:    _focus,
        decoration:   BC.fieldDeco(widget.label),
        style:        const TextStyle(fontSize: 14),
        onTapOutside: (_) => _focus.unfocus(),
      );
}

// ─── Formatter virgule → point ────────────────────────────────────
class _CommaToPointFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue nv) =>
      nv.copyWith(
          text: nv.text.replaceAll(',', '.'),
          selection: nv.selection);
}
