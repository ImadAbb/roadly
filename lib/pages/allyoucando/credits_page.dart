import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // ── AppBar avec dégradé bleu ───────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
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
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Crédits & Informations",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Contenu ───────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionLabel("APPLICATION"),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.apps,
                  color: Colors.blueAccent,
                  title: "Application",
                  value: "Roadly",
                ),
                const SizedBox(height: 20),

                _SectionLabel("DÉVELOPPEUR"),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.person,
                  color: Colors.blue,
                  title: "Développé par",
                  value: "Abbas Imad",
                ),
                const SizedBox(height: 20),

                _SectionLabel("BUT"),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.track_changes,
                  color: const Color.fromARGB(255, 33, 194, 243),
                  title: "Objectif",
                  value: "Projet personnel pour améliorer mes compétences en design",
                ),
                const SizedBox(height: 20),

                _SectionLabel("REMERCIEMENTS"),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.favorite,
                  color: Colors.red,
                  title: "Remerciements",
                  value: "Merci à l’USTHB et aux encadrants pour leur soutien.",
                ),
                const SizedBox(height: 20),

                _SectionLabel("TECHNOLOGIES"),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.build,
                  color: Colors.green,
                  title: "Technologies utilisées",
                  value: "Flutter · Dart · Material Design",
                ),
                const SizedBox(height: 20),

                _SectionLabel("LICENCE"),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.description,
                  color: Colors.orange,
                  title: "Licence",
                  value: "© 2026 ROADLY - Tous droits réservés",
                ),
                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    "Version beta 1.0.0",
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ───────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontFamily: 'monospace',
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }
}

// ── Info Card stylisée ───────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
