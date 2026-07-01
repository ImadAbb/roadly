// ═══════════════════════════════════════════════════════════════
//  dialogs/support_dialog.dart
//  Dialogue appui — virgule acceptée, withValues, onTapOutside
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/beam_models.dart';
import '../core/beam_colors.dart';

class SupportDialog extends StatefulWidget {
  final BeamSupport? existing;
  final double       beamLength;

  const SupportDialog({super.key, this.existing, required this.beamLength});

  @override
  State<SupportDialog> createState() => _SupportDialogState();
}

class _SupportDialogState extends State<SupportDialog> {
  late SupportType _type;
  late final TextEditingController _posCtrl;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _type    = widget.existing?.type ?? SupportType.simple;
    _posCtrl = TextEditingController(
        text: (widget.existing?.position ?? 0.0).toStringAsFixed(2));
  }

  @override
  void dispose() {
    _posCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Ajouter un appui' : 'Modifier l\'appui',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type d\'appui',
                style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: BC.textS)),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.6,
              physics: const NeverScrollableScrollPhysics(),
              children: SupportType.values
                  .map((t) => _SupportTypeBtn(
                        type:     t,
                        selected: _type == t,
                        onTap:    () => setState(() => _type = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Position',
                style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: BC.textS)),
            const SizedBox(height: 6),
            // onTapOutside → perd le focus
            TextField(
              controller:   _posCtrl,
              focusNode:    _focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              // Accepte chiffres, point ET virgule
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                _CommaToPointFormatter(),
              ],
              decoration: BC.fieldDeco('Position', suffix: 'm'),
              style:      const TextStyle(fontSize: 14),
              autofocus:  widget.existing == null,
              onTapOutside: (_) => _focusNode.unfocus(),
            ),
            const SizedBox(height: 6),
            Text('0 à ${widget.beamLength.toStringAsFixed(2)} m',
                style: const TextStyle(fontSize: 11, color: BC.textM)),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: BC.primary),
          child: Text(widget.existing == null ? 'Ajouter' : 'Enregistrer'),
        ),
      ],
    );
  }

  void _submit() {
    final raw = _posCtrl.text.replaceAll(',', '.');
    final pos = double.tryParse(raw) ?? 0;
    if (pos < 0 || pos > widget.beamLength) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Position hors de la poutre (0–${widget.beamLength.toStringAsFixed(2)} m)'),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }
    Navigator.pop(context, BeamSupport(
      id:       widget.existing?.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
      type:     _type,
      position: pos,
    ));
  }
}

// ─── Bouton type d'appui ─────────────────────────────────────────
class _SupportTypeBtn extends StatelessWidget {
  final SupportType  type;
  final bool         selected;
  final VoidCallback onTap;

  static const _labels = {
    SupportType.simple:  'Appui simple\n(RV)',
    SupportType.double_: 'Appui double\n(RV + RH)',
    SupportType.hinge:   'Rotule\n(articulation)',
    SupportType.fixed:   'Encastrement\n(RV+RH+M)',
  };
  static const _icons = {
    SupportType.simple:  Icons.change_history,
    SupportType.double_: Icons.vertical_align_bottom,
    SupportType.hinge:   Icons.circle_outlined,
    SupportType.fixed:   Icons.view_stream,
  };

  const _SupportTypeBtn({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? BC.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? BC.primary : BC.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(_icons[type], size: 16,
              color: selected ? BC.primary : BC.textS),
          const SizedBox(width: 6),
          Expanded(
            child: Text(_labels[type]!,
                style: TextStyle(
                    fontSize: 10.5,
                    color:      selected ? BC.primary : BC.textS,
                    fontWeight: selected
                        ? FontWeight.w600 : FontWeight.normal,
                    height: 1.3)),
          ),
        ]),
      ),
    );
  }
}

// ─── Formatter : virgule → point ─────────────────────────────────
class _CommaToPointFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.replaceAll(',', '.'),
      selection: newValue.selection,
    );
  }
}
