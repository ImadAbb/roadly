import 'package:flutter/material.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_vpro/models/beam_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/models/support_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/sheets/support_editor_sheet.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/tab_widgets/pro_card.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/tab_widgets/pro_tab_scaffold.dart';

class SupportsTab extends StatelessWidget {
  final Beam beam;
  final VoidCallback onBeamChanged;

  const SupportsTab({
    super.key,
    required this.beam,
    required this.onBeamChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProTabScaffold(
      title: "Appuis",

      // ─────────────────────────────
      // BOUTON AJOUTER
      // ─────────────────────────────
      action: IconButton(
        onPressed: () => _addSupport(context),
        tooltip: "Ajouter un appui",
        icon: const Icon(Icons.add_rounded, size: 21, color: Color(0xFF2563EB)),
      ),

      // ─────────────────────────────
      // CONTENU
      // ─────────────────────────────
      child: beam.supports.isEmpty
          ? const Center(
              child: Text(
                "Aucun appui",
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            )
          : ListView.separated(
              itemCount: beam.supports.length,

              separatorBuilder: (_, _) => const SizedBox(height: 6),

              itemBuilder: (context, index) {
                final support = beam.supports[index];

                return Dismissible(
                  key: ValueKey(support.id),

                  direction: DismissDirection.endToStart,

                  // ─────────────────────────────
                  // ARRIÈRE-PLAN SUPPRESSION
                  // ─────────────────────────────
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),

                  // ─────────────────────────────
                  // SUPPRESSION
                  // ─────────────────────────────
                  onDismissed: (_) {
                    final removedSupport = support;
                    final removedIndex = index;

                    beam.removeSupport(removedSupport);
                    onBeamChanged();

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,

                        backgroundColor: const Color(0xFF1E293B),
                        elevation: 0,

                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        content: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Color(0xFFCBD5E1),
                            ),

                            const SizedBox(width: 9),

                            Expanded(
                              child: Text(
                                'Appui "${removedSupport.id}" supprimé',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                beam.supports.insert(
                                  removedIndex.clamp(0, beam.supports.length),
                                  removedSupport,
                                );

                                onBeamChanged();
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF60A5FA),
                              ),
                              child: const Text(
                                "ANNULER",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },

                  // ─────────────────────────────
                  // CARTE
                  // ─────────────────────────────
                  child: GestureDetector(
                    onTap: () => _editSupport(context, support),
                    child: _SupportCard(support: support),
                  ),
                );
              },
            ),
    );
  }

  // ═══════════════════════════════════════
  // AJOUTER
  // ═══════════════════════════════════════

  Future<void> _addSupport(BuildContext context) async {
    final result = await showModalBottomSheet<Support>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SupportEditorSheet(beamLength: beam.beamLenght),
    );

    if (result == null) return;

    beam.addSupport(result);
    onBeamChanged();
  }

  // ═══════════════════════════════════════
  // MODIFIER
  // ═══════════════════════════════════════

  Future<void> _editSupport(BuildContext context, Support support) async {
    final result = await showModalBottomSheet<Support>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          SupportEditorSheet(support: support, beamLength: beam.beamLenght),
    );

    if (result == null) return;

    beam.updateSupport(support, result);

    onBeamChanged();
  }
}

// ═══════════════════════════════════════
// CARTE APPUI
// ═══════════════════════════════════════

class _SupportCard extends StatelessWidget {
  final Support support;

  const _SupportCard({required this.support});

  @override
  Widget build(BuildContext context) {
    return ProCard(
      child: Row(
        children: [
          // ─────────────────────────────
          // ICÔNE
          // ─────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEF7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              _supportIcon(support),
              size: 19,
              color: const Color(0xFF526174),
            ),
          ),

          const SizedBox(width: 10),

          // ─────────────────────────────
          // INFORMATIONS
          // ─────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supportLabel(support),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  "ID : ${support.id}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // ─────────────────────────────
          // POSITION
          // ─────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Position",
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),

              const SizedBox(height: 1),

              Text(
                "${support.position.toStringAsFixed(2)} m",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ICÔNE SELON LE TYPE
  // ═══════════════════════════════════════

  IconData _supportIcon(Support support) {
    switch (support.type) {
      case SupportType.simple_:
        return Icons.change_history_outlined;

      case SupportType.double_:
        return Icons.change_history_rounded;

      case SupportType.rotule_:
        return Icons.circle_outlined;

      case SupportType.encastrement_:
        return Icons.view_sidebar_rounded;
    }
  }
}
