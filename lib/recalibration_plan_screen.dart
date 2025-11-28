import 'package:flutter/material.dart';

class RecalibrationPlanScreen extends StatelessWidget {
  final String fullRecalibrationPlan;

  const RecalibrationPlanScreen(
      {super.key, required this.fullRecalibrationPlan});

  // Simple parser pour mettre en forme le plan
  List<Widget> _parsePlan(String plan) {
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
            collapsedBackgroundColor: Colors.indigo.shade50,
            backgroundColor: Colors.indigo.shade100,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF3F51B5), // Indigo
              child: Text('$index',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(
              'SEMAINE $index : $titleLine',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  details,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 14),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programme de Recalibration (5 Semaines)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Félicitations ! Votre Programme Synergie Évolutive est Prêt.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5)),
              ),
            ),
            const Divider(height: 30),

            // Afficher le plan complet
            ..._parsePlan(fullRecalibrationPlan),

            const SizedBox(height: 20),
            Center(
              child: Text(
                'Ce programme est basé sur votre profil unique.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
