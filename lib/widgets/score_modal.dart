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
    if (teamAScore > teamBScore) {
      resultMessage = 'Team A Wins!';
    } else if (teamBScore > teamAScore) {
      resultMessage = 'Team B Wins!';
    } else {
      resultMessage = 'It\'s a Tie!';
    }

    return AlertDialog(
      title: const Text('Game Over'),
      content: Text(resultMessage),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmed();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
