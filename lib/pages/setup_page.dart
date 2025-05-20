import 'package:flutter/material.dart';
import '../models/player.dart';
import 'game_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final List<Player> players = [];
  final TextEditingController nameController = TextEditingController();
  String selectedTeam = 'A';
  int rounds = 3;

  void _addPlayer() {
    final name = nameController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        players.add(Player(name: name, team: selectedTeam));
        nameController.clear();
      });
    }
  }

  void _startGame() {
    if (players.length < 2) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeGamePage(
          players: players,
          totalRounds: rounds,
        ),
      ),
    );
  }

  void _movePlayer(Player player, String newTeam) {
    setState(() {
      final index = players.indexOf(player);
      if (index != -1) {
        players[index] = player.copyWith(team: newTeam);
      }
    });
  }

  Widget buildTeamColumn(String team, Color color) {
    final teamPlayers = players.where((p) => p.team == team).toList();

    return Expanded(
      child: DragTarget<Player>(
        onWillAcceptWithDetails: (details) => details.data.team != team,
        onAccept: (player) => _movePlayer(player, team),
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'Team $team',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                ...teamPlayers.map((p) => Draggable<Player>(
                      data: p,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.4,
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(p.name),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(p.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() => players.remove(p)),
                        ),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Setup',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A0CA3), Color(0xFF4361EE), Color(0xFF4CC9F0)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Player name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedTeam,
                  items: const [
                    DropdownMenuItem(value: 'A', child: Text('Team A 🟥')),
                    DropdownMenuItem(value: 'B', child: Text('Team B 🟦')),
                  ],
                  onChanged: (val) => setState(() => selectedTeam = val!),
                ),
                IconButton(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.add_circle, size: 30, color: Colors.deepPurple),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Teams Columns
            Expanded(
              child: Row(
                children: [
                  buildTeamColumn('A', Colors.red),
                  const SizedBox(width: 8),
                  buildTeamColumn('B', Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Round selection and Start button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Rounds: ', style: TextStyle(fontSize: 16, color: Colors.white)),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: rounds,
                      dropdownColor: Colors.deepPurple[200],
                      items: List.generate(10, (i) => i + 1)
                          .map((r) => DropdownMenuItem(value: r, child: Text('$r')))
                          .toList(),
                      onChanged: (val) => setState(() => rounds = val!),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Game', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
