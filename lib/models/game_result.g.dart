// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameResultAdapter extends TypeAdapter<GameResult> {
  @override
  final int typeId = 0;

  @override
  GameResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameResult(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
      fields[3] as int,
      fields[4] as String,
      winner: fields[5] as String?,
      roundsPlayed: fields[6] as int?,
      team1Players: (fields[7] as List?)?.cast<String>(),
      team2Players: (fields[8] as List?)?.cast<String>(),
      duration: fields[9] as int?,
      notes: fields[10] as String?,
      team1RoundScores: (fields[11] as List?)?.cast<int>(),
      team2RoundScores: (fields[12] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, GameResult obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.team1)
      ..writeByte(1)
      ..write(obj.team2)
      ..writeByte(2)
      ..write(obj.score1)
      ..writeByte(3)
      ..write(obj.score2)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.winner)
      ..writeByte(6)
      ..write(obj.roundsPlayed)
      ..writeByte(7)
      ..write(obj.team1Players)
      ..writeByte(8)
      ..write(obj.team2Players)
      ..writeByte(9)
      ..write(obj.duration)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.team1RoundScores)
      ..writeByte(12)
      ..write(obj.team2RoundScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
