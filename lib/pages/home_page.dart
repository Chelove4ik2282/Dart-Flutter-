import 'dart:ui';
import 'package:flutter/material.dart';
import 'setup_page.dart';

class GameButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const GameButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shadowColor: Colors.black54,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A0CA3), Color(0xFF4361EE), Color(0xFF4CC9F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🌫️ Glass effect overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🎮 Welcome to Taboo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Start Game
                    GameButton(
                      text: 'Start Game',
                      icon: Icons.play_arrow_rounded,
                      color: const Color(0xFF00C896),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SetupPage()),
                        );
                      },
                    ),

                    // Instructions
                    GameButton(
                      text: 'Instructions',
                      icon: Icons.info_outline,
                      color: const Color(0xFF3A86FF),
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          backgroundColor: const Color(0xFF1C1B33),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.6,
                            minChildSize: 0.4,
                            maxChildSize: 0.9,
                            builder: (_, controller) => SingleChildScrollView(
                              controller: controller,
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 5,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white38,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const Center(
                                    child: Text(
                                      '📘 How to Play Taboo',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amberAccent,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  _instructionItem("👥 Split into two teams."),
                                  _instructionItem("🎴 One player draws a card with a word."),
                                  _instructionItem("🚫 They must describe the word without using the taboo words."),
                                  _instructionItem("🧠 Teammates try to guess the word."),
                                  _instructionItem("⏳ Beat the timer and guess as many as possible."),
                                  _instructionItem("🏆 Each correct guess earns a point."),
                                  _instructionItem("🔁 Rotate the clue-giver after each round."),
                                  _instructionItem("📋 Prepare a list of cards or use the built-in word list."),
                                  _instructionItem("🛑 If the clue-giver says a taboo word, the team loses a point."),
                                  _instructionItem("👀 The opposing team watches to ensure rules are followed."),
                                  _instructionItem("🕵️‍♂️ One player can act as a judge to manage time and check words."),
                                  _instructionItem("🧭 Decide the number of rounds before starting the game."),
                                  _instructionItem("🔕 No gestures or sounds — words only!"),
                                  _instructionItem("💬 Use synonyms, definitions, and associations to describe the word."),
                                  _instructionItem("❌ Don’t use any part of the taboo word or direct translations."),
                                  _instructionItem("🎯 The team with the most points at the end wins."),
                                  
                                  const SizedBox(height: 30),
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.check_circle_outline),
                                      label: const Text("Let's Go!"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amberAccent,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // History
                    GameButton(
                      text: 'History',
                      icon: Icons.history_rounded,
                      color: const Color(0xFFFF9F1C),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('History page coming soon!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.black87,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Colors.amberAccent, fontSize: 18),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
