import 'package:flutter/material.dart';
import '../models/game_result.dart';
import '../services/local_storage_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<GameResult>> _historyFuture;

  @override 
void initState() {
  super.initState();
  // Сначала инициализируем сервис
  LocalStorageService.instance.init().then((_) {
    setState(() {
      _historyFuture = Future.value(LocalStorageService.instance.getHistory());
    });
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        backgroundColor: const Color(0xFF3A0CA3),
      ),
      body: FutureBuilder<List<GameResult>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No games played yet.'));
          }

          final history = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final game = history[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text('${game.team1} vs ${game.team2}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${game.score1} : ${game.score2} • ${game.date}'),
                  leading: const Icon(Icons.sports_esports),
                  trailing: game.score1 > game.score2
                      ? const Icon(Icons.emoji_events, color: Colors.green)
                      : game.score1 < game.score2
                          ? const Icon(Icons.emoji_events, color: Colors.red)
                          : const Icon(Icons.handshake, color: Colors.orange),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
