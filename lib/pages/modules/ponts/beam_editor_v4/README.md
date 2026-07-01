# Éditeur de Poutre Flutter — README complet (v4)

## Sommaire
1. [Structure des fichiers](#1-structure-des-fichiers)
2. [Installation](#2-installation)
3. [Intégration dans votre app](#3-intégration-dans-votre-app)
4. [Description de chaque fichier](#4-description-de-chaque-fichier)
5. [Fonctionnalités utilisateur](#5-fonctionnalités-utilisateur)
6. [Types d'appuis](#6-types-dappuis)
7. [Types de charges](#7-types-de-charges)
8. [Comment fonctionne le calcul](#8-comment-fonctionne-le-calcul)
9. [Export PDF — étapes complètes](#9-export-pdf--étapes-complètes)
10. [Bugs corrigés en v4](#10-bugs-corrigés-en-v4)
11. [Unités et conventions](#11-unités-et-conventions)

---

## 1. Structure des fichiers

```
beam_editor_v4/
├── beam_editor_screen.dart        ← Point d'entrée (assemblage)
│
├── core/                          ← Logique pure, pas de UI
│   ├── beam_colors.dart           ← Toutes les couleurs + InputDecoration
│   ├── beam_models.dart           ← Modèles de données (BeamModel, etc.)
│   └── beam_solver.dart           ← Moteur de calcul V(x) et M(x)
│
├── canvas/                        ← Dessin de la poutre
│   ├── beam_canvas_painter.dart   ← CustomPainter (dessin pur)
│   ├── canvas_hit_test.dart       ← Détection tap/drag
│   └── canvas_widget.dart         ← GestureDetector + boutons overlay
│
├── diagram/                       ← Diagrammes V et M
│   ├── diagram_painter.dart       ← CustomPainter courbe + curseur
│   ├── diagram_widget.dart        ← Widget interactif (tap, drag, double tap)
│   └── diagram_fullscreen.dart    ← Page plein écran
│
├── dialogs/                       ← Un fichier par dialogue
│   ├── support_dialog.dart        ← Ajouter/modifier un appui
│   └── load_dialog.dart           ← Ajouter/modifier une charge
│
├── panels/                        ← Un fichier par panneau
│   ├── side_panel.dart            ← Conteneur des 3 onglets
│   ├── geo_panel.dart             ← Longueur, nom, bouton théorèmes
│   ├── supports_panel.dart        ← Liste des appuis
│   └── loads_panel.dart           ← Liste des charges
│
├── widgets/                       ← Widgets réutilisables
│   ├── support_tile.dart          ← Tuile d'un appui dans la liste
│   ├── load_tile.dart             ← Tuile d'une charge dans la liste
│   ├── result_chip.dart           ← Chip de valeur résultat
│   └── status_chip.dart           ← Chip erreur/info + confirmDelete()
│
├── results/
│   └── results_panel.dart         ← Réactions + valeurs clés + barre résumé
│
└── theory/
    └── theory_page.dart           ← Page des théorèmes (7 sections dépliables)
```

---

## 2. Installation

### pubspec.yaml — seule dépendance obligatoire

```yaml
dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.1.4    # Pour l'export JSON
```

### Dépendances optionnelles pour le PDF

```yaml
  pdf: ^3.10.8
  printing: ^5.12.0
```

Puis dans le terminal :

```bash
flutter pub get
```

---

## 3. Intégration dans votre app

### Copier les fichiers

Copiez le dossier `beam_editor_v4/` dans votre `lib/pages/modules/ponts/` (ou ailleurs).

### Ouvrir l'éditeur

```dart
import 'pages/modules/ponts/beam_editor_v4/beam_editor_screen.dart';

// Éditeur vide (poutre bi-appuyée par défaut)
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const BeamEditorScreen()),
);

// Avec un modèle personnalisé
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BeamEditorScreen(
      initialModel: BeamModel.cantilever(),
    ),
  ),
);
```

### Charger un fichier JSON sauvegardé

```dart
import 'dart:convert';
import 'dart:io';
import 'core/beam_models.dart';

Future<void> ouvrirFichier(String chemin) async {
  final json = jsonDecode(await File(chemin).readAsString());
  final beam = BeamModel.fromJson(json['model']);
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => BeamEditorScreen(initialModel: beam),
  ));
}
```

---

## 4. Description de chaque fichier

### `core/beam_colors.dart`
Centralise toutes les couleurs, l'extension `ColorX` (`.wo(alpha)`) qui remplace `.withOpacity()` deprecated, et `BC.fieldDeco()` qui génère l'InputDecoration commune à tous les champs.

### `core/beam_models.dart`
Contient :
- `SupportType` : simple, double_, hinge, fixed
- `LoadType` : pointForce, pointMoment, distributedLoad, triangularLoad
- `BeamSupport` : position, type, réactions calculées
- `BeamLoad` : position, magnitude, endPosition, visualCenter (pour hitbox)
- `DiagramPoint` : x, V, M
- `BeamResults` : points[], maxShear, maxMoment, interpolation
- `BeamModel` : modèle principal + validate() + 3 exemples prédéfinis

### `core/beam_solver.dart`
Moteur de calcul :
1. Compte les inconnues de réaction
2. Si h=0 → résolution directe par équilibre (ΣF=0, ΣM=0)
3. Si h>0 → méthode des 3 moments de Clapeyron
4. Construit les diagrammes V(x) et M(x) par intégration numérique (500 points)

### `canvas/beam_canvas_painter.dart`
CustomPainter qui dessine :
- Le sol (clampé à offsetX, ne dépasse pas à gauche)
- La poutre (rectangle bleu)
- Les appuis (chaque type a son dessin distinct)
- Les charges (flèches, courbes, réparties)
- Les réactions (flèches vertes)
- La cotation entre appuis
- Le guide de drag (ligne bleue verticale)
- La position live pendant le drag (charges ET appuis)

### `canvas/canvas_hit_test.dart`
Détecte l'élément sous le doigt. Pour les charges réparties, utilise `visualCenter` (milieu de la zone) au lieu de `position` seule, ce qui corrige la hitbox bizarre.

### `canvas/canvas_widget.dart`
Gère les gestes :
- `onTapDown` → sélection
- `onLongPressStart` → début drag
- `onLongPressMoveUpdate` → drag avec guard null
- `onLongPressEnd` → fin drag avec guard null (évite le crash)
Applique la safe zone iPhone (MediaQuery.padding).

### `diagram/diagram_painter.dart`
CustomPainter : courbe remplie, grille, marqueurs extrema, curseur orange interactif avec bulle de valeur.

### `diagram/diagram_widget.dart`
Gère :
- `onTapDown` → pose le curseur
- `onHorizontalDragUpdate` → déplace le curseur
- `onDoubleTap` → efface le curseur

### `diagram/diagram_fullscreen.dart`
Page plein écran avec toggle V/M, barre résumé, et bouton fermer unique.

### `dialogs/support_dialog.dart`
- Controller créé dans `initState` (focus stable)
- Accepte virgule ET point (formatter `_CommaToPointFormatter`)
- `onTapOutside` pour perdre le focus
- Grille 2×2 pour choisir le type d'appui

### `dialogs/load_dialog.dart`
Idem support_dialog mais pour les charges. Tous les controllers créés dans `initState`.

### `panels/geo_panel.dart`
- Champ longueur avec controller stable
- Champ nom avec controller stable
- Encadré convention de signes
- Bouton "Voir les théorèmes utilisés" → `TheoryPage`

### `panels/side_panel.dart`
Conteneur avec barre d'onglets custom (Appuis / Charges / Géométrie).

### `widgets/support_tile.dart` et `load_tile.dart`
Tuiles animées avec sélection visuelle, boutons éditer/supprimer.

### `widgets/status_chip.dart`
Contient aussi `confirmDelete()` (dialogue de confirmation suppression).

### `results/results_panel.dart`
Tableau des réactions par appui + valeurs V max/min, M max/min.
`ResultsSummaryBar` : barre compacte affichée en permanence sous le canvas.

### `theory/theory_page.dart`
7 sections dépliables (accordion) :
1. Équilibre statique
2. Effort tranchant V(x)
3. Moment fléchissant M(x)
4. Théorème des 3 moments (Clapeyron)
5. Types d'appuis
6. Types de charges
7. Précision du calcul numérique

### `beam_editor_screen.dart`
Assemblage final. Gère :
- Toutes les orientations (`SystemChrome.setPreferredOrientations`)
- Layout portrait vs landscape (`OrientationBuilder`)
- Plein écran canvas (bouton fermer **unique**, pas de doublon)
- Guard null sur le drag (`if (id == null) return;`)
- Navigation vers `TheoryPage` et `DiagramFullscreenPage`
- Export JSON

---

## 5. Fonctionnalités utilisateur

| Fonctionnalité | Comment faire |
|---|---|
| Ajouter un appui | Bouton "Appui" sur le canvas, ou bouton "Ajouter" dans l'onglet Appuis |
| Ajouter une charge | Bouton "Charge" sur le canvas, ou bouton "Ajouter" dans l'onglet Charges |
| Déplacer un élément | Appui long sur l'élément puis glisser |
| Sélectionner un élément | Tap simple sur l'élément |
| Modifier un élément | Bouton ✏️ dans la liste, ou tap puis éditer |
| Supprimer un élément | Bouton 🗑️ dans la liste |
| Voir les réactions | Bouton "Réactions" sur le canvas |
| Plein écran canvas | Bouton ⛶ sur le canvas |
| Plein écran diagramme | Bouton ⛶ dans la zone diagramme |
| Inspecter un point | Tap sur le diagramme → curseur orange avec valeur |
| Déplacer le curseur | Glisser horizontalement sur le diagramme |
| Effacer le curseur | Double tap sur le diagramme |
| Changer V / M | Boutons toggle dans la barre diagramme |
| Exemples prédéfinis | Menu 📚 dans l'AppBar |
| Renommer la poutre | Tap sur le nom dans l'AppBar |
| Exporter en JSON | Bouton ⬇ dans l'AppBar |
| Voir les théorèmes | Bouton dans l'onglet Géométrie |

---

## 6. Types d'appuis

| Type | Réactions | Dessin | Usage typique |
|---|---|---|---|
| **Appui simple** | RV | Triangle + roues (roulettes) | Extrémité libre de tourner et glisser |
| **Appui double** | RV + RH | Triangle + double ligne + barres | Rotule (bloque translation mais pas rotation) |
| **Rotule** | Articulation interne | Cercle avec croix | Charnière entre 2 tronçons |
| **Encastrement** | RV + RH + M | Rectangle hachuré | Mur, poteau encastré |

**Règle de stabilité :**
- 1 encastrement seul → structure stable (console)
- 2 appuis simples ou doubles → structure stable (bi-appuyée)
- 3 appuis ou plus → hyperstatique (Clapeyron)

---

## 7. Types de charges

| Type | Unité | Signe | Description |
|---|---|---|---|
| Force ponctuelle P | kN | + = vers le bas | Charge concentrée |
| Moment ponctuel M | kN·m | + = horaire | Moment concentré |
| Charge répartie q | kN/m | + = vers le bas | Intensité constante |
| Charge triangulaire | kN/m | + = vers le bas | Intensité variable |

---

## 8. Comment fonctionne le calcul

### Étape 1 — Comptage des inconnues
```
Appui simple  → 1 inconnue (RV)
Appui double  → 2 inconnues (RV + RH)
Encastrement  → 3 inconnues (RV + RH + M)
h = total_inconnues - 3
```

### Étape 2 — Résolution
- **h = 0** (isostatique) : ΣFy=0 et ΣM=0 → système 2×2
- **h > 0** (hyperstatique) : méthode des 3 moments de Clapeyron, algorithme de Thomas
- **h < 0** (instable) : message d'erreur

### Étape 3 — Diagrammes (500 points)
```
Pour chaque pas Δx = L/500 :
  V += charges_réparties * Δx
  + sauts aux points (réactions, charges ponctuelles)
  M += V * Δx
```

---

## 9. Export PDF — étapes complètes

Le code PDF est **déjà écrit mais commenté** dans `beam_editor_screen.dart`. Voici comment l'activer :

### Étape 1 — Ajouter les packages dans pubspec.yaml

```yaml
dependencies:
  pdf: ^3.10.8
  printing: ^5.12.0
```

```bash
flutter pub get
```

### Étape 2 — Créer un fichier pdf_export_service.dart

```dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'core/beam_models.dart';

class PdfExportService {
  static Future<void> exportPdf(BuildContext context, BeamModel beam) async {
    if (beam.results == null) return;
    final r = beam.results!;
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        // En-tête
        pw.Text('RAPPORT DE CALCUL — ${beam.name}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Divider(thickness: 2, color: PdfColors.blue800),
        pw.SizedBox(height: 12),

        // Géométrie
        _section('GÉOMÉTRIE', [
          _row('Longueur', '${beam.length.toStringAsFixed(2)} m'),
          _row('Nombre d\'appuis', '${beam.supports.length}'),
          _row('Nombre de charges', '${beam.loads.length}'),
        ]),
        pw.SizedBox(height: 12),

        // Réactions
        _section('RÉACTIONS D\'APPUI',
          beam.supports.map((s) =>
            _row(
              '${s.label} (x=${s.position.toStringAsFixed(2)} m)',
              'RV=${s.reactionV.toStringAsFixed(2)} kN'
              '${s.reactionM.abs() > 0.01 ? '  RM=${s.reactionM.toStringAsFixed(2)} kN·m' : ''}',
            )
          ).toList(),
        ),
        pw.SizedBox(height: 12),

        // Résultats
        _section('RÉSULTATS', [
          _row('V max', '${r.maxShear.toStringAsFixed(2)} kN'),
          _row('V min', '${r.minShear.toStringAsFixed(2)} kN'),
          _row('M max', '${r.maxMoment.toStringAsFixed(2)} kN·m'),
          _row('M min', '${r.minMoment.toStringAsFixed(2)} kN·m'),
          _row('Position M max', '${r.posMaxMoment.toStringAsFixed(2)} m'),
        ]),
        pw.SizedBox(height: 12),

        // Tableau des diagrammes (extrait)
        _section('DIAGRAMME (extrait 20 points)', [
          pw.Table.fromTextArray(
            headers: ['x (m)', 'V (kN)', 'M (kN·m)'],
            data: r.points
                .asMap()
                .entries
                .where((e) => e.key % (r.points.length ~/ 20) == 0)
                .map((e) => [
                      e.value.x.toStringAsFixed(2),
                      e.value.v.toStringAsFixed(2),
                      e.value.m.toStringAsFixed(2),
                    ])
                .toList(),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
            headerStyle: pw.TextStyle(color: PdfColors.white,
                fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            border: pw.TableBorder.all(color: PdfColors.grey400),
          ),
        ]),
      ],
    ));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${beam.name.replaceAll(' ', '_')}_rapport.pdf',
    );
  }

  static pw.Widget _section(String title, List<pw.Widget> children) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900)),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: children),
        ),
      ]);

  static pw.Widget _row(String label, String value) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(fontSize: 9,
                    color: PdfColors.grey700)),
            pw.Text(value,
                style: pw.TextStyle(fontSize: 9,
                    fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );
}
```

### Étape 3 — Appeler depuis l'AppBar

Dans `beam_editor_screen.dart`, ajouter dans les `actions` de l'AppBar :

```dart
import 'pdf_export_service.dart';

// Dans les actions AppBar :
IconButton(
  icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
  tooltip: 'Export PDF',
  onPressed: () => PdfExportService.exportPdf(context, _beam),
),
```

---

## 10. Bugs corrigés en v4

| Bug | Cause | Correction |
|---|---|---|
| Crash drag | `_draggingId` pouvait être null au moment de `_applyDrag` | Guard `if (id == null) return;` |
| Bouton fermer affiché 2 fois | Le widget canvas ET le `_buildCanvasFullscreen` affichaient chacun un bouton | `isFullscreen: false` toujours dans le widget, bouton géré uniquement dans `_buildCanvasFullscreen` |
| `withOpacity` deprecated | API Flutter dépréciée | Remplacé par `.withValues(alpha: x)` partout |
| Virgule rejetée | Formatter n'acceptait que `.` | `_CommaToPointFormatter` convertit `,` → `.` |
| Focus perdu entre frappes | Controllers recréés dans `build()` | Tous les controllers dans `initState()` |
| Hitbox charge répartie | Hitbox sur `position` (début) au lieu du centre | Utilise `visualCenter = (position + endPosition) / 2` |
| Sol qui déborde à gauche | Le sol commençait à x=0 | Commence à `offsetX` (aligné avec la poutre) |
| Position invisible en drag | Pas de label pendant le drag des charges | Label de position affiché pour tous les types en drag |
| `Ls`, `Vi`, `Rright` | Noms non camelCase | Renommés `spanLen`, `shearSpan`, `rRight` |
| Accolades manquantes | `if` sans `{}` dans beam_models | Accolades ajoutées |
| Import inutilisé | `result_chip` importé mais non utilisé | Import supprimé de l'écran principal |
| Poutre bi-appuyée incorrecte | Les deux appuis étaient `simple` | Appui A = simple, Appui B = double |
| Safe zone landscape | Boutons cachés par le notch iPhone | `SafeArea` sur le layout landscape, `MediaQuery.padding` dans canvas_widget |

---

## 11. Unités et conventions

| Grandeur | Unité |
|---|---|
| Longueur de la poutre | m |
| Position des appuis/charges | m depuis l'extrémité gauche |
| Force ponctuelle | kN |
| Moment ponctuel | kN·m |
| Charge répartie | kN/m |
| Effort tranchant V | kN |
| Moment fléchissant M | kN·m |

**Signe des forces :** positif = vers le bas ↓

**Signe des moments :** positif = sens horaire ↻

**Origine x = 0 :** extrémité gauche de la poutre
