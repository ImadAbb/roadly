// ═══════════════════════════════════════════════════════════════
//  panels/geo_panel.dart
//  Panneau géométrie — withValues, onTapOutside, virgule acceptée
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/beam_colors.dart';

class GeoPanel extends StatelessWidget {
  final double   beamLength;
  final String   beamName;
  final ValueChanged<double> onLengthChanged;
  final ValueChanged<String> onNameChanged;
  final VoidCallback         onLengthSubmitted;
  final VoidCallback         onOpenTheory;

  const GeoPanel({
    super.key,
    required this.beamLength,
    required this.beamName,
    required this.onLengthChanged,
    required this.onNameChanged,
    required this.onLengthSubmitted,
    required this.onOpenTheory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Longueur de la poutre', style: BC.sectionLabel),
        const SizedBox(height: 6),
        _LengthField(
          initialValue:     beamLength,
          onChanged:        onLengthChanged,
          onSubmitted:      onLengthSubmitted,
        ),
        const SizedBox(height: 14),
        const Text('Nom du projet', style: BC.sectionLabel),
        const SizedBox(height: 6),
        _NameField(initialValue: beamName, onChanged: onNameChanged),
        const SizedBox(height: 16),
        _ConventionBox(),
        const SizedBox(height: 14),
        // Bouton page des théorèmes
        OutlinedButton.icon(
          onPressed: onOpenTheory,
          icon: const Icon(Icons.menu_book_outlined, size: 18),
          label: const Text('Voir les théorèmes utilisés'),
          style: OutlinedButton.styleFrom(
            foregroundColor: BC.primary,
            side: const BorderSide(color: BC.primary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

class _LengthField extends StatefulWidget {
  final double               initialValue;
  final ValueChanged<double> onChanged;
  final VoidCallback         onSubmitted;
  const _LengthField({
    required this.initialValue,
    required this.onChanged,
    required this.onSubmitted,
  });
  @override
  State<_LengthField> createState() => _LengthFieldState();
}

class _LengthFieldState extends State<_LengthField> {
  late final TextEditingController _ctrl;
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.initialValue.toStringAsFixed(2));
  }
  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => TextField(
        controller:      _ctrl,
        focusNode:       _focus,
        keyboardType:    const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          _CommaToPoint(),
        ],
        decoration:   BC.fieldDeco('Longueur', suffix: 'm'),
        style:        const TextStyle(fontSize: 14),
        onTapOutside: (_) => _focus.unfocus(),
        onChanged: (v) {
          final d = double.tryParse(v.replaceAll(',', '.'));
          if (d != null && d >= 0.5 && d <= 200) widget.onChanged(d);
        },
        onSubmitted: (_) => widget.onSubmitted(),
      );
}

class _NameField extends StatefulWidget {
  final String               initialValue;
  final ValueChanged<String> onChanged;
  const _NameField({required this.initialValue, required this.onChanged});
  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _ctrl;
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }
  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => TextField(
        controller:   _ctrl,
        focusNode:    _focus,
        decoration:   BC.fieldDeco('Nom'),
        onChanged:    widget.onChanged,
        onTapOutside: (_) => _focus.unfocus(),
      );
}

class _ConventionBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BC.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Convention de signes', style: BC.sectionLabel),
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
      );
}

class _CommaToPoint extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue o, TextEditingValue n) =>
      n.copyWith(text: n.text.replaceAll(',', '.'), selection: n.selection);
}
