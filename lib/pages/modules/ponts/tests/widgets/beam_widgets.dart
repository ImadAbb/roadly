// ═══════════════════════════════════════════════════════════════
//  beam_widgets.dart  —  Dialogues et widgets réutilisables
//  Importer : import '../widgets/beam_widgets.dart';
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/beam_models.dart';

// ─── Couleurs partagées ──────────────────────────────────────────
class BC {
  static const primary  = Color(0xFF1E3A8A);
  static const shear    = Color(0xFFDC2626);
  static const moment   = Color(0xFF0369A1);
  static const load     = Color(0xFFCC3A1A);
  static const support  = Color(0xFF1A5C38);
  static const warning  = Color(0xFFF59E0B);
  static const surface  = Color(0xFFF8FAFC);
  static const border   = Color(0xFFE2E8F0);
  static const textP    = Color(0xFF0F172A);
  static const textS    = Color(0xFF64748B);
  static const textM    = Color(0xFF94A3B8);
}

// ─── InputDecoration partagée ─────────────────────────────────────
InputDecoration _deco(String label, {String? suffix}) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(fontSize: 12, color: BC.textS),
  suffixText: suffix,
  suffixStyle: const TextStyle(fontSize: 12, color: BC.textS),
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: BC.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: BC.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: BC.primary, width: 1.5),
  ),
);

// ═══════════════════════════════════════════════════════════════════
//  DIALOGUE APPUI  (focus stable : TextEditingController externe)
// ═══════════════════════════════════════════════════════════════════

class SupportDialog extends StatefulWidget {
  final BeamSupport? existing;
  final double beamLength;

  const SupportDialog({super.key, this.existing, required this.beamLength});

  @override
  State<SupportDialog> createState() => _SupportDialogState();
}

