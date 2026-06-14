import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/editeur_de_poutre/structure/classes.dart';
import 'package:roadly/pages/modules/ponts/right_pannel/elements.dart';
import 'package:roadly/pages/modules/ponts/right_pannel/propreties.dart';
import 'package:roadly/pages/modules/ponts/right_pannel/results.dart';

class MainRightPannel extends StatefulWidget {
  final Beam beam;

  const MainRightPannel({super.key, required this.beam});

  @override
  State<MainRightPannel> createState() => _MainRightPannelState();
}

class _MainRightPannelState extends State<MainRightPannel> {
  late PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    setState(() {
      _currentPage = index;
    });
    _controller.jumpToPage(index);
  }

  Widget _buildTab(String label, int index) {
    final bool isSelected = _currentPage == index;
    return Expanded(
      child: InkWell(
        onTap: () => _goToPage(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ligne d’onglets
        Row(
          children: [
            _buildTab("Éléments", 0),
            _buildTab("Propriétés", 1),
            _buildTab("Résultats", 2),
          ],
        ),

        // PageView contrôlé par les onglets
        Expanded(
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            children: [
              ElementsPannel(beam: widget.beam),
              const Propreties(),
              const Resultats(),
            ],
          ),
        ),
      ],
    );
  }
}
