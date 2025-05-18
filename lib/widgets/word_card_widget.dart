import 'package:flutter/material.dart';

class WordCardWidget extends StatelessWidget {
  final String word;
  final List<String> tabooWords;
  final VoidCallback onCorrect;
  final VoidCallback onTaboo;
  final VoidCallback onSkip;

  const WordCardWidget({
    Key? key,
    required this.word,
    required this.tabooWords,
    required this.onCorrect,
    required this.onTaboo,
    required this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Taboo words:',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: tabooWords
                  .map((w) => Chip(
                        label: Text(w),
                        backgroundColor: Colors.red.shade100,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onCorrect,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Correct'),
                ),
                ElevatedButton(
                  onPressed: onTaboo,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Taboo'),
                ),
                ElevatedButton(
                  onPressed: onSkip,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Skip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
