import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/classes.dart';

class ElementsPannel extends StatelessWidget {
  final Beam beam;

  const ElementsPannel({super.key, required this.beam});

  Color _colorForElement(dynamic e) {
    if (e is Support) return Colors.green;
    if (e is PointLoad) return Colors.red;
    if (e is DistributedLoad) return Colors.yellow;
    return Colors.grey;
  }

  String _labelForElement(dynamic e) {
    if (e is Support) return "Appui ${e.type.name}";
    if (e is PointLoad) return "Charge : ${e.value} kN";
    if (e is DistributedLoad) return "Répartie : ${e.value} kN/m";
    return "Élément inconnu";
  }

  String _positionForElement(dynamic e) {
    if (e is Support) return "x=${e.x} m";
    if (e is PointLoad) return "x=${e.x} m";
    if (e is DistributedLoad) return "${e.x} → ${e.xEnd} m";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final elements = [...beam.supports, ...beam.loads];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8), // 👈 padding réduit
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Éléments (${elements.length})",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14, // 👈 plus petit
            ),
          ),
          const SizedBox(height: 8),
          ...elements.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // rond coloré plus petit
                Container(
                  width: 12, // 👈 réduit
                  height: 12,
                  decoration: BoxDecoration(
                    color: _colorForElement(e),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                // texte type + valeur plus petit
                Expanded(
                  child: Text(
                    _labelForElement(e),
                    style: const TextStyle(fontSize: 12), // 👈 réduit
                  ),
                ),
                // position affichée à la fin plus petit
                Text(
                  _positionForElement(e),
                  style: const TextStyle(
                    fontSize: 11, // 👈 réduit
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

