import 'package:flutter/material.dart';

import '../../canvas/beam_diagram.dart';
import '../../canvas/force_diagrams/shear_diagram.dart';
import '../../domain/models/beam.dart';

enum DiagramType {
  beam,
  shear,
}

class DiagramView extends StatefulWidget {
  final Beam beam;

  const DiagramView({
    super.key,
    required this.beam,
  });

  @override
  State<DiagramView> createState() => _DiagramViewState();
}

class _DiagramViewState extends State<DiagramView> {
  DiagramType _selectedDiagram = DiagramType.beam;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ═══════════════════════════════════════
        // SÉLECTEUR DE DIAGRAMME
        // ═══════════════════════════════════════

        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FC),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD7DFEC),
                width: 1,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD7DFEC),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDiagramOption(
                    type: DiagramType.beam,
                    icon: Icons.straighten,
                    label: 'Poutre',
                  ),

                  _buildSeparator(),

                  _buildDiagramOption(
                    type: DiagramType.shear,
                    icon: Icons.show_chart,
                    label: 'Effort tranchant',
                  ),
                ],
              ),
            ),
          ),
        ),

        // ═══════════════════════════════════════
        // DIAGRAMME
        // ═══════════════════════════════════════

        Expanded(
          child: _buildDiagram(),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // OPTION DU SÉLECTEUR
  // ═══════════════════════════════════════

  Widget _buildDiagramOption({
    required DiagramType type,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedDiagram == type;

    return GestureDetector(
      onTap: () {
        if (_selectedDiagram == type) return;

        setState(() {
          _selectedDiagram = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,

        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(9),

          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ═══════════════════════════════
            // ICÔNE
            // ═══════════════════════════════

            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : const Color(0xFFDCE5F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF526174),
              ),
            ),

            const SizedBox(width: 7),

            // ═══════════════════════════════
            // TEXTE
            // ═══════════════════════════════

            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF526174),
                fontSize: 12,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // SÉPARATION ENTRE LES OPTIONS
  // ═══════════════════════════════════════

  Widget _buildSeparator() {
    return Container(
      width: 1,
      height: 26,
      color: const Color(0xFFD0D9E8),
    );
  }

  // ═══════════════════════════════════════
  // DIAGRAMME ACTUEL
  // ═══════════════════════════════════════

  Widget _buildDiagram() {
    switch (_selectedDiagram) {
      case DiagramType.beam:
        return BeamDiagram(
          beam: widget.beam,
        );

      case DiagramType.shear:
        return ShearDiagram(
          beam: widget.beam,
        );
    }
  }
}