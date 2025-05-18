import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    _loadHistory();
  }

  void _loadHistory() {
    LocalStorageService.instance.init().then((_) {
      setState(() {
        _historyFuture = Future.value(LocalStorageService.instance.getHistory());
      });
    });
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  void showGameDetails(GameResult game) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${game.team1} vs ${game.team2}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${game.score1} : ${game.score2}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Date: ${formatDate(game.date)}'),
            if (game.winner != null) ...[
              const SizedBox(height: 8),
              Text('Winner: ${game.winner!}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
            if (game.roundsPlayed != null) ...[
              const SizedBox(height: 8),
              Text('Rounds Played: ${game.roundsPlayed}'),
            ],
            if (game.duration != null) ...[
              const SizedBox(height: 8),
              Text('Duration: ${game.duration} min'),
            ],
            if (game.team1Players != null && game.team2Players != null) ...[
              const SizedBox(height: 8),
              Text('Team 1 Players: ${game.team1Players!.join(", ")}'),
              Text('Team 2 Players: ${game.team2Players!.join(", ")}'),
            ],
            if (game.notes != null && game.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${game.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  void deleteGame(int index) async {
    await LocalStorageService.instance.removeGameAt(index);
    _loadHistory();
  }

  void clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('Are you sure you want to delete all game history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete All')),
        ],
      ),
    );

    if (confirm == true) {
      await LocalStorageService.instance.clearHistory();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        backgroundColor: const Color(0xFF3A0CA3),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All',
            onPressed: clearHistory,
          ),
        ],
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
              final isDraw = game.score1 == game.score2;
              final isTeam1Winner = game.score1 > game.score2;

              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 300 + index * 100),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: child,
                  ),
                ),
                child: Dismissible(
                  key: Key(game.date + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  onDismissed: (_) => deleteGame(index),
                  child: GestureDetector(
                    onTap: () => showGameDetails(game),
                    child: Card(
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: const Color(0xFFF9F9F9),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          '${game.team1} vs ${game.team2}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          '${game.score1} : ${game.score2}  •  ${formatDate(game.date)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        leading: const Icon(Icons.sports_esports, color: Color(0xFF3A0CA3), size: 32),
                        trailing: isDraw
                            ? const Icon(Icons.handshake, color: Colors.orange, size: 28)
                            : Icon(
                                Icons.emoji_events,
                                color: isTeam1Winner ? Colors.green : Colors.red,
                                size: 28,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
