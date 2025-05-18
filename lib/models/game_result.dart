import 'package:hive/hive.dart';

part 'game_result.g.dart';

@HiveType(typeId: 0)
class GameResult {
  @HiveField(0)
  final String team1;

  @HiveField(1)
  final String team2;

  @HiveField(2)
  final int score1;

  @HiveField(3)
  final int score2;

  @HiveField(4)
  final String date; // Дата в виде строки (ISO)

  @HiveField(5)
  final String? winner; // Победитель или null при ничьей

  @HiveField(6)
  final int? roundsPlayed; // Количество раундов

  @HiveField(7)
  final List<String>? team1Players; // Игроки команды 1

  @HiveField(8)
  final List<String>? team2Players; // Игроки команды 2

  @HiveField(9)
  final int? duration; // Продолжительность игры в минутах

  @HiveField(10)
  final String? notes; // Заметки к игре

  GameResult(
    this.team1,
    this.team2,
    this.score1,
    this.score2,
    this.date, {
    this.winner,
    this.roundsPlayed,
    this.team1Players,
    this.team2Players,
    this.duration,
    this.notes,
  });
}
