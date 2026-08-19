import 'package:flutter/material.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_vpro/models/load_classes.dart';

class LoadEditorSheet extends StatefulWidget {
  final Load? load;
  final double beamLength;

  const LoadEditorSheet({
    super.key,
    this.load,
    required this.beamLength,
  });

  bool get isEditing => load != null;

  @override
  State<LoadEditorSheet> createState() => _LoadEditorSheetState();
}

class _LoadEditorSheetState extends State<LoadEditorSheet> {
  late final TextEditingController idController;
  late final TextEditingController positionController;
  late final TextEditingController positionEndController;
  late final TextEditingController valueController;

  late LoadType selectedType;

  @override
  void initState() {
    super.initState();

    final load = widget.load;

    idController = TextEditingController(
      text: load?.id ?? "",
    );

    positionController = TextEditingController(
      text: load?.position.toString() ?? "0",
    );

    positionEndController = TextEditingController(
      text: load is DistributedLoad
          ? load.positionEnd.toString()
          : "0",
    );

    valueController = TextEditingController(
      text: load?.value.toString() ?? "0",
    );

    selectedType = _getLoadType(load);
  }

  @override
  void dispose() {
    idController.dispose();
    positionController.dispose();
    positionEndController.dispose();
    valueController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final isDistributed =
        selectedType == LoadType.distributed;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: keyboardHeight,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════
              // TITRE
              // ═══════════════════════════════════════

              Text(
                widget.isEditing
                    ? "Modifier la charge"
                    : "Ajouter une charge",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.isEditing
                    ? "Modifiez les caractéristiques de la charge."
                    : "Définissez les caractéristiques de la nouvelle charge.",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // TYPE
              // ═══════════════════════════════════════

              const Text(
                "Type de charge",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 6),

              Column(
  children: [
    Row(
      children: [
        Expanded(
          child: _loadTypeButton(
            label: "Charge ponctuelle",
            icon: Icons.arrow_downward_rounded,
            type: LoadType.point,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _loadTypeButton(
            label: "Charge répartie",
            icon: Icons.vertical_align_bottom_rounded,
            type: LoadType.distributed,
          ),
        ),
      ],
    ),

    const SizedBox(height: 10),

    SizedBox(
      width: double.infinity,
      child: _loadTypeButton(
        label: "Moment",
        icon: Icons.refresh_rounded,
        type: LoadType.moment,
      ),
    ),
  ],
),

              const SizedBox(height: 12),

              // ═══════════════════════════════════════
              // POSITION
              // ═══════════════════════════════════════

              const Text(
                "Position",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: positionController,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  suffixText: "m",
                  hintText: "Position sur la poutre",
                ),
              ),

              // ═══════════════════════════════════════
              // POSITION FIN
              // ═══════════════════════════════════════

              if (isDistributed) ...[
                const SizedBox(height: 12),

                const Text(
                  "Position de fin",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: positionEndController,
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    suffixText: "m",
                    hintText: "Fin de la charge",
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // ═══════════════════════════════════════
              // VALEUR
              // ═══════════════════════════════════════

              const Text(
                "Valeur",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: valueController,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  suffixText: _valueUnit(),
                  hintText: "Valeur de la charge",
                ),
              ),

              const SizedBox(height: 12),

              // ═══════════════════════════════════════
              // IDENTIFIANT
              // ═══════════════════════════════════════

              const Text(
                "Identifiant",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: idController,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration(
                  hintText: "Optionnel — ex : charge_1",
                ),
                onSubmitted: (_) => _save(),
              ),

              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // BOUTONS
              // ═══════════════════════════════════════

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF475569),
                        side: const BorderSide(
                          color: Color(0xFFD7DFEC),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Annuler"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        widget.isEditing
                            ? "Enregistrer"
                            : "Ajouter",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // SAUVEGARDER
  // ═══════════════════════════════════════

  void _save() {
    final position = _parseDouble(
      positionController.text,
    );

    final value = _parseDouble(
      valueController.text,
    );

    // ─────────────────────────────────────
    // VALIDATION POSITION
    // ─────────────────────────────────────

    if (position == null) {
      return;
    }

    if (position < 0 ||
        position > widget.beamLength) {
      return;
    }

    // ─────────────────────────────────────
    // VALIDATION VALEUR
    // ─────────────────────────────────────

    if (value == null) {
      return;
    }

    // ─────────────────────────────────────
    // ID
    // ─────────────────────────────────────

    final id = idController.text.trim();

    Load newLoad;

    // ═══════════════════════════════════════
    // CHARGE PONCTUELLE
    // ═══════════════════════════════════════

    if (selectedType == LoadType.point) {
      newLoad = PointLoad(
        id,
        position,
        value,
      );
    }

    // ═══════════════════════════════════════
    // CHARGE RÉPARTIE
    // ═══════════════════════════════════════

    else if (selectedType == LoadType.distributed) {
      final positionEnd = _parseDouble(
        positionEndController.text,
      );

      if (positionEnd == null) {
        return;
      }

      if (positionEnd < 0 ||
          positionEnd > widget.beamLength) {
        return;
      }

      if (positionEnd <= position) {
        return;
      }

      newLoad = DistributedLoad(
        id,
        position,
        positionEnd,
        value,
      );
    }

    // ═══════════════════════════════════════
    // MOMENT
    // ═══════════════════════════════════════

    else {
      newLoad = MomentLoad(
        id,
        position,
        value,
      );
    }

    FocusScope.of(context).unfocus();

    Navigator.pop(context, newLoad);
  }

  // ═══════════════════════════════════════
  // TYPE INITIAL
  // ═══════════════════════════════════════

  LoadType _getLoadType(Load? load) {
    if (load is PointLoad) {
      return LoadType.point;
    }

    if (load is DistributedLoad) {
      return LoadType.distributed;
    }

    if (load is MomentLoad) {
      return LoadType.moment;
    }

    return LoadType.point;
  }

  // ═══════════════════════════════════════
  // UNITÉ
  // ═══════════════════════════════════════

  String _valueUnit() {
    switch (selectedType) {
      case LoadType.point:
        return "kN";

      case LoadType.distributed:
        return "kN/m";

      case LoadType.moment:
        return "kN·m";
    }
  }

  // ═══════════════════════════════════════
  // PARSE DOUBLE
  // ═══════════════════════════════════════

  double? _parseDouble(String text) {
    return double.tryParse(
      text.trim().replaceAll(',', '.'),
    );
  }

  // ═══════════════════════════════════════
  // STYLE DES CHAMPS
  // ═══════════════════════════════════════

  InputDecoration _inputDecoration({
    String? suffixText,
    String? hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE1E7F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE1E7F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
    );
  }
  Widget _loadTypeButton({
  required String label,
  required IconData icon,
  required LoadType type,
}) {
  final selected = selectedType == type;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedType = type;
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      height: 52,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFEFF6FF)
            : const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected
              ? const Color(0xFF2563EB)
              : const Color(0xFFE1E7F0),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFDCEBFF)
                  : const Color(0xFFE9EEF7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: selected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF526174),
            ),
          ),

          const SizedBox(width: 7),

          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

// ═══════════════════════════════════════
// TYPE DE CHARGE POUR LE SHEET
// ═══════════════════════════════════════

enum LoadType {
  point,
  distributed,
  moment,
}