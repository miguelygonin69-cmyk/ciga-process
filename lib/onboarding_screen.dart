// lib/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'input_screen.dart';

// Modèle pour chaque page
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'LA GÉOMÉTRIE MENTALE',
      description:
          'Vos mots révèlent votre conscient. Vos symboles trahissent votre inconscient. CIGA décode la friction entre les deux.',
      icon: Icons.architecture,
    ),
    OnboardingPage(
      title: 'HONNÊTETÉ RADICALE',
      description:
          'Le miroir ne ment pas. Pour que l\'analyse fonctionne, ne cherchez pas à \'bien faire\'. Soyez brut. Soyez vrai.',
      icon: Icons.remove_red_eye_outlined,
    ),
    OnboardingPage(
      title: 'INTELLIGENCE HYBRIDE',
      description:
          'CIGA n\'est pas un simple chatbot. C\'est un moteur d\'analyse qui croise la psychologie des profondeurs avec la puissance de calcul de l\'IA.',
      icon: Icons.psychology_outlined,
    ),
  ];

  // Marque la première ouverture pour ne pas réafficher l'écran
  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasRunOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const InputScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Utilise la couleur d'accentuation Cyan/Bleu vif des captures de page
    const Color introAccentColor = Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Fond Noir
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: introAccentColor, width: 2),
                      ),
                      child: Icon(
                        _pages[index].icon,
                        size: 80,
                        color: introAccentColor,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      _pages[index].title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _pages[index].description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: const Color(0xFFCCCCCC),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Indicateur de page (Dots)
          Align(
            alignment: const Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? introAccentColor
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          // Bouton Suivant/Terminer
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: FloatingActionButton(
                backgroundColor: introAccentColor,
                foregroundColor: Colors.black,
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _finishOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Icon(
                  _currentPage == _pages.length - 1
                      ? Icons.check
                      : Icons.arrow_forward,
                ),
              ),
            ),
          ),

          // Bouton Passer
          if (_currentPage < _pages.length - 1)
            Align(
              alignment: Alignment.topRight,
              child: SafeArea(
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'PASSER',
                    style: TextStyle(color: introAccentColor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
