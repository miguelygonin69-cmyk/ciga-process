import 'package:flutter/material.dart';

class RecalibrationPlanScreen extends StatelessWidget {
  final String fullRecalibrationPlan;

  const RecalibrationPlanScreen(
      {super.key, required this.fullRecalibrationPlan});

  // Simple parser pour mettre en forme le plan
  List<Widget> _parsePlan(String plan, BuildContext context) {
    // Récupération des couleurs du thème (Or et Gris/Noir)
    final accentColor = Theme.of(context).colorScheme.primary; // Or
    final surfaceColor = Theme.of(context).colorScheme.surface; // Gris foncé
    final foregroundColor = Theme.of(context).colorScheme.onSurface; // Blanc/Gris clair

    // Le prompt garantit un format SEMAINE X : TITRE (DETAILS)
    final List<String> parts = plan.split(RegExp(r'\bSEMAINE\s\d\s:'));

    // Supprime la première entrée vide avant le premier "SEMAINE 1"
    parts.removeAt(0);

    return parts.asMap().entries.map((entry) {
      final int index = entry.key + 1;
      final String content = entry.value.trim();
      final List<String> lines =
          content.split('\n').where((l) => l.isNotEmpty).toList();

      if (lines.isEmpty) return const SizedBox.shrink();

      final String titleLine = lines.first;
      final String details = lines.skip(1).join('\n');

      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ExpansionTile(
            initiallyExpanded: index == 1,
            // CORRECTION: Utilisation des couleurs du thème (surface / accent)
            collapsedBackgroundColor: surfaceColor, 
            backgroundColor: surfaceColor,
            leading: CircleAvatar(
              backgroundColor: accentColor, // Utilise la couleur Or
              child: Text('$index',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            title: Text(
              'SEMAINE $index : $titleLine',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: accentColor), // Utilise la couleur Or
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  details,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 14, color: foregroundColor),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary; // Or
    final foregroundColor = Theme.of(context).colorScheme.onSurface; // Blanc/Gris clair

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programme de Recalibration (5 Semaines)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Félicitations ! Votre Programme Synergie Évolutive est Prêt.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor), // Utilise la couleur Or
              ),
            ),
            const Divider(height: 30),

            // Afficher le plan complet
            ..._parsePlan(fullRecalibrationPlan, context), // NOTE: Passage du context

            const SizedBox(height: 20),
            Center(
              child: Text(
                'Ce programme est basé sur votre profil unique.',
                style: TextStyle(color: foregroundColor.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}