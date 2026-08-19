import 'package:flutter/material.dart';

import 'package:roadly/pages/modules/ponts/beam_editor_vpro/models/beam_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/models/load_classes.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/sheets/load_editor_sheet.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/tab_widgets/pro_card.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_vpro/widgets/tab_widgets/pro_tab_scaffold.dart';

class LoadsTab extends StatelessWidget {
  final Beam beam;
  final VoidCallback onBeamChanged;

  const LoadsTab({
    super.key,
    required this.beam,
    required this.onBeamChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProTabScaffold(
      title: "Charges",

      // ═══════════════════════════════════════
      // BOUTON AJOUTER
      // ═══════════════════════════════════════

      action: IconButton(
        onPressed: () async {
          final result = await showModalBottomSheet<Load>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            builder: (_) => LoadEditorSheet(
              beamLength: beam.beamLenght,
            ),
          );

          if (result != null) {
            beam.addLoad(result);
            onBeamChanged();
          }
        },
        tooltip: "Ajouter une charge",
        icon: const Icon(
          Icons.add_rounded,
          size: 21,
          color: Color(0xFF2563EB),
        ),
      ),

      // ═══════════════════════════════════════
      // CONTENU
      // ═══════════════════════════════════════

      child: beam.loads.isEmpty
          ? const Center(
              child: Text(
                "Aucune charge",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            )
          : ListView.separated(
              itemCount: beam.loads.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final load = beam.loads[index];

                return _LoadCard(
                  load: load,

                  // ─────────────────────────
                  // MODIFIER
                  // ─────────────────────────

                  onEdit: () async {
                    final result = await showModalBottomSheet<Load>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => LoadEditorSheet(
                        load: load,
                        beamLength: beam.beamLenght,
                      ),
                    );

                    if (result != null) {
                      beam.updateLoad(load, result);
                      onBeamChanged();
                    }
                  },

                  // ─────────────────────────
                  // SUPPRIMER
                  // ─────────────────────────

                  onDelete: () {
                    _deleteLoad(context, load);
                  },
                );
              },
            ),
    );
  }

  // ═══════════════════════════════════════
  // SUPPRIMER UNE CHARGE
  // ═══════════════════════════════════════

  void _deleteLoad(BuildContext context, Load load) {
    final loadIndex = beam.loads.indexOf(load);

    if (loadIndex == -1) {
      return;
    }

    beam.removeLoad(load);

    onBeamChanged();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFF8FAFC),
              size: 19,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                "${_loadType(load)} supprimée",
                style: const TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                if (loadIndex >= 0 &&
                    loadIndex <= beam.loads.length) {
                  beam.loads.insert(loadIndex, load);
                  onBeamChanged();
                }

                ScaffoldMessenger.of(context)
                    .hideCurrentSnackBar();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF93C5FD),
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TYPE DE CHARGE
  // ═══════════════════════════════════════

  String _loadType(Load load) {
    if (load is PointLoad) {
      return "Charge ponctuelle";
    }

    if (load is DistributedLoad) {
      return "Charge répartie";
    }

    if (load is MomentLoad) {
      return "Moment";
    }

    return "Charge";
  }
}

// ═══════════════════════════════════════
// CARTE CHARGE
// ═══════════════════════════════════════

class _LoadCard extends StatelessWidget {
  final Load load;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LoadCard({
    required this.load,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(load.id),

      // Swipe uniquement vers la gauche
      direction: DismissDirection.endToStart,

      // ═══════════════════════════════════════
      // FOND DU SWIPE
      // ═══════════════════════════════════════

      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 21,
        ),
      ),

      // ═══════════════════════════════════════
      // SUPPRESSION
      // ═══════════════════════════════════════

      confirmDismiss: (direction) async {
        onDelete();

        // On gère nous-mêmes la suppression.
        return false;
      },

      // ═══════════════════════════════════════
      // CARTE CLIQUABLE
      // ═══════════════════════════════════════

      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: ProCard(
          child: Row(
            children: [
              // ═════════════════════════════════
              // ICÔNE
              // ═════════════════════════════════

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EEF7),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  _loadIcon(load),
                  size: 19,
                  color: const Color(0xFF526174),
                ),
              ),

              const SizedBox(width: 10),

              // ═════════════════════════════════
              // INFORMATIONS
              // ═════════════════════════════════

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _loadType(load),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      "ID : ${load.id}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    // ─────────────────────────
                    // CHARGE PONCTUELLE
                    // ─────────────────────────

                    if (load is PointLoad) ...[
                      const SizedBox(height: 2),

                      Text(
                        "Force : "
                        "${(load as PointLoad).value.toStringAsFixed(2)} "
                        "kN",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    // ─────────────────────────
                    // CHARGE RÉPARTIE
                    // ─────────────────────────

                    if (load is DistributedLoad) ...[
                      const SizedBox(height: 2),

                      Text(
                        "Force : "
                        "${(load as DistributedLoad).value.toStringAsFixed(2)} "
                        "kN/m",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    // ─────────────────────────
                    // MOMENT
                    // ─────────────────────────

                    if (load is MomentLoad) ...[
                      const SizedBox(height: 2),

                      Text(
                        "Moment : "
                        "${(load as MomentLoad).value.toStringAsFixed(2)} "
                        "kN·m",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ═════════════════════════════════
              // POSITION
              // ═════════════════════════════════

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ─────────────────────────
                  // CHARGE RÉPARTIE
                  // ─────────────────────────

                  if (load is DistributedLoad) ...[
                    const Text(
                      "Début",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),

                    const SizedBox(height: 1),

                    Text(
                      "${(load as DistributedLoad).position.toStringAsFixed(2)} m",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Fin",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),

                    const SizedBox(height: 1),

                    Text(
                      "${(load as DistributedLoad).positionEnd.toStringAsFixed(2)} m",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ]

                  // ─────────────────────────
                  // AUTRES CHARGES
                  // ─────────────────────────

                  else ...[
                    const Text(
                      "Position",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),

                    const SizedBox(height: 1),

                    Text(
                      "${load.position.toStringAsFixed(2)} m",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TYPE
  // ═══════════════════════════════════════

  String _loadType(Load load) {
    if (load is PointLoad) {
      return "Charge ponctuelle";
    }

    if (load is DistributedLoad) {
      return "Charge répartie";
    }

    if (load is MomentLoad) {
      return "Moment";
    }

    return "Charge";
  }

  // ═══════════════════════════════════════
  // ICÔNE
  // ═══════════════════════════════════════

  IconData _loadIcon(Load load) {
    if (load is PointLoad) {
      return Icons.arrow_downward_rounded;
    }

    if (load is DistributedLoad) {
      return Icons.vertical_align_bottom_rounded;
    }

    if (load is MomentLoad) {
      return Icons.refresh_rounded;
    }

    return Icons.download_rounded;
  }
}