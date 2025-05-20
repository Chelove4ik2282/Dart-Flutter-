import 'package:flutter/material.dart';

class ScoreModal extends StatelessWidget {
  final int teamAScore;
  final int teamBScore;
  final VoidCallback onConfirmed;

  const ScoreModal({
    super.key,
    required this.teamAScore,
    required this.teamBScore,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    String resultMessage;
    IconData resultIcon;
    Color resultColor;

    if (teamAScore > teamBScore) {
      resultMessage = '🎉 Team A Wins!';
      resultIcon = Icons.emoji_events;
      resultColor = Colors.green;
    } else if (teamBScore > teamAScore) {
      resultMessage = '🎉 Team B Wins!';
      resultIcon = Icons.emoji_events;
      resultColor = Colors.blue;
    } else {
      resultMessage = '🤝 It\'s a Tie!';
      resultIcon = Icons.handshake;
      resultColor = Colors.orange;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.indigo.shade900
          : Colors.white,
      title: Column(
        children: [
          Icon(resultIcon, size: 48, color: resultColor),
          const SizedBox(height: 12),
          Text(
            'Game Over',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            resultMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildScoreRow('Team A', teamAScore, Colors.green),
          const SizedBox(height: 8),
          _buildScoreRow('Team B', teamBScore, Colors.blue),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: resultColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.home, size: 20),
          label: const Text(
            'Back to Home',
            style: TextStyle(fontSize: 16),
          ),
          onPressed: onConfirmed,
        ),
      ],
    );
  }

  Widget _buildScoreRow(String team, int score, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$team:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color),
        ),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [
              Shadow(
                color: color.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
