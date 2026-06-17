import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_model.dart';
import 'package:roadly/assets/widgets/result_card.dart';

class ResultPageCbr extends StatelessWidget {
  final CBRResults? results;

  const ResultPageCbr({super.key, this.results});

  @override
  Widget build(BuildContext context) {
    if (results == null) {
      return const Center(
        child: Text(
          'Aucun résultat calculé',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      );
    }

    final result = results!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résultats du calcul CBR',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle("Informations générales"),
          ResultCard(icon: Icons.alt_route, label: 'Type de voies', value: result.pavementType),
          ResultCard(icon: Icons.timeline, label: 'Répartition transversale du trafic', value: result.codeChaussee.toStringAsFixed(2)),
          ResultCard(icon: Icons.calendar_today, label: 'Année de fin de vie', value: result.anneeFinDeVie.toString()),

          const SizedBox(height: 20),

          _buildSectionTitle("Trafic"),
          ResultCard(icon: Icons.directions_car, label: 'TJMA mise en service', value: "${result.tjmaZero.toStringAsFixed(1)} V/J"),
          ResultCard(icon: Icons.directions_car_filled, label: 'TJMA fin de vie', value: "${result.tjmaFinDeVie.toStringAsFixed(1)} V/J"),
          ResultCard(icon: Icons.local_shipping, label: 'Trafic poids lourds', value: "${result.traficPoidsLourds.toStringAsFixed(1)} PL/J"),

          const SizedBox(height: 20),

          _buildSectionTitle("Dimensionnement"),
          ResultCard(icon: Icons.straighten, label: 'Épaisseur équivalente', value: "${result.eppTotalGnt.toStringAsFixed(2)} cm"),

          const SizedBox(height: 20),
          const Text(
            "👉 La répartition détaillée des couches sera ajoutée plus tard.",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}


