// lib/controllers/game_controller.dart

import 'dart:async';
import 'dart:math';
import '../data/word_data.dart';

class GameController {
  final int roundDuration; // в секундах
  late List<Map<String, dynamic>> _words;
  int currentWordIndex = 0;
  Timer? timer;
  int secondsLeft;

  Function()? onTimeUp;
  Function()? onWin;
  Function(int)? onTick;

  GameController({this.roundDuration = 60}) : secondsLeft = 60 {
    resetWords();
  }

  // ✅ Добавляем геттер totalDurationSeconds
  int get totalDurationSeconds => roundDuration;

  void resetWords() {
    _words = List<Map<String, dynamic>>.from(allWords)..shuffle(Random());
    currentWordIndex = 0;
  }

  Map<String, dynamic> get currentWordMap => _words[currentWordIndex];
  String get currentWord => currentWordMap['word'];
  List<String> get tabooWords => List<String>.from(currentWordMap['taboo']);

  void startTimer() {
    timer?.cancel();
    secondsLeft = roundDuration;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      secondsLeft--;
      onTick?.call(secondsLeft);
      if (secondsLeft <= 0) {
        stopTimer();
        onTimeUp?.call();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void nextWord() {
    if (_words.length == 1) {
      stopTimer();
      onWin?.call(); // Все слова угаданы
    } else {
      _words.removeAt(currentWordIndex);
      currentWordIndex = 0;
    }
  }

  bool hasWords() => _words.isNotEmpty;
}
