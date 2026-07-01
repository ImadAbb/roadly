import 'package:flutter/material.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_v1/ponts_main.dart';
import 'package:roadly/pages/modules/ponts/beam_editor_v4/beam_editor_screen.dart';

class ChooseBeta extends StatelessWidget {
  const ChooseBeta({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Version du module",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.orange.shade200,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Les deux versions sont actuellement en bêta.\n\n"
                      "• La version Standard est plus stable et recommandée pour une utilisation normal.\n\n"
                      "• La version Claude propose davantage de fonctionnalités mais peut encore contenir quelques erreurs.",
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            _VersionCard(
              icon: Icons.verified_outlined,
              title: "Version Standard",
              subtitle: "Plus stable • Recommandée",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ModulePonts(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            _VersionCard(
              icon: Icons.auto_awesome,
              title: "Version Claude",
              subtitle: "Plus avancée • En développement",
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BeamEditorScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _VersionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: color.withValues(alpha: .25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 34,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}