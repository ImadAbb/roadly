import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_model.dart';
import 'package:roadly/assets/widgets/result_card.dart';

class ResultPageCbr extends StatelessWidget {
  final CBRResults? results;

  const ResultPageCbr({super.key, this.results});

  // Palette claire - accent bleu (cohérent avec ResultPageAsphalt)
  static const _bg = Color(0xFFF5F7FA);
  static const _surface = Colors.white;
  static const _blue = Color(0xFF3B82F6);
  static const _textPrimary = Color(0xFF1E293B);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    if (results == null) {
      return Container(
        color: _bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 48, color: _textSecondary),
              const SizedBox(height: 12),
              const Text(
                'Aucun résultat calculé',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final result = results!;

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(result),
            const SizedBox(height: 24),

            _buildSection(
              title: "Informations générales",
              icon: Icons.info_outline_rounded,
              children: [
                ResultCard(
                  icon: Icons.alt_route,
                  label: 'Type de chaussée',
                  value: result.pavementType,
                ),
                ResultCard(
                  icon: Icons.timeline,
                  label: 'Répartition transversale du trafic',
                  value: result.codeChaussee.toStringAsFixed(2),
                ),
                ResultCard(
                  icon: Icons.calendar_today,
                  label: 'Année de fin de vie',
                  value: result.anneeFinDeVie.toString(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: "Trafic",
              icon: Icons.local_shipping_rounded,
              children: [
                ResultCard(
                  icon: Icons.directions_car,
                  label: 'TJMA mise en service',
                  value: "${result.tjmaZero.toStringAsFixed(1)} V/J",
                ),
                ResultCard(
                  icon: Icons.directions_car_filled,
                  label: 'TJMA fin de vie',
                  value: "${result.tjmaFinDeVie.toStringAsFixed(1)} V/J",
                ),
                ResultCard(
                  icon: Icons.local_shipping,
                  label: 'Trafic poids lourds',
                  value: "${result.traficPoidsLourds.toStringAsFixed(1)} PL/J",
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: "Dimensionnement",
              icon: Icons.straighten_rounded,
              children: [
                ResultCard(
                  icon: Icons.straighten,
                  label: 'Épaisseur équivalente',
                  value: "${result.eppTotalGnt.toStringAsFixed(2)} cm",
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildComingSoonBanner(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CBRResults result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue, _blue.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.layers_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MÉTHODE CBR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Résultats du dimensionnement',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Épaisseur équivalente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${result.eppTotalGnt.toStringAsFixed(2)} cm",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _blue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _blue.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top_rounded, size: 18, color: _blue.withOpacity(0.8)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "La répartition détaillée des couches sera ajoutée plus tard.",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}