import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  final String diagnosticFlash;
  final List<String> keywords;
  final List<String> symbolOrder;
  final String coachingPlan;

  PdfService({
    required this.diagnosticFlash,
    required this.keywords,
    required this.symbolOrder,
    required this.coachingPlan,
  });

  // Extrait la première semaine (Phase 1) du plan IA
  String _extractPhaseOne(String plan) {
    final match =
        RegExp(r'SEMAINE 1 : (.*?)SEMAINE 2 :', dotAll: true).firstMatch(plan);
    if (match != null) {
      return match.group(1)!.trim();
    }
    final parts = plan.split('SEMAINE 2 :');
    return parts.isNotEmpty
        ? parts.first.replaceFirst(RegExp(r'SEMAINE 1 :'), '').trim()
        : "Détail de la Phase 1 non disponible.";
  }

  // Génère et sauvegarde le PDF, puis ouvre le fichier
  Future<void> generateAndSharePdf() async {
    final pdf = pw.Document();

    // Chargement du logo
    final ByteData image = await rootBundle.load('assets/logo.png');
    final Uint8List imageBytes = image.buffer.asUint8List();
    final pw.MemoryImage logo = pw.MemoryImage(imageBytes);

    // Style de base (Noir/Or)
    const PdfColor primaryColor = PdfColor.fromInt(0xFF0A0A0A); // Noir
    const PdfColor accentColor = PdfColor.fromInt(0xFFFFC107); // Or/Ambre
    const PdfColor foregroundColor =
        PdfColor.fromInt(0xFFEBEBEB); // Blanc cassé

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),

          // CORRECTION FINALE APPLIQUÉE : Seul defaultTextStyle est utilisé pour la compatibilité
          theme: pw.ThemeData(
            defaultTextStyle:
                pw.TextStyle(color: foregroundColor, fontSize: 11),
          ),
        ),
        build: (pw.Context context) {
          // Utilisation du Container pour le fond Noir (remplace la 'decoration' dans PageTheme)
          return pw.Container(
              color: primaryColor,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // EN-TÊTE
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Image(logo, height: 50),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            // Le style est appliqué directement, car headerStyle n'est pas supporté
                            pw.Text('ANALYSE FLASH CIGA PROCESS',
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                    color: accentColor)),
                            pw.Text('Le Miroir Intérieur',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    color: foregroundColor.shade(0.7))),
                          ]),
                    ],
                  ),
                  pw.Divider(color: accentColor, thickness: 1),

                  // SECTION PROFIL UTILISATEUR
                  _buildSectionTitle(
                      title: 'Votre Géométrie Mentale', color: accentColor),
                  pw.SizedBox(height: 10),

                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: _buildInfoCard(
                          title: 'Mots-clés Saisis',
                          content: keywords.join(', '),
                          icon: pw.Icon(const pw.IconData(0xe90d),
                              color: accentColor),
                          bgColor: primaryColor.shade(0.3),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _buildInfoCard(
                          title: 'Ordre Symbolique (Priorité)',
                          content: symbolOrder
                              .asMap()
                              .entries
                              .map((e) => '${e.key + 1}. ${e.value}')
                              .join('\n'),
                          icon: pw.Icon(const pw.IconData(0xe84e),
                              color: accentColor),
                          bgColor: primaryColor.shade(0.3),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  // SECTION DIAGNOSTIC FLASH
                  _buildSectionTitle(
                      title: 'Diagnostic Flash (Synthèse IA)',
                      color: accentColor),
                  pw.SizedBox(height: 10),

                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: accentColor.shade(0.5)),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      diagnosticFlash,
                      textAlign: pw.TextAlign.justify,
                      style: pw.TextStyle(fontSize: 12, color: foregroundColor),
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // --- SECTION LEVIER D'AUTORITÉ (Ennéagramme) ---
                  _buildSectionTitle(
                      title: 'L\'Analyse CIGA et ses Fondements',
                      color: accentColor),
                  pw.SizedBox(height: 10),

                  pw.Text(
                    'L\'analyse CIGA Process repose sur le croisement unique entre les données conscientes (mots-clés) et l\'architecture inconsciente (symboles). Ce système s\'ancre dans les grandes cartographies psychologiques de la personnalité, à l\'instar de l\'Ennéagramme, qui révèle les dynamiques profondes de succès ou d\'échec. L\'outil agit comme un véritable GPS pour identifier précisément vos zones de fragilité et de croissance personnelle.',
                    textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(
                        fontSize: 10, color: foregroundColor.shade(0.9)),
                  ),

                  pw.SizedBox(height: 30),

                  // --- AVANT-GOÛT DU PROGRAMME (Phase 1 Synergie Évolutive) ---
                  _buildSectionTitle(
                      title: 'Phase 1 : Prise de Conscience (Avant-goût)',
                      color: accentColor),
                  pw.SizedBox(height: 10),

                  pw.Text(
                    _extractPhaseOne(coachingPlan),
                    textAlign: pw.TextAlign.justify,
                    style: pw.TextStyle(fontSize: 11, color: foregroundColor),
                  ),

                  pw.Spacer(),

                  // Pied de page
                  pw.Center(
                    child: pw.Text(
                      'Document Généré par le Coach Expert Synergie Évolutive - ${DateTime.now().year}',
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey500),
                    ),
                  )
                ],
              ));
        },
      ),
    );

    // Sauvegarde et ouverture du fichier
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path =
        '${directory.path}/CIGA_Process_Diagnostic_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(path);
  }

  // Widget d'aide pour le titre de section
  static pw.Widget _buildSectionTitle(
      {required String title, required PdfColor color}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: color, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(title,
          style: pw.TextStyle(
              fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
    );
  }

  // Widget d'aide pour les cartes d'information
  static pw.Widget _buildInfoCard(
      {required String title,
      required String content,
      required pw.Widget icon,
      required PdfColor bgColor}) {
    return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(children: [
                icon,
                pw.SizedBox(width: 5),
                pw.Text(title,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white)),
              ]),
              pw.SizedBox(height: 5),
              // Correction de lineSpacing
              pw.Text(content,
                  style: const pw.TextStyle(
                      fontSize: 10, lineSpacing: 1.5, color: PdfColors.white)),
            ]));
  }
}
