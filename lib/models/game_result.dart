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
  final String date;

  @HiveField(5)
  final String? winner;

  @HiveField(6)
  final int? roundsPlayed;

  @HiveField(7)
  final List<String>? team1Players;

  @HiveField(8)
  final List<String>? team2Players;

  @HiveField(9)
  final int? duration;

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final List<int>? team1RoundScores;

  @HiveField(12)
  final List<int>? team2RoundScores;

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
    this.team1RoundScores,
    this.team2RoundScores,
  });
} 