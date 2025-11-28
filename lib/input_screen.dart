import 'package:flutter/material.dart';
import 'result_screen.dart';

// Définition du modèle Symbole pour le classement
class SymbolItem {
  final String name;
  final String description;
  final IconData icon;

  SymbolItem(this.name, this.description, this.icon);
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // Les 3 mots-clés sont gérés par des contrôleurs de texte
  final List<TextEditingController> _keywordControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // Les 5 Symboles CIGA
  List<SymbolItem> _symbols = [
    SymbolItem('Spirale', 'Évolution', Icons.cached),
    SymbolItem('Croix', 'Choix', Icons.close),
    SymbolItem('Triangle', 'Action', Icons.change_history),
    SymbolItem('Cercle', 'Unité', Icons.circle_outlined),
    SymbolItem('Carré', 'Structure', Icons.square_outlined),
  ];

  // Liste réordonnée des symboles pour le classement
  List<SymbolItem> _rankedSymbols = [];

  // Liste des mots sensibles pour le filtrage
  final List<String> _sensitiveWords = const [
    'suicide',
    'arme',
    'mort',
    'drogue',
    'violence',
    'abus',
    'danger',
    'tuer',
    'mourir',
    'pistolet',
    'blessure',
  ];

  @override
  void initState() {
    super.initState();
    _rankedSymbols = List.from(_symbols); // Initialiser avec la liste complète
  }

  @override
  void dispose() {
    for (var controller in _keywordControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final SymbolItem item = _rankedSymbols.removeAt(oldIndex);
      _rankedSymbols.insert(newIndex, item);
    });
  }

  // Affiche l'alerte pour contenu sensible
  void _showSensitiveContentAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text(
          '⚠️ Contenu Sensible Détecté',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          'Votre description contient des mots qui indiquent une situation critique. '
          'CIGA Process n\'est pas un outil d\'urgence ni un substitut à un professionnel de la santé mentale. '
          'Veuillez contacter immédiatement un spécialiste ou une ligne d\'assistance dédiée (par exemple, le 3114 en France).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToResult() {
    // 1. Récupération des mots-clés
    final List<String> keywords = _keywordControllers
        .map((c) => c.text.trim())
        .where((k) => k.isNotEmpty)
        .toList();

    // 2. Validation de l'entrée (3 mots minimum)
    if (keywords.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir les 3 mots-clés.')),
      );
      return;
    }

    // 3. Vérification des mots sensibles
    final inputWords = keywords.map((k) => k.toLowerCase()).toSet();
    final hasSensitiveContent = inputWords.any(
      (word) => _sensitiveWords.any((sensitive) => word.contains(sensitive)),
    );

    if (hasSensitiveContent) {
      _showSensitiveContentAlert();
      return;
    }

    // 4. Récupération de l'ordre des symboles
    final List<String> symbolOrder = _rankedSymbols.map((s) => s.name).toList();

    // 5. Navigation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ResultScreen(keywords: keywords, symbolOrder: symbolOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary; // Or/Ambre
    final foregroundColor = Theme.of(
      context,
    ).colorScheme.onSurface; // Blanc/Gris clair

    return Scaffold(
      appBar: AppBar(title: const Text('CIGA Process - Saisie'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // CARD d'introduction / Logo (esthétique similaire à votre capture)
            Center(
              child: Card(
                elevation: 8,
                color: Colors.white, // Garder le fond de la Card blanc
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  // Vous devez avoir 'logo.png' dans assets/
                  child: Image.asset('assets/logo.png', height: 100),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Text(
              '1. Saisissez 3 Mots-clés de votre état d\'esprit actuel:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
            const SizedBox(height: 10),
            ..._keywordControllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: controller,
                  // Style pour thème sombre
                  style: TextStyle(color: foregroundColor),
                  decoration: InputDecoration(
                    labelText: 'Mot-clé ${index + 1}',
                    labelStyle: TextStyle(
                      color: foregroundColor.withOpacity(0.7),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: accentColor.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            Text(
              '2. Classez les Symboles (du plus important au moins important) par Drag & Drop:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
            const SizedBox(height: 10),

            // Liste réordonnable des symboles
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: accentColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.black, // Léger contraste sur fond noir
              ),
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: _onReorder,
                children: _rankedSymbols.map((SymbolItem symbol) {
                  return Card(
                    key: ValueKey(symbol.name),
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    color: Colors
                        .grey
                        .shade900, // Couleur pour le Drag & Drop sur fond sombre
                    child: ListTile(
                      leading: Icon(symbol.icon, color: accentColor),
                      title: Text(
                        symbol.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: foregroundColor,
                        ),
                      ),
                      subtitle: Text(
                        symbol.description,
                        style: TextStyle(
                          color: foregroundColor.withOpacity(0.7),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.drag_handle,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),

            Center(
              // Le style de ce bouton est défini dans lib/main.dart (ElevatedButtonTheme)
              child: ElevatedButton.icon(
                onPressed: _navigateToResult,
                icon: const Icon(Icons.send),
                label: const Text('Générer mon Diagnostic Flash'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
