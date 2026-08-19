import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/models/support_classes.dart';

class SupportEditorSheet extends StatefulWidget {
  final Support? support;
  final double beamLength;

  const SupportEditorSheet({super.key, this.support, required this.beamLength});

  bool get isEditing => support != null;

  @override
  State<SupportEditorSheet> createState() => _SupportEditorSheetState();
}

class _SupportEditorSheetState extends State<SupportEditorSheet> {
  late final TextEditingController idController;
  late final TextEditingController positionController;

  late SupportType selectedType;

  // ═══════════════════════════════════════
  // CÔTÉ DE L'ENCASTREMENT
  // ═══════════════════════════════════════

  late bool isEncastrementRightSide;

  @override
  void initState() {
    super.initState();

    final support = widget.support;

    idController = TextEditingController(text: support?.id ?? "");

    positionController = TextEditingController(
      text: support?.position.toString() ?? "0",
    );

    selectedType = support?.type ?? SupportType.simple_;

    // false = gauche
    // true = droite
    isEncastrementRightSide = support?.isEncastrementRightSide ?? false;

    // Si on modifie un ancien encastrement qui n'avait pas
    // encore cette information, on déduit le côté de sa position.
    if (support != null &&
        support.type == SupportType.encastrement_ &&
        support.isEncastrementRightSide == null) {
      isEncastrementRightSide = support.position >= widget.beamLength;
    }
  }

  @override
  void dispose() {
    idController.dispose();
    positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final isEncastrement = selectedType == SupportType.encastrement_;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════
              // TITRE
              // ═══════════════════════════════════════
              Text(
                widget.isEditing ? "Modifier l'appui" : "Ajouter un appui",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.isEditing
                    ? "Modifiez les caractéristiques de l'appui."
                    : "Définissez les caractéristiques du nouvel appui.",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // TYPE
              // ═══════════════════════════════════════
              const Text(
                "Type d'appui",
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
                        child: _supportTypeButton(
                          label: "Appui simple",
                          icon: Icons.horizontal_rule_rounded,
                          type: SupportType.simple_,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _supportTypeButton(
                          label: "Appui double",
                          icon: Icons.swap_horiz_rounded,
                          type: SupportType.double_,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _supportTypeButton(
                          label: "Rotule",
                          icon: Icons.circle_outlined,
                          type: SupportType.rotule_,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _supportTypeButton(
                          label: "Encastrement",
                          icon: Icons.vertical_align_bottom_rounded,
                          type: SupportType.encastrement_,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ═══════════════════════════════════════
              // CÔTÉ DE L'ENCASTREMENT
              // ═══════════════════════════════════════
              if (isEncastrement) ...[
                const SizedBox(height: 12),

                const Text(
                  "Côté de l'encastrement",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: _sideButton(
                        label: "Gauche",
                        icon: Icons.arrow_back_rounded,
                        selected: !isEncastrementRightSide,
                        onTap: () {
                          setState(() {
                            isEncastrementRightSide = false;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _sideButton(
                        label: "Droite",
                        icon: Icons.arrow_forward_rounded,
                        selected: isEncastrementRightSide,
                        onTap: () {
                          setState(() {
                            isEncastrementRightSide = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Information sur la position automatique
                Text(
                  isEncastrementRightSide
                      ? "Position automatique : ${widget.beamLength.toStringAsFixed(2)} m"
                      : "Position automatique : 0.00 m",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],

              // ═══════════════════════════════════════
              // POSITION
              // ═══════════════════════════════════════
              //
              // Pas de champ pour les encastrements :
              // gauche = 0
              // droite = beamLength
              //
              if (!isEncastrement) ...[
                const SizedBox(height: 12),

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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    suffixText: "m",
                    hintText: "Position sur la poutre",
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // ═══════════════════════════════════════
              // ID
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
                decoration: _inputDecoration(hintText: "(Optionnel)"),
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
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFD7DFEC)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Annuler"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(widget.isEditing ? "Enregistrer" : "Ajouter"),
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
    double position;

    // ═══════════════════════════════════════
    // ENCASTREMENT
    // ═══════════════════════════════════════

    if (selectedType == SupportType.encastrement_) {
      position = isEncastrementRightSide ? widget.beamLength : 0.0;
    }
    // ═══════════════════════════════════════
    // AUTRES APPUIS
    // ═══════════════════════════════════════
    else {
      final parsedPosition = double.tryParse(
        positionController.text.replaceAll(',', '.'),
      );

      if (parsedPosition == null) {
        return;
      }

      if (parsedPosition < 0 || parsedPosition > widget.beamLength) {
        return;
      }

      position = parsedPosition;
    }

    // ═══════════════════════════════════════
    // ID
    // ═══════════════════════════════════════

    final id = idController.text.trim();

    // ═══════════════════════════════════════
    // CRÉATION DE L'APPUI
    // ═══════════════════════════════════════

    final support = Support(
      id: id,
      position: position,
      type: selectedType,

      isEncastrementRightSide: selectedType == SupportType.encastrement_
          ? isEncastrementRightSide
          : null,
    );

    FocusScope.of(context).unfocus();

    Navigator.pop(context, support);
  }

  // ═══════════════════════════════════════
  // BOUTON GAUCHE / DROITE
  // ═══════════════════════════════════════

  Widget _sideButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE1E7F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
            ),

            const SizedBox(width: 7),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // STYLE DES CHAMPS
  // ═══════════════════════════════════════

  InputDecoration _inputDecoration({String? suffixText, String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,

      filled: true,
      fillColor: const Color(0xFFF7F9FC),

      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE1E7F0)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE1E7F0)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  Widget _supportTypeButton({
    required String label,
    required IconData icon,
    required SupportType type,
  }) {
    final selected = selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
    
          // Quand on sélectionne un encastrement,
          // gauche est sélectionné par défaut.
          if (type == SupportType.encastrement_) {
            isEncastrementRightSide = false;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
    
        height: 52,
    
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF7F9FC),
    
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
