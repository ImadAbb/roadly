// ─────────────────────────────────────────────────────────────────
//  beam_export_service.dart
//  Export JSON et génération de rapport PDF
//  Dépendances : path_provider, share_plus (ou printing + pdf)
//  Importer : import 'services/beam_export_service.dart';
// ─────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/beam_models.dart';

class BeamExportService {
  // ══════════════════════════════════════════════════════════════
  //  EXPORT JSON
  // ══════════════════════════════════════════════════════════════

  /// Sérialise le modèle + résultats en JSON formaté
  static String toJsonString(BeamModel beam) {
    final Map<String, dynamic> data = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'model': beam.toJson(),
    };

    if (beam.results != null) {
      data['results'] = {
        ...beam.results!.toJson(),
        // Échantillon du diagramme (1 point tous les 10)
        'diagramSample': beam.results!.points
            .asMap()
            .entries
            .where((e) => e.key % 10 == 0)
            .map((e) => {
                  'x': _round(e.value.x),
                  'V': _round(e.value.v),
                  'M': _round(e.value.m),
                })
            .toList(),
      };
    }

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Sauvegarde le JSON dans un fichier temporaire et retourne le chemin
  static Future<String> saveJsonFile(BeamModel beam) async {
    final json = toJsonString(beam);
    final dir = await getTemporaryDirectory();
    final safeName = beam.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final file = File('${dir.path}/$safeName.json');
    await file.writeAsString(json, encoding: utf8);
    return file.path;
  }

  /// Charge un BeamModel depuis un fichier JSON
  static Future<BeamModel> loadJsonFile(String path) async {
    final file = File(path);
    final content = await file.readAsString(encoding: utf8);
    final data = jsonDecode(content) as Map<String, dynamic>;
    return BeamModel.fromJson(data['model'] as Map<String, dynamic>);
  }

  // ══════════════════════════════════════════════════════════════
  //  GÉNÉRATION RAPPORT PDF (via printing + pdf packages)
  // ══════════════════════════════════════════════════════════════
  //
  //  Pour activer : ajouter dans pubspec.yaml
  //    printing: ^5.12.0
  //    pdf: ^3.10.8
  //
  //  Puis décommenter les imports et méthodes ci-dessous.
  //  La version commentée fonctionne sans ces dépendances.

  // import 'package:pdf/pdf.dart';
  // import 'package:pdf/widgets.dart' as pw;
  // import 'package:printing/printing.dart';

  /// Génère et partage un rapport PDF complet
  /// Retourne true si succès, false si printing non disponible
  static Future<bool> exportPdf(BuildContext context, BeamModel beam) async {
    if (beam.results == null) return false;

    // ── Version sans package pdf : affiche une snackbar d'info ──
    // Remplacer ce bloc par le code PDF ci-dessous une fois les
    // packages ajoutés.
    _showPdfNotAvailable(context);
    return false;

    // ── Code PDF (décommenter après ajout des packages) ─────────
    /*
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildPdfHeader(beam),
          pw.SizedBox(height: 16),
          _buildPdfGeometry(beam),
          pw.SizedBox(height: 12),
          _buildPdfSection(beam),
          pw.SizedBox(height: 12),
          _buildPdfLoads(beam),
          pw.SizedBox(height: 12),
          _buildPdfReactions(beam),
          pw.SizedBox(height: 12),
          _buildPdfResults(beam),
          pw.SizedBox(height: 12),
          _buildPdfDiagramTable(beam),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${beam.name.replaceAll(' ', '_')}_rapport.pdf',
    );
    return true;
    */
  }

  static void _showPdfNotAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'PDF : ajoutez les packages "pdf" et "printing" dans pubspec.yaml '
          'puis décommentez le code dans beam_export_service.dart',
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  CONTENU DU RAPPORT PDF (blocs pw.Widget)
  // ══════════════════════════════════════════════════════════════