class _SupportDialogState extends State<SupportDialog> {
  late SupportType _type;
  // Controller créé une seule fois → pas de perte de focus
  late final TextEditingController _posCtrl;

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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BC.textS)),
            const SizedBox(height: 8),
            // Grille 2×2 pour les 4 types
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: SupportType.values.map((t) => _typeBtn(t)).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Position',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BC.textS)),
            const SizedBox(height: 6),
            // ⚠ Controller fixe = pas de rebuild = pas de perte de focus
            TextField(
              controller: _posCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: _deco('Position', suffix: 'm'),
              style: const TextStyle(fontSize: 14),
              autofocus: widget.existing == null,
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
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: BC.primary),
          child: Text(widget.existing == null ? 'Ajouter' : 'Enregistrer'),
        ),
      ],
    );
  }

  Widget _typeBtn(SupportType t) {
    final labels = {
      SupportType.simple:  'Appui simple\n(RV)',
      SupportType.double_: 'Appui double\n(RV + RH)',
      SupportType.hinge:   'Rotule\n(articulation)',
      SupportType.fixed:   'Encastrement\n(RV + RH + M)',
    };
    final icons = {
      SupportType.simple:  Icons.change_history,
      SupportType.double_: Icons.vertical_align_bottom,
      SupportType.hinge:   Icons.circle_outlined,
      SupportType.fixed:   Icons.view_stream,
    };
    final sel = _type == t;
    return GestureDetector(
      onTap: () => setState(() => _type = t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: sel ? BC.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: sel ? BC.primary : BC.border,
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icons[t], size: 16,
                color: sel ? BC.primary : BC.textS),
            const SizedBox(width: 6),
            Expanded(
              child: Text(labels[t]!,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: sel ? BC.primary : BC.textS,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    height: 1.3,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final pos = double.tryParse(_posCtrl.text) ?? 0;
    if (pos < 0 || pos > widget.beamLength) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Position hors de la poutre (0–${widget.beamLength.toStringAsFixed(2)} m)'),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }
    Navigator.pop(
      context,
      BeamSupport(
        id: widget.existing?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        type: _type,
        position: pos,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DIALOGUE CHARGE  (focus stable)
// ═══════════════════════════════════════════════════════════════════

class LoadDialog extends StatefulWidget {
  final BeamLoad? existing;
  final double beamLength;

  const LoadDialog({super.key, this.existing, required this.beamLength});

  @override
  State<LoadDialog> createState() => _LoadDialogState();
}

class _LoadDialogState extends State<LoadDialog> {
  late LoadType _type;
  // Tous les controllers créés une seule fois dans initState
  late final TextEditingController _posCtrl;
  late final TextEditingController _magCtrl;
  late final TextEditingController _endPosCtrl;
  late final TextEditingController _endMagCtrl;
  late final TextEditingController _lblCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type       = e?.type ?? LoadType.pointForce;
    _posCtrl    = TextEditingController(text: (e?.position ?? 3.0).toStringAsFixed(2));
    _magCtrl    = TextEditingController(text: (e?.magnitude ?? 50.0).toStringAsFixed(1));
    _endPosCtrl = TextEditingController(
        text: (e?.endPosition ?? widget.beamLength).toStringAsFixed(2));
    _endMagCtrl = TextEditingController(
        text: (e?.endMagnitude ?? 0.0).toStringAsFixed(1));
    _lblCtrl    = TextEditingController(text: e?.label ?? '');
  }

  @override
  void dispose() {
    _posCtrl.dispose();
    _magCtrl.dispose();
    _endPosCtrl.dispose();
    _endMagCtrl.dispose();
    _lblCtrl.dispose();
    super.dispose();
  }

  bool get _isDist =>
      _type == LoadType.distributedLoad || _type == LoadType.triangularLoad;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Ajouter une charge' : 'Modifier la charge',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          // keyboardDismissBehavior pour éviter le scroll involontaire
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type
              const Text('Type de charge',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BC.textS)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: LoadType.values.map(_loadTypeChip).toList(),
              ),
              const SizedBox(height: 14),

              // Position + magnitude
              Row(children: [
                Expanded(child: _field('Position', _posCtrl, suffix: 'm',
                    allowNeg: false)),
                const SizedBox(width: 8),
                Expanded(child: _field(
                  _type == LoadType.pointMoment ? 'Valeur' : 'Intensité',
                  _magCtrl,
                  suffix: _type == LoadType.pointMoment
                      ? 'kN·m'
                      : _isDist ? 'kN/m' : 'kN',
                )),
              ]),

              // Champs charges réparties
              if (_isDist) ...[
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _field('Position fin', _endPosCtrl, suffix: 'm',
                      allowNeg: false)),
                  if (_type == LoadType.triangularLoad) ...[
                    const SizedBox(width: 8),
                    Expanded(child: _field('Intensité fin', _endMagCtrl, suffix: 'kN/m')),
                  ] else
                    const Expanded(child: SizedBox()),
                ]),
              ],

              const SizedBox(height: 10),
              _field('Étiquette (optionnel)', _lblCtrl, isNum: false),

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

  Widget _loadTypeChip(LoadType t) {
    final labels = {
      LoadType.pointForce:      'Force P',
      LoadType.pointMoment:     'Moment M',
      LoadType.distributedLoad: 'Répartie q',
      LoadType.triangularLoad:  'Triangulaire',
    };
    final sel = _type == t;
    return GestureDetector(
      onTap: () => setState(() => _type = t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? BC.load.withValues(alpha: 0.09) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: sel ? BC.load : BC.border, width: sel ? 1.5 : 1),
        ),
        child: Text(labels[t]!,
            style: TextStyle(
              fontSize: 12,
              color: sel ? BC.load : BC.textS,
              fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
            )),
      ),
    );
  }

  /// Champ numérique ou texte — controller externe fixe = pas de perte de focus
  Widget _field(String label, TextEditingController ctrl,
      {String? suffix, bool isNum = true, bool allowNeg = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextField(
        controller: ctrl,
        // Les controllers sont créés dans initState et ne changent jamais
        // → Flutter ne reconstruit pas le TextField = focus conservé
        keyboardType: isNum
            ? TextInputType.numberWithOptions(
                decimal: true, signed: allowNeg)
            : TextInputType.text,
        inputFormatters: isNum
            ? [FilteringTextInputFormatter.allow(
                RegExp(allowNeg ? r'[-\d.]' : r'[\d.]'))]
            : null,
        decoration: _deco(label, suffix: suffix),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _submit() {
    final pos    = double.tryParse(_posCtrl.text) ?? 0;
    final mag    = double.tryParse(_magCtrl.text) ?? 0;
    final endPos = double.tryParse(_endPosCtrl.text);
    final endMag = double.tryParse(_endMagCtrl.text);
    Navigator.pop(
      context,
      BeamLoad(
        id: widget.existing?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        type: _type,
        position: pos,
        magnitude: mag,
        endPosition: _isDist ? (endPos ?? widget.beamLength) : null,
        endMagnitude: _type == LoadType.triangularLoad ? (endMag ?? 0) : null,
        label: _lblCtrl.text.trim(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PANNEAU LATÉRAL — LISTE APPUIS / CHARGES (tuiles)
// ═══════════════════════════════════════════════════════════════════

class SupportTile extends StatelessWidget {
  final BeamSupport support;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SupportTile({
    super.key,
    required this.support,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? BC.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? BC.primary : BC.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(_icon(), color: BC.support, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(support.label,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: BC.textP)),
                  Text(
                    'x = ${support.position.toStringAsFixed(2)} m  ·  ${support.reactionDescription}',
                    style: const TextStyle(fontSize: 11, color: BC.textS,
                        fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            _iconBtn(Icons.edit_outlined, BC.textS, onEdit),
            _iconBtn(Icons.delete_outline, Colors.red.shade400, onDelete),
          ],
        ),
      ),
    );
  }

  IconData _icon() {
    switch (support.type) {
      case SupportType.simple:  return Icons.change_history;
      case SupportType.double_: return Icons.vertical_align_bottom;
      case SupportType.hinge:   return Icons.circle_outlined;
      case SupportType.fixed:   return Icons.view_stream;
    }
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback fn) =>
      InkWell(
        onTap: fn,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 17, color: color),
        ),
      );
}

class LoadTile extends StatelessWidget {
  final BeamLoad load;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LoadTile({
    super.key,
    required this.load,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icons = {
      LoadType.pointForce:      Icons.arrow_downward,
      LoadType.pointMoment:     Icons.rotate_right,
      LoadType.distributedLoad: Icons.density_medium,
      LoadType.triangularLoad:  Icons.change_history,
    };
    final unit = load.isDistributed
        ? 'kN/m'
        : (load.type == LoadType.pointMoment ? 'kN·m' : 'kN');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? BC.load.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? BC.load : BC.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icons[load.type]!, color: BC.load, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    load.label.isNotEmpty
                        ? load.label
                        : '${load.magnitude.abs().toStringAsFixed(1)} $unit',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: BC.textP),
                  ),
                  Text(
                    'x = ${load.position.toStringAsFixed(2)} m'
                    '${load.isDistributed ? ' → ${(load.endPosition ?? 0).toStringAsFixed(2)} m' : ''}',
                    style: const TextStyle(fontSize: 11, color: BC.textS,
                        fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            _iconBtn(Icons.edit_outlined, BC.textS, onEdit),
            _iconBtn(Icons.delete_outline, Colors.red.shade400, onDelete),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback fn) =>
      InkWell(
        onTap: fn,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 17, color: color),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  CHIP RÉSULTAT
// ═══════════════════════════════════════════════════════════════════

class ResultChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const ResultChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 14, color: color,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DIALOGUE CONFIRMATION SUPPRESSION
// ═══════════════════════════════════════════════════════════════════

Future<bool?> confirmDelete(BuildContext context, String what) =>
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Supprimer $what ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

// ═══════════════════════════════════════════════════════════════════
//  STATUS CHIP
// ═══════════════════════════════════════════════════════════════════

class StatusChip extends StatelessWidget {
  final String message;
  final bool isError;

  const StatusChip({super.key, required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final c = isError ? Colors.red.shade700 : BC.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isError ? Icons.error_outline : Icons.info_outline,
              size: 14, color: c),
          const SizedBox(width: 6),
          Flexible(
            child: Text(message,
                style: TextStyle(
                    fontSize: 12, color: c, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
