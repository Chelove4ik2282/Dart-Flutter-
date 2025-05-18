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
  final String date; // сохраняем дату в виде строки

  GameResult(this.team1, this.team2, this.score1, this.score2, this.date);
}
