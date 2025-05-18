import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/game_result.dart';
import '../widgets/word_card_widget.dart';
import '../widgets/score_modal.dart';
import '../services/local_storage_service.dart';  // <-- Импорт сервиса локального хранилища

class HomeGamePage extends StatefulWidget {
  final List<Player> players;
  final int totalRounds;

  const HomeGamePage({super.key, required this.players, required this.totalRounds});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<HomeGamePage> {
  late List<Player> teamAPlayers;
  late List<Player> teamBPlayers;

  int currentRound = 1;
  int teamAScore = 0;
  int teamBScore = 0;
  String currentTeam = 'A';
  List<int> roundScoresA = [];
  List<int> roundScoresB = [];

  static const int roundDuration = 60;
  int secondsLeft = roundDuration;
  Timer? timer;

  final List<Map<String, dynamic>> allWords = [
    {'word': 'Sunflower', 'taboo': ['Flower', 'Yellow', 'Plant', 'Garden', 'Petal']},
    {'word': 'Apple', 'taboo': ['Fruit', 'Red', 'Tree', 'Pie', 'Sweet']},
    {'word': 'Car', 'taboo': ['Drive', 'Engine', 'Wheels', 'Road', 'Speed']},
    {'word': 'Dog', 'taboo': ['Pet', 'Bark', 'Tail', 'Animal', 'Fetch']},
    {'word': 'Computer', 'taboo': ['Keyboard', 'Mouse', 'Screen', 'Internet', 'Laptop']},
    {'word': 'Book', 'taboo': ['Read', 'Library', 'Pages', 'Story', 'Cover']},
    {'word': 'Pizza', 'taboo': ['Cheese', 'Crust', 'Slice', 'Oven', 'Pepperoni']},
    {'word': 'Chair', 'taboo': ['Sit', 'Legs', 'Seat', 'Backrest', 'Wood']},
    {'word': 'Ocean', 'taboo': ['Water', 'Waves', 'Sea', 'Beach', 'Fish']},
    {'word': 'Clock', 'taboo': ['Time', 'Hands', 'Wall', 'Tick', 'Watch']},
    {'word': 'Phone', 'taboo': ['Call', 'Text', 'Smart', 'Ring', 'Mobile']},
    {'word': 'Bicycle', 'taboo': ['Pedal', 'Wheels', 'Ride', 'Helmet', 'Handlebar']},
    {'word': 'Ice Cream', 'taboo': ['Cold', 'Dessert', 'Cone', 'Scoop', 'Sweet']},
    {'word': 'Movie', 'taboo': ['Cinema', 'Screen', 'Actor', 'Popcorn', 'Watch']},
    {'word': 'Mountain', 'taboo': ['Climb', 'Peak', 'Tall', 'Hike', 'Rock']},
    {'word': 'Basketball', 'taboo': ['Sport', 'Hoop', 'Dribble', 'Court', 'NBA']},
    {'word': 'Camera', 'taboo': ['Photo', 'Lens', 'Shoot', 'Flash', 'Picture']},
    {'word': 'Pencil', 'taboo': ['Write', 'Eraser', 'Paper', 'Sharp', 'Lead']},
    {'word': 'Milk', 'taboo': ['Drink', 'Cow', 'White', 'Glass', 'Dairy']},
    {'word': 'Plane', 'taboo': ['Fly', 'Pilot', 'Airport', 'Wings', 'Sky']},
    {'word': 'Ghost', 'taboo': ['Scary', 'Haunt', 'Spirit', 'Boo', 'Invisible']},
    {'word': 'Robot', 'taboo': ['Machine', 'AI', 'Metal', 'Automate', 'Technology']},
    {'word': 'Music', 'taboo': ['Song', 'Sing', 'Instrument', 'Sound', 'Melody']},
    {'word': 'Toothbrush', 'taboo': ['Teeth', 'Brush', 'Toothpaste', 'Clean', 'Bathroom']},
    {'word': 'Train', 'taboo': ['Track', 'Railway', 'Station', 'Locomotive', 'Travel']},
    {'word': 'Fire', 'taboo': ['Hot', 'Flame', 'Burn', 'Smoke', 'Campfire']},
    {'word': 'Doctor', 'taboo': ['Hospital', 'Patient', 'Medicine', 'Nurse', 'Sick']},
    {'word': 'Snow', 'taboo': ['Cold', 'White', 'Winter', 'Ice', 'Flakes']},
    {'word': 'Balloon', 'taboo': ['Air', 'Helium', 'Float', 'Pop', 'Party']},
    {'word': 'Map', 'taboo': ['Directions', 'Country', 'Route', 'Navigate', 'Location']},
  ];

  late List<Map<String, dynamic>> remainingWords;
  int currentWordIndex = 0;

  Map<String, dynamic> get currentWordMap => remainingWords[currentWordIndex];
  String get currentWord => currentWordMap['word'];
  List<String> get tabooWords => List<String>.from(currentWordMap['taboo']);

  @override
  void initState() {
    super.initState();
    teamAPlayers = widget.players.where((p) => p.team == 'A').toList();
    teamBPlayers = widget.players.where((p) => p.team == 'B').toList();
    remainingWords = List<Map<String, dynamic>>.from(allWords)..shuffle(Random());
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();
    setState(() {
      secondsLeft = roundDuration;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft > 0) {
        setState(() {
          secondsLeft--;
        });
      } else {
        t.cancel();
        _showRoundEndDialog(reason: 'Time is up! The round has ended.');
      }
    });
  }

