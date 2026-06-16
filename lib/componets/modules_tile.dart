import 'package:flutter/material.dart';
import 'package:roadly/componets/modules.dart';

class ModulesTile extends StatelessWidget {
  final Modules modules;
  final void Function()? onTap;

  const ModulesTile({
    super.key,
    required this.modules,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Barre colorée en haut
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                color: Colors.blueAccent.withOpacity(0.8),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône + badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(modules.icon, size: 40, color: Colors.grey[800]),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.12),
                          border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          "MàJ: ${modules.lastUpdate}",
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Nom du module
                  Text(
                    modules.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Description courte si disponible
                  if (modules.descreption != null)
                    Text(
                      modules.descreption!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ),

            // Flèche en bas à droite
            Positioned(
              right: 12,
              bottom: 12,
              child: Text(
                '→',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
