import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_result.dart';
import '../widgets/word_card_widget.dart';
import '../widgets/score_modal.dart';
import '../services/local_storage_service.dart';
import '../controllers/game_controller.dart';
import 'home_page.dart';

class HomeGamePage extends StatefulWidget {
  final List<Player> players;
  final int totalRounds;

  const HomeGamePage({super.key, required this.players, required this.totalRounds});

  @override
  State<HomeGamePage> createState() => _HomeGamePageState();
}

class _HomeGamePageState extends State<HomeGamePage> {
  late List<Player> teamAPlayers;
  late List<Player> teamBPlayers;
  int currentRound = 1;
  int teamAScore = 0;
  int teamBScore = 0;
  int roundTurn = 0;

  List<int> roundScoresA = [];
  List<int> roundScoresB = [];

  final GameController controller = GameController();

  @override
  void initState() {
    super.initState();
    teamAPlayers = widget.players.where((p) => p.team == 'A').toList();
    teamBPlayers = widget.players.where((p) => p.team == 'B').toList();

    controller.onTick = (seconds) => setState(() {});
    controller.onTimeUp = () {
  controller.stopTimer();

  _showDialogWithTitleAndAction(
    icon: Icons.flag,
    iconColor: Colors.orange,
    title: 'Round ${currentRound} Over',
    content: '⏰ Time is up!\n\nReady for the next team?',
    buttonText: currentRound >= widget.totalRounds && roundTurn == 1 ? 'Show Results' : 'Next',
    buttonColor: Colors.indigo,
    onPressed: _nextTurnOrRound,
  );
};

    controller.onWin = () {
      controller.stopTimer();
      _saveGameHistory();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWinDialog();
      });
    };

    _showStartRoundDialog();
  }

  @override
  void dispose() {
    controller.stopTimer();
    super.dispose();
  }

  void _handleRoundEnd({required bool taboo}) {
    setState(() {
      if (taboo) {
        if (roundTurn == 0) {
          teamAScore = (teamAScore - 1).clamp(0, 999);
        } else {
          teamBScore = (teamBScore - 1).clamp(0, 999);
        }
      } else {
        if (roundTurn == 0) {
          teamAScore++;
        } else {
          teamBScore++;
        }
      }
      controller.nextWord();
    });
  }

  void _skipWord() {
    setState(() => controller.nextWord());
  }

  void _nextTurnOrRound() {
    if (roundTurn == 0) {
      roundScoresA.add(teamAScore - roundScoresA.fold(0, (a, b) => a + b));
      roundTurn = 1;
    } else {
      roundScoresB.add(teamBScore - roundScoresB.fold(0, (a, b) => a + b));
      roundTurn = 0;
      currentRound++;
    }

    if (currentRound > widget.totalRounds) {
      _saveGameHistory();
      _showGameOverDialog();
    } else {
      controller.resetWords();
      _showStartRoundDialog();
    }
  }

  void _showStartRoundDialog() {
    _showDialogWithTitleAndAction(
      icon: Icons.play_circle_fill,
      iconColor: Colors.blueAccent,
      title: 'Round $currentRound',
      content: 'Team ${roundTurn == 0 ? 'A' : 'B'}, get ready!',
      buttonText: 'Start',
      buttonColor: Colors.indigo,
      onPressed: controller.startTimer,
    );
  }

  void _showDialogWithTitleAndAction({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(content, style: const TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                onPressed();
              },
              child: Text(buttonText),
            ),
          ],
        ),
      );
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScoreModal(
        teamAScore: teamAScore,
        teamBScore: teamBScore,
        onConfirmed: () {
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        },
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 10),
            Text('Victory!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'You guessed all the words!',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGameHistory() async {
    final now = DateTime.now();
    final duration = controller.totalDurationSeconds;
    final gameResult = GameResult(
      teamAPlayers.map((p) => p.name).join(', '),
      teamBPlayers.map((p) => p.name).join(', '),
      teamAScore,
      teamBScore,
      now.toIso8601String(),
      winner: teamAScore > teamBScore
          ? 'Team A'
          : teamBScore > teamAScore
              ? 'Team B'
              : 'Draw',
      roundsPlayed: widget.totalRounds,
      team1Players: teamAPlayers.map((p) => p.name).toList(),
      team2Players: teamBPlayers.map((p) => p.name).toList(),
      duration: duration,
      notes: null,
      team1RoundScores: roundScoresA,
      team2RoundScores: roundScoresB,
    );

    await LocalStorageService.instance.insertGame(gameResult);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Round $currentRound / ${widget.totalRounds}', style: TextStyle(color: Colors.white)),
        
        centerTitle: true,
        elevation: 3,
        backgroundColor: isDark ? Colors.indigo[700] : Colors.indigo,
        shadowColor: Colors.indigoAccent.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Team ${roundTurn == 0 ? 'A' : 'B'}\'s Turn',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.indigoAccent : Colors.indigo.shade900,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Time left: ${controller.secondsLeft} s',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: WordCardWidget(
                word: controller.currentWord,
                tabooWords: controller.tabooWords,
                onCorrect: () => _handleRoundEnd(taboo: false),
                onTaboo: () => _handleRoundEnd(taboo: true),
                onSkip: _skipWord,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.indigo.shade900 : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.indigoAccent.withOpacity(0.3) : Colors.indigo.shade200,
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreColumn('Team A Score', teamAScore, Colors.green.shade400),
                  _buildScoreColumn('Team B Score', teamBScore, Colors.blue.shade400),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreColumn(String label, int score, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.85),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [
              Shadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
