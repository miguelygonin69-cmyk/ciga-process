import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Nécessaire pour rootBundle
import 'package:shared_preferences/shared_preferences.dart';
import 'input_screen.dart';
import 'onboarding_screen.dart';

// Modifiez la fonction main pour qu'elle soit asynchrone
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Pré-chargement du logo (Robustesse du PDF)
  try {
    await rootBundle.load('assets/logo.png');
  } catch (e) {
    print(
        "Erreur de pré-chargement du logo: $e. Vérifiez assets/logo.png et pubspec.yaml.");
  }

  // 2. Vérification de l'Onboarding
  final prefs = await SharedPreferences.getInstance();
  final hasRunOnboarding = prefs.getBool('hasRunOnboarding') ?? false;

  runApp(CigaProcessApp(hasRunOnboarding: hasRunOnboarding));
}

class CigaProcessApp extends StatelessWidget {
  final bool hasRunOnboarding;

  const CigaProcessApp({super.key, required this.hasRunOnboarding});

  @override
  Widget build(BuildContext context) {
    // Palette 'Noir/Or'
    const Color darkBackground = Color(0xFF0A0A0A);
    const Color lightForeground = Color(0xFFEBEBEB);
    const Color accentGold = Color(0xFFFFC107);

    return MaterialApp(
      title: 'CIGA Process',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Thème sombre
        brightness: Brightness.dark,

        // Couleurs de base
        primaryColor: accentGold,
        scaffoldBackgroundColor: darkBackground,

        colorScheme: ColorScheme.dark(
          primary: accentGold,
          onPrimary: Colors.black,
          secondary: accentGold,
          background: darkBackground,
          surface: Colors.grey.shade900, // Couleur des Cards, Dialogues
          onSurface: lightForeground,
          error: Colors.redAccent,
        ),

        // Style de texte global
        textTheme: const TextTheme(
          headlineLarge:
              TextStyle(color: lightForeground, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: lightForeground),
        ),

        // Configuration de l'AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          foregroundColor: lightForeground,
          elevation: 0,
        ),

        // Configuration des boutons (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGold,
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      // Point d'entrée conditionnel
      home: hasRunOnboarding ? const InputScreen() : const OnboardingScreen(),
    );
  }
}
