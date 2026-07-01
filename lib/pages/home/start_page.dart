import 'package:flutter/material.dart';
import 'package:roadly/componets/modules.dart';
import 'package:roadly/componets/modules_tile.dart';
import 'package:roadly/pages/allyoucando/allyou/introduction.dart';
import 'package:roadly/pages/allyoucando/credits_page.dart';
import 'package:roadly/pages/home/tip_card.dart';
import 'package:roadly/pages/modules/hydraulique/hydraulique_page.dart';
import 'package:roadly/pages/modules/ponts/choose_beam_editor_v.dart';
import 'package:roadly/pages/modules/route/route_page.dart';
import 'package:roadly/pages/modules/structure/strmtc_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour 👋';
    if (h < 18) return 'Bon après-midi 👋';
    return 'Bonsoir 👋';
  }

  @override
  Widget build(BuildContext context) {
    final modulesList = [
      Modules(
        name: "Route",
        lastUpdate: "9 Juin",
        icon: Icons.roundabout_left,
        page: const ModuleRoute(),
        descreption: "Dimensionnement des chaussées par méthode CBR",
      ),
      Modules(
        name: "Hydraulique",
        lastUpdate: "7 Juin",
        icon: Icons.water_drop,
        page: ModuleHydraulique(),
        descreption: "Calculs d'écoulement et réseaux hydrauliques",
      ),
      Modules(
        name: "Structure Métallique",
        lastUpdate: "7 Juin",
        icon: Icons.iron,
        page: ModuleStructureMetallique(),
        descreption: "Analyse et dimensionnement des structures métalliques",
      ),
      Modules(
        name: "Ponts",
        lastUpdate: "12 Juin",
        icon: Icons.add_road,
        page: ChooseBeta(),
        descreption: "Étude et calcul des poutres et ponts",
      ),
    ];

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        overscroll: false, // 👈 enlève le stretch/rebond
        physics: const ClampingScrollPhysics(),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildQuickAccess(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MODULES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    Container(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.90,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => modulesList[i].page,
                        ),
                      );
                    },
                    child: ModulesTile(
                      modules: modulesList[i],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => modulesList[i].page,
                          ),
                        );
                      },
                    ),
                  ),
                  childCount: modulesList.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: TipCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'R',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'ROADLY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'v1.0 · Génie Civile',
                        style: TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreditsPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Quel calcul\naujourd\'hui ?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Barre de recherche ────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey, size: 18),
            SizedBox(width: 10),
            Text(
              'Rechercher une méthode...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Accès rapide ─────────────────────────────────────
  Widget _buildQuickAccess(BuildContext context) {
    final items = [
      (icon: Icons.bar_chart, label: 'CBR', color: Colors.orange),
      (icon: Icons.architecture, label: 'Poutres', color: Colors.green),
      (icon: Icons.calculate_outlined, label: 'Formules', color: Colors.blue),
      (icon: Icons.menu_book_outlined, label: 'Cours', color: Colors.purple),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACCÈS RAPIDE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Introduction(),
                    ),
                  );
                },
                child: const Text(
                  'Voir tout',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: items.map((q) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(q.icon, color: q.color, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          q.label,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
