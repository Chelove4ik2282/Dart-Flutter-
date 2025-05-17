import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/word_card_widget.dart';
import '../widgets/score_modal.dart';


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
                _showGameOverDialog();
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
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

      // Удаляем текущее слово после использования
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
      currentRound++;
      currentTeam = currentTeam == 'A' ? 'B' : 'A';
      currentWordIndex = 0;
    });
    startTimer();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Round $currentRound/${widget.totalRounds}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Team $currentTeam',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Time left: $secondsLeft s',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                const SizedBox(height: 10),

                if (remainingWords.isNotEmpty)
                  WordCardWidget(
                    word: currentWord,
                    tabooWords: tabooWords,
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Team A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ...teamAPlayers.map((player) => Text(player.name, style: const TextStyle(color: Colors.white))),
                        Text('Score: $teamAScore', style: const TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Team B', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ...teamBPlayers.map((player) => Text(player.name, style: const TextStyle(color: Colors.white))),
                        Text('Score: $teamBScore', style: const TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _handleRoundEnd(scoreChange: 1, taboo: false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Next', style: TextStyle(fontSize: 18)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _skipRound();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      child: const Text('Skip', style: TextStyle(fontSize: 18)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _handleRoundEnd(scoreChange: 1, taboo: true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Taboo', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
