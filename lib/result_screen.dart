import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'pdf_service.dart';
import 'package:email_validator/email_validator.dart';
import 'recalibration_plan_screen.dart';

// Clé API OpenAI intégrée (Injectée par CI/CD)
const String openApiKey = 'VOTRE_CLE_SERA_INJECTEE_PAR_CODEMAGIC';
const String openaiUrl = 'https://api.openai.com/v1/chat/completions';

// URL de déploiement Google Apps Script intégrée
const String _webhookUrl =
    'https://script.google.com/macros/s/AKfycbwTQY32fC7AUR0Jej5YCRWJXFB7HKXInO8xuPql0MB6hz8OQHHKuwSdqk_Q8Jbb3m-yrA/exec';

class ResultScreen extends StatefulWidget {
  final List<String> keywords;
  final List<String> symbolOrder;

  const ResultScreen(
      {super.key, required this.keywords, required this.symbolOrder});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _diagnosticFlash = 'Analyse en cours par le Coach Expert...';
  String _coachingPlan = '';
  bool _isLoading = true;
  bool _isPremiumUser = false;

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _generateCoachingPlan();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Vérifie si l'utilisateur a déjà 'acheté' le programme
  Future<void> _checkPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPremiumUser = prefs.getBool('isPremium') ?? false;
    });
  }

  // Widget pour afficher l'ordre des symboles (non modifié)
  Widget _buildSymbolOrderDisplay(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final symbolList = widget.symbolOrder.asMap().entries.map((entry) {
      final index = entry.key;
      final symbol = entry.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          '${index + 1}. $symbol',
          style: TextStyle(
            fontSize: 16,
            fontWeight: index < 2 ? FontWeight.bold : FontWeight.normal,
            color: index < 2
                ? accentColor
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Votre Géométrie Mentale (Ordre de priorité):',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
          ),
          const SizedBox(height: 10),
          ...symbolList,
        ],
      ),
    );
  }

  // Envoie les données au Webhook Google Sheet (non modifié)
  Future<void> _sendDataToWebhook(String email) async {
    try {
      await http.post(
        Uri.parse(_webhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'keywords': widget.keywords.join(', '),
          'symbolOrder': widget.symbolOrder.join(' > '),
          'diagnosticFlash': _diagnosticFlash,
        }),
      );
    } catch (e) {
      print('Erreur réseau Webhook: $e');
    }
  }

  // Affiche le dialogue de saisie d'email (non modifié)
  void _showEmailInputDialog() {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('Télécharger votre Analyse Complète',
              style: TextStyle(color: accentColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Pour recevoir le PDF de votre Diagnostic et de votre Plan d\'Action de 5 Semaines, veuillez entrer votre email :'),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Adresse Email',
                  labelStyle: TextStyle(color: accentColor.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ANNULER',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                if (EmailValidator.validate(email)) {
                  Navigator.of(context).pop();
                  await _generatePdfAndSend(email);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Veuillez entrer une adresse email valide.')),
                  );
                }
              },
              child: const Text('ENVOYER & TÉLÉCHARGER'),
            ),
          ],
        );
      },
    );
  }

  // Génère le PDF et envoie les données
  Future<void> _generatePdfAndSend(String email) async {
    // 1. Envoi des données (Lead Magnet)
    await _sendDataToWebhook(email);

    setState(() {
      _diagnosticFlash = 'Préparation du PDF...';
      _isLoading = true;
    });

    // 2. Génération du PDF
    final pdfService = PdfService(
      keywords: widget.keywords,
      symbolOrder: widget.symbolOrder,
      diagnosticFlash: _diagnosticFlash,
      coachingPlan: _coachingPlan,
    );

    try {
      // NOTE CRITIQUE: L'appel au PDF est neutralisé car les plugins ont été retirés pour corriger l'erreur V1 embedding.
      // await pdfService.generateAndSharePdf();
      
      setState(() {
        _diagnosticFlash =
            'PDF généré et partagé avec succès. Vérifiez vos téléchargements.';
      });
    } catch (e) {
      setState(() {
        _diagnosticFlash =
            'Erreur lors de la génération ou du partage du PDF. $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // SIMULATION DE PAIEMENT (Upsell - non modifié)
  Future<void> _handlePaymentSimulation(BuildContext context) async {
    if (_coachingPlan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Le plan IA est en cours de génération. Veuillez patienter.')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Simulation de Paiement'),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Traitement de l'achat (49€)..."),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();

    // Enregistrer le statut premium
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', true);
    setState(() => _isPremiumUser = true);

    // Redirection vers l'écran du plan complet
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RecalibrationPlanScreen(
            fullRecalibrationPlan: _coachingPlan),
      ),
    );
  }

  // Appelle l'API OpenAI avec le Prompt Calibré
  Future<void> _generateCoachingPlan() async {
    final keywordsString = widget.keywords.join(', ');
    final symbolOrderString = widget.symbolOrder.join(', ');

    // PROMPT FINALISÉ AVEC LA STRUCTURE 'SYNERGIE ÉVOLUTIVE'
    final prompt = """
    RÔLE: Tu es un Coach Expert "Synergie Évolutive". Ton style est autoritaire, précis, et bienveillant, intégrant les principes de la PNL, de l'Ennéagramme et de l'alignement énergétique.
    
    BASE DE CONNAISSANCE DU PROGRAMME "SYNERGIE ÉVOLUTIVE":
    Le programme est structuré autour de 4 phases : Prise de Conscience, Ressentis des Énergies/Vision, Reconnexion/Fusion, et Excellence Professionnelle. Les outils privilégiés incluent l'Exploration des Biais Cognitifs, les techniques de PNL (ancrage, visualisation, alignement) et le Centrage Émotionnel.
    
    MISSION: Analyser le profil utilisateur (Conscient: $keywordsString | Inconscient: $symbolOrderString) et générer deux sections strictement formatées : un diagnostic flash et un plan de recalibration de 5 semaines.
    
    CONTRAINTE CLÉ POUR LE PLAN (5 SEMAINES): Chaque semaine doit s'ancrer dans l'une des phases du programme (Fusion, Vision, etc.) et proposer un outil spécifique qui résonne avec l'analyse.
    
    STRUCTURE DE RÉPONSE ATTENDUE: (Respecter strictement ces balises pour le parsing Dart)
    
    [DIAGNOSTIC_FLASH] : Un paragraphe de 100-150 mots maximum. Interprète la tension entre les Mots-clés et l'Ordre Symbolique. Le diagnostic doit se conclure par le besoin principal (Ex: "Votre besoin primaire est la Structure avant l'Action").
    
    [PLAN_5_SEMAINES] : Le plan complet de 5 semaines, strictement formaté pour le parsing :
    
    SEMAINE 1 : CONSOLIDATION - Prise de Conscience & Diagnostic - Outil: Exploration des Biais Cognitifs. [Détail de l'objectif, étapes clés liées à la PNL et à l'état de conscience].
    SEMAINE 2 : VISION - Élaboration d'Objectifs & Ressentis - Outil: Vision Clairvoyante du Soi Professionnel (PNL). [Détail lié à la création d'une vision claire du succès professionnel].
    SEMAINE 3 : INTÉGRATION - Clarification Matière/Énergie - Outil: Distinction entre Matière et Énergie (PNL). [Détail sur l'alignement des actions concrètes avec l'énergie investie].
    SEMAINE 4 : FUSION - Alignement & Stratégies - Outil: Fusion des Énergies Matérielles et Spirituelles. [Détail sur l'utilisation de la PNL pour l'alignement et la congruence].
    SEMAINE 5 : EXCELLENCE - Planification & Ancrage - Outil: Planification de l'Excellence Professionnelle (PNL). [Détail sur l'élaboration d'un plan d'action concret et l'ancrage des états de réussite].
    """;

    try {
      final response = await http.post(
        Uri.parse(openaiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        String content = '';
        if (data['choices'] != null &&
            data['choices'].isNotEmpty &&
            data['choices'][0]['message'] != null) {
          content = data['choices'][0]['message']['content'] as String;
        } else {
          throw Exception('Réponse de l\'API vide ou mal formée.');
        }

        // Parsing du contenu pour extraire les deux parties
        final parts = content.split('[PLAN_5_SEMAINES] :');
        final diagnosticPart = parts[0];
        final planPart = parts.length > 1
            ? parts[1].trim()
            : "Plan non généré ou mal formaté.";

        final cleanDiagnostic = diagnosticPart
            .replaceFirst('[DIAGNOSTIC_FLASH] :', '')
            .trim(); // Supprime la balise

        setState(() {
          _diagnosticFlash = cleanDiagnostic;
          _coachingPlan = planPart;
          _isLoading = false;
        });
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        setState(() {
          _diagnosticFlash =
              'Erreur lors de l\'appel à l\'API. Code: ${response.statusCode}. Vérifiez votre clé, vos quotas ou le modèle.';
          _isLoading = false;
        });
      }
    } on SocketException {
      // Gestion de l'erreur DNS/Internet (votre problème initial)
      setState(() {
        _diagnosticFlash =
            'Erreur de connexion réseau : impossible de joindre api.openai.com. Vérifiez votre connexion Internet.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _diagnosticFlash =
            'Erreur de traitement (timeout ou parsing). Réessayez. Détails: $e';
        _isLoading = false;
      });
    }
  }

  // Widget pour le bouton de réinitialisation si une erreur se produit (non modifié)
  Widget _buildRetryButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _diagnosticFlash = 'Analyse en cours par le Coach Expert...';
            _coachingPlan = '';
            _isLoading = true;
          });
          _generateCoachingPlan();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Réessayer l\'Analyse'),
      ),
    );
  }

  // Méthode pour afficher les 4 phases du programme Synergie Évolutive (non modifié)
  void _showProgramStructureDialog() {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    // Structure des phases de Synergie Évolutive (basée sur le document)
    final List<String> phases = [
      'Phase 1: Prise de Conscience du Soi (Biais Cognitifs, PNL, Centrage Émotionnel)',
      'Phase 2: Ressentis des Énergies Internes et Vision du Soi (Visualisation, PNL)',
      'Phase 3: Reconnexion et Fusion des Énergies (Alignement Actions/Valeurs, Distinction Matière/Énergie)',
      'Phase 4: Fusion et Excellence Professionnelle (Ancrage, Planification PNL)',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('Structure du Programme "Synergie Évolutive"',
              style: TextStyle(color: accentColor, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Découvrez les 4 piliers de votre transformation. Ce plan de 5 semaines est entièrement personnalisé sur ces fondations :',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 15),
                ...phases
                    .map((phase) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle,
                                  color: accentColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(phase,
                                      style:
                                          const TextStyle(fontSize: 14))),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('FERMER', style: TextStyle(color: accentColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre Diagnostic Flash'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Carte du Diagnostic ---
            Card(
              elevation: 4,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 Votre Diagnostic Flash CIGA Process:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const Divider(height: 20, color: Colors.grey),
                    if (_isLoading)
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 15),
                            Text(_diagnosticFlash, textAlign: TextAlign.center),
                          ],
                        ),
                      )
                    else
                      Text(
                        _diagnosticFlash,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Affichage de l'Ordre Symbolique ---
            if (!_isLoading && !_diagnosticFlash.startsWith('Erreur'))
              _buildSymbolOrderDisplay(context),

            const SizedBox(height: 30),

            // --- Tunnel de Vente ---
            if (_isLoading)
              const SizedBox.shrink()
            else if (_coachingPlan.isEmpty ||
                _diagnosticFlash.startsWith('Erreur'))
              // Affiche le bouton de réessai
              _buildRetryButton()
            else
              // Boutons d'action (Lead Magnet et Upsell)
              Column(
                children: [
                  // 1. LEAD MAGNET (PDF)
                  ElevatedButton.icon(
                    onPressed: _showEmailInputDialog,
                    icon: const Icon(Icons.download),
                    label: const Text('TÉLÉCHARGER MON ANALYSE COMPLÈTE (PDF)'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. UPSELL (Programme 5 Semaines)
                  Card(
                    elevation: 6,
                    color: _isPremiumUser
                        ? Colors.green.shade50
                        : Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Nouvelle ligne pour la prévisualisation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isPremiumUser
                                    ? '✅ Accès au Programme'
                                    : '🔥 Passez à l\'Action',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isPremiumUser
                                      ? Colors.greenAccent
                                      : accentColor,
                                ),
                              ),
                              TextButton(
                                onPressed: _showProgramStructureDialog,
                                child: Text('Voir la structure',
                                    style: TextStyle(
                                        color: accentColor.withOpacity(0.8),
                                        fontSize: 14)),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Boutons Acheter/Voir
                          _isPremiumUser
                              ? ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecalibrationPlanScreen(
                                                fullRecalibrationPlan:
                                                    _coachingPlan),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.verified),
                                  label:
                                      const Text('VOIR MON PROGRAMME COMPLET'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () =>
                                      _handlePaymentSimulation(context),
                                  icon: const Icon(Icons.lock_open),
                                  label: const Text(
                                      'ACHETER MON PROGRAMME 5 SEMAINES (49€)'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Disclaimer bas de page
            const Center(
              child: Text(
                "Le Diagnostic Flash ne remplace en aucun cas une consultation médicale ou un traitement par un professionnel de la santé mentale.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}