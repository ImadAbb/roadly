import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/route/cbr/cbr.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_model.dart';
import 'package:roadly/pages/modules/route/cbr/cbr_result.dart';

class ModuleRoute extends StatefulWidget {
  const ModuleRoute({super.key});

  @override
  State<ModuleRoute> createState() => _ModuleRouteState();
}

class _ModuleRouteState extends State<ModuleRoute> {
  String? selectedMethod;
  int selectedIndex = 0;
  CBRResults? results;

  final ScrollController scrollController = ScrollController();

  void _onValidated(CBRResults value) {
    setState(() {
      results = value;
      selectedIndex = 1;
    });

    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          /// HEADER
          SliverAppBar(
            backgroundColor: Color(0xFF42A5F5),
            elevation: 0,
            expandedHeight: 220,
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MODULE ROUTE",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Dimensionnement\nDes Chaussées",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Choisissez une méthode de calcul",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// CHOIX MÉTHODE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(child: _methodCard("CBR", Icons.bar_chart)),

                  const SizedBox(width: 12),

                  Expanded(child: _methodCard("AI", Icons.layers)),

                  const SizedBox(width: 12),

                  Expanded(child: _methodCard("CTTP", Icons.architecture)),
                ],
              ),
            ),
          ),

          if (selectedMethod == "CBR")
            SliverToBoxAdapter(
              child: selectedIndex == 0
                  ? CBR(onValidated: _onValidated)
                  : ResultPageCbr(results: results),
            ),
        ],
      ),

      bottomNavigationBar: selectedMethod == "CBR"
          ? BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (i) {
                setState(() {
                  selectedIndex = i;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit),
                  label: "Formulaire",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: "Résultats",
                ),
              ],
            )
          : null,
    );
  }

  Widget _methodCard(String method, IconData icon) {
    final selected = selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: selected ? Colors.blue.withValues(alpha: .1) : Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
          ),
        ),

        child: Column(
          children: [
            Icon(icon),

            const SizedBox(height: 8),

            Text(method, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