  void _handleRoundEnd({required int scoreChange, required bool taboo}) {
    setState(() {
      if (scoreChange != 0) {
        if (taboo) {
          if (currentTeam == 'A') {
            teamAScore = (teamAScore - 1).clamp(0, 999);
          } else {
            teamBScore = (teamBScore - 1).clamp(0, 999);
          }
        } else {
          if (currentTeam == 'A') {
            teamAScore++;
          } else {
            teamBScore++;
          }
        }
      }
      remainingWords.removeAt(currentWordIndex);
    });

    if (remainingWords.isEmpty) {
      timer?.cancel();
      _showRoundEndDialog(reason: 'No more words left! The round has ended.');
    } else {
      setState(() {
        currentWordIndex = 0;
      });
    }
  }

  void _skipRound() {
    setState(() {
      remainingWords.removeAt(currentWordIndex);
    });

    if (remainingWords.isEmpty) {
      timer?.cancel();
      _showRoundEndDialog(reason: 'No more words left! The round has ended.');
    } else {
      setState(() {
        currentWordIndex = 0;
      });
    }
  }

  void _nextRound() {
    setState(() {
      // Добавляем очки за раунд
      int lastSumA = roundScoresA.fold(0, (a, b) => a + b);
      int lastSumB = roundScoresB.fold(0, (a, b) => a + b);

      roundScoresA.add(teamAScore - lastSumA);
      roundScoresB.add(teamBScore - lastSumB);

      currentRound++;
      currentTeam = currentTeam == 'A' ? 'B' : 'A';
      currentWordIndex = 0;
      remainingWords = List<Map<String, dynamic>>.from(allWords)..shuffle(Random());
    });
    startTimer();
  }

  void _showRoundEndDialog({required String reason}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Round Over'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (currentRound < widget.totalRounds && remainingWords.isNotEmpty) {
                _nextRound();
              } else {
                _saveGameHistory();
                _showGameOverDialog();
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
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
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _saveGameHistory() async {
  final gameResult = GameResult(
  teamAPlayers.map((p) => p.name).join(', '),
  teamBPlayers.map((p) => p.name).join(', '),
  teamAScore,
  teamBScore,
  DateTime.now().toIso8601String(),
);


  await LocalStorageService.instance.insertGame(gameResult);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Round $currentRound / ${widget.totalRounds}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Team $currentTeam\'s turn',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Time left: $secondsLeft seconds',
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 16),

            WordCardWidget(
              word: currentWord,
              tabooWords: tabooWords,
              onCorrect: () => _handleRoundEnd(scoreChange: 1, taboo: false),
              onTaboo: () => _handleRoundEnd(scoreChange: -1, taboo: true),
              onSkip: _skipRound,
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Team A Score', style: TextStyle(fontSize: 16)),
                    Text(teamAScore.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Team B Score', style: TextStyle(fontSize: 16)),
                    Text(teamBScore.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                timer?.cancel();
                _showRoundEndDialog(reason: 'Round manually ended.');
              },
              child: const Text('End Round'),
            ),
          ],
        ),
      ),
    );
  }
}