  /*
  static pw.Widget _buildPdfHeader(BeamModel beam) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('RAPPORT DE CALCUL DE POUTRE',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(DateTime.now().toString().substring(0, 16),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue800),
        pw.SizedBox(height: 4),
        pw.Text(beam.name,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900)),
      ],
    );
  }

  static pw.Widget _buildPdfGeometry(BeamModel beam) {
    return _pdfSection('GÉOMÉTRIE', [
      _pdfRow('Longueur totale', '${beam.length.toStringAsFixed(2)} m'),
      _pdfRow('Nombre d\'appuis', '${beam.supports.length}'),
      _pdfRow('Nombre de charges', '${beam.loads.length}'),
    ]);
  }

  static pw.Widget _buildPdfSection(BeamModel beam) {
    final s = beam.section;
    return _pdfSection('SECTION TRANSVERSALE', [
      _pdfRow('Type', s.type.name),
      _pdfRow('Matériau', s.material),
      _pdfRow('Module d\'Young E', '${s.eModulus.toStringAsFixed(0)} GPa'),
      _pdfRow('Aire A', '${s.areaCm2.toStringAsFixed(2)} cm²'),
      _pdfRow('Inertie I', '${s.icm4.toStringAsFixed(2)} cm⁴'),
      _pdfRow('Module W', '${s.wcm3.toStringAsFixed(2)} cm³'),
    ]);
  }

  static pw.Widget _buildPdfLoads(BeamModel beam) {
    final rows = beam.loads.map((l) => [
      l.label.isEmpty ? l.type.name : l.label,
      '${l.position.toStringAsFixed(2)} m',
      '${l.magnitude.toStringAsFixed(2)} ${l.isDistributed ? "kN/m" : "kN"}',
    ]).toList();

    return _pdfSection('CHARGES APPLIQUÉES', [
      pw.Table.fromTextArray(
        headers: ['Description', 'Position', 'Valeur'],
        data: rows,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
        rowDecoration: const pw.BoxDecoration(),
        border: pw.TableBorder.all(color: PdfColors.grey400),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerAlignment: pw.Alignment.center,
        cellAlignment: pw.Alignment.center,
      ),
    ]);
  }

  static pw.Widget _buildPdfReactions(BeamModel beam) {
    final rows = beam.supports.map((s) => [
      '${s.label} (x = ${s.position.toStringAsFixed(2)} m)',
      '${s.reactionV.toStringAsFixed(2)} kN',
      '${s.reactionH.toStringAsFixed(2)} kN',
      '${s.reactionM.toStringAsFixed(2)} kN·m',
    ]).toList();

    return _pdfSection('RÉACTIONS D\'APPUI', [
      pw.Table.fromTextArray(
        headers: ['Appui', 'RV (kN)', 'RH (kN)', 'RM (kN·m)'],
        data: rows,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
        border: pw.TableBorder.all(color: PdfColors.grey400),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerAlignment: pw.Alignment.center,
        cellAlignment: pw.Alignment.center,
      ),
    ]);
  }

  static pw.Widget _buildPdfResults(BeamModel beam) {
    final r = beam.results!;
    return _pdfSection('RÉSULTATS', [
      _pdfRow('Effort tranchant max', '${r.maxShear.toStringAsFixed(2)} kN à ${r.posMaxDeflection.toStringAsFixed(2)} m'),
      _pdfRow('Moment max', '${r.maxMoment.toStringAsFixed(2)} kN·m à ${r.posMaxMoment.toStringAsFixed(2)} m'),
      _pdfRow('Flèche max', '${r.maxDeflection.abs().toStringAsFixed(2)} mm à ${r.posMaxDeflection.toStringAsFixed(2)} m'),
      _pdfRow('Contrainte max σ', '${r.maxStress.toStringAsFixed(2)} MPa'),
      _pdfRow('Rotation max θ', '${(r.maxRotation * 1000).toStringAsFixed(3)} mrad'),
    ]);
  }

  static pw.Widget _buildPdfDiagramTable(BeamModel beam) {
    final r = beam.results!;
    final step = r.points.length ~/ 20;
    final rows = r.points
        .asMap()
        .entries
        .where((e) => e.key % step == 0)
        .map((e) => [
              e.value.x.toStringAsFixed(2),
              e.value.v.toStringAsFixed(2),
              e.value.m.toStringAsFixed(2),
              e.value.w.toStringAsFixed(2),
            ])
        .toList();

    return _pdfSection('DIAGRAMME (extrait)', [
      pw.Table.fromTextArray(
        headers: ['x (m)', 'V (kN)', 'M (kN·m)', 'w (mm)'],
        data: rows,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
        border: pw.TableBorder.all(color: PdfColors.grey400),
        cellStyle: const pw.TextStyle(fontSize: 8),
        headerAlignment: pw.Alignment.center,
        cellAlignment: pw.Alignment.center,
      ),
    ]);
  }

  static pw.Widget _pdfSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900)),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
  */

  // ══════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════

  static double _round(double v) => double.parse(v.toStringAsFixed(3));
}
