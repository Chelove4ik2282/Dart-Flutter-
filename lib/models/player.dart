class Player {
   String name;
   String team;

  Player({required this.name, required this.team});

  Player copyWith({String? name, String? team}) {
    return Player(
      name: name ?? this.name,
      team: team ?? this.team,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
