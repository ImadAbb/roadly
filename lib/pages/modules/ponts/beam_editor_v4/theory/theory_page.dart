// ═══════════════════════════════════════════════════════════════
//  theory/theory_page.dart
//  Page des théorèmes et méthodes utilisés dans le module
//  Accès : Navigator.push depuis le bouton dans GeoPanel
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/beam_colors.dart';

class TheoryPage extends StatelessWidget {
  const TheoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BC.surface,
      appBar: AppBar(
        title: const Text(
          'Théorèmes & méthodes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: BC.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TheorySection(
            icon: Icons.balance,
            color: BC.primary,
            title: '1. Équilibre statique (Isostatique)',
            content: '''
Une poutre est isostatique quand le nombre d'inconnues de réaction est égal à 3 (les 3 équations d'équilibre).

Les 3 équations utilisées :
  • ΣFx = 0  →  somme des forces horizontales nulle
  • ΣFy = 0  →  somme des forces verticales nulle
  • ΣM = 0   →  somme des moments nulle (en un point)

Exemple — Poutre bi-appuyée (appui simple + appui double) :
  • Appui double en A : RVA et RHA (2 inconnues)
  • Appui simple en B : RVB (1 inconnue)
  • Total : 3 inconnues = 3 équations → système résolu directement.

Formules :
  ΣM_A = 0  →  RVB = (ΣF·xi) / L
  ΣFy = 0   →  RVA = ΣF - RVB
''',
          ),
          _TheorySection(
            icon: Icons.functions,
            color: BC.shear,
            title: '2. Effort tranchant V(x)',
            content: '''
L'effort tranchant V(x) en une section x est la somme algébrique de toutes les forces extérieures agissant à gauche de la section.

Convention de signe (utilisée dans ce module) :
  • Force vers le bas à gauche de x  →  V positif
  • Force vers le haut à gauche de x →  V négatif

Relation avec les charges :
  dV/dx = -q(x)
  où q(x) est l'intensité de la charge répartie.

Discontinuités :
  • Force ponctuelle P en x₀ : saut de V = +P (vers le bas)
  • Réaction R en x₀ : saut de V = -R

Calcul numérique (méthode des pas) :
  Pour chaque pas Δx, on ajoute la contribution des charges réparties :
  V(x + Δx) = V(x) + q(x)·Δx
''',
          ),
          _TheorySection(
            icon: Icons.rotate_right,
            color: BC.moment,
            title: '3. Moment fléchissant M(x)',
            content: '''
Le moment fléchissant M(x) en une section x est la somme des moments de toutes les forces extérieures à gauche de x, calculés par rapport à x.

Relation fondamentale :
  dM/dx = V(x)
  d²M/dx² = -q(x)

Conséquences pratiques :
  • Là où V = 0 → M est extremum (maximum ou minimum)
  • Sous une charge ponctuelle → rupture de pente de M
  • Sous une charge répartie → M est une courbe parabolique

Conditions aux limites :
  • Appui simple ou double : M = 0
  • Encastrement : M = valeur calculée (≠ 0 en général)
  • Extrémité libre : M = 0

Calcul numérique (intégration de V) :
  M(x + Δx) = M(x) + V(x)·Δx
''',
          ),
          _TheorySection(
            icon: Icons.timeline,
            color: Color(0xFF7B3FA0),
            title: '4. Théorème des 3 moments (Clapeyron)',
            content: '''
Utilisé pour les poutres CONTINUES (hyperstatiques) avec plus de 2 appuis.

Pour chaque appui intermédiaire i, l'équation de Clapeyron relie les moments aux appuis i-1, i et i+1 :

  M(i-1)·L(i-1) + 2·M(i)·[L(i-1) + L(i)] + M(i+1)·L(i)
    = -6·[B_right(i-1)/L(i-1) + B_left(i)/L(i)]

Où :
  • L(i) = longueur de la travée i
  • B_right, B_left = termes dépendant des charges appliquées

Pour une charge uniformément répartie q sur toute une travée :
  B_left = B_right = q·L³/4

Le système tridiagonal est résolu par l'algorithme de Thomas (LU), efficace en O(n).

Une fois les moments aux appuis connus, les réactions verticales sont calculées par équilibre de chaque travée :
  RVright = (ΣM_charges + M(i) - M(i+1)) / L
  RVleft  = ΣF_travée - RVright
''',
          ),
          _TheorySection(
            icon: Icons.architecture,
            color: BC.support,
            title: '5. Types d\'appuis',
            content: '''
Appui simple (rouleau)
  • Bloque uniquement la translation verticale
  • Réaction : RV
  • Dessin : triangle + roues (peut tourner et glisser horizontalement)

Appui double (rotule)
  • Bloque les translations verticale ET horizontale
  • Réactions : RV + RH
  • Dessin : triangle + double trait

Rotule interne (charnière)
  • Articulation entre deux tronçons de poutre
  • Permet la rotation relative → M = 0 en ce point
  • Pas de réaction externe, mais condition M = 0

Encastrement
  • Bloque toutes les déformations (translation + rotation)
  • Réactions : RV + RH + Moment d'encastrement M
  • Dessin : rectangle hachuré

Degré d'hyperstaticité :
  h = (nombre d'inconnues) - 3
  h = 0 → isostatique (résolution directe)
  h > 0 → hyperstatique (Clapeyron ou autres méthodes)
  h < 0 → mécanisme (instable)
''',
          ),
          _TheorySection(
            icon: Icons.density_medium,
            color: BC.load,
            title: '6. Types de charges',
            content: '''
Force ponctuelle P [kN]
  • Appliquée en un point précis
  • Crée une discontinuité dans V(x)
  • Crée un coude dans M(x)

Moment ponctuel M [kN·m]
  • Moment concentré en un point
  • Crée une discontinuité dans M(x)
  • Pas d'effet sur V(x)

Charge répartie uniforme q [kN/m]
  • Intensité constante sur un segment
  • V(x) varie linéairement sous la charge
  • M(x) est une parabole du 2ème degré
  • Résultante : F = q·L, appliquée au milieu

Charge répartie triangulaire q(x) [kN/m]
  • Intensité variable de q₁ à q₂
  • V(x) varie paraboliquement
  • Résultante : F = (q₁+q₂)/2 · L
  • Point d'application : centroïde du trapèze
    x_centroïde = L·(q₁ + 2·q₂) / [3·(q₁+q₂)]
''',
          ),
          _TheorySection(
            icon: Icons.info_outline,
            color: BC.textS,
            title: '7. Précision du calcul numérique',
            content: '''
Le calcul des diagrammes est effectué par intégration numérique pas à pas avec 500 points régulièrement espacés.

Méthode des rectangles à gauche :
  V(xᵢ₊₁) = V(xᵢ) + q(xᵢ)·Δx
  M(xᵢ₊₁) = M(xᵢ) + V(xᵢ)·Δx

Limitations :
  • Pas de calcul de flèche (nécessiterait EI)
  • Précision de l'ordre de Δx = L/500
  • Les discontinuités (charges ponctuelles) sont gérées
    par détection de proximité (fenêtre de Δx/2)

Pour les poutres continues, la méthode de Clapeyron
est exacte pour les charges uniformes, et approchée
(< 3 % d'erreur) pour les charges ponctuelles.
''',
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Section de théorème ─────────────────────────────────────────
class _TheorySection extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String content;

  const _TheorySection({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
  });

  @override
  State<_TheorySection> createState() => _TheorySectionState();
}

class _TheorySectionState extends State<_TheorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BC.border),
      ),
      child: Column(
        children: [
          // ── En-tête cliquable ──────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.color,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: BC.textM,
                  ),
                ],
              ),
            ),
          ),
          // ── Contenu dépliable ──────────────────────────────
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BC.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.content.trim(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: BC.textP,
                    height: 1.7,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
