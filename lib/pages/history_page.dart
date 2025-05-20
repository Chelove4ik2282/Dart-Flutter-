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

  Widget _buildScoreList(String teamName, List<int>? scores, Color color) {
    if (scores == null || scores.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$teamName Round Scores:',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: List.generate(
            scores.length,
            (i) => Chip(
              label: Text('R${i + 1}: ${scores[i]}'),
              backgroundColor: color.withOpacity(0.15),
              labelStyle: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 13),
              elevation: 2,
              shadowColor: color.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(icon, color: Colors.deepPurple.shade400, size: 22),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepPurple.shade700)),
          ],
        ),
        const SizedBox(height: 10),
        ...children.map((child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: child,
            )),
      ],
    );
  }

  void showGameDetails(GameResult game) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxHeight: 520, maxWidth: 400),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text('${game.team1}  vs  ${game.team2}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                letterSpacing: 0.8)),
                      ),
                      const SizedBox(height: 14),
                      _buildDetailSection("Summary", Icons.bar_chart, [
                        Text('Score: ${game.score1} : ${game.score2}',
                            style: const TextStyle(fontSize: 16)),
                        Text('Date: ${formatDate(game.date)}',
                            style: const TextStyle(fontSize: 16)),
                        if (game.winner != null)
                          Text('Winner: ${game.winner!}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        if (game.roundsPlayed != null)
                          Text('Rounds Played: ${game.roundsPlayed}',
                              style: const TextStyle(fontSize: 16)),
                      ]),
                      if (game.team1Players != null && game.team2Players != null)
                        _buildDetailSection("Players", Icons.people_alt, [
                          Text('Team A: ${game.team1Players!.join(", ")}',
                              style: const TextStyle(fontSize: 15)),
                          Text('Team B: ${game.team2Players!.join(", ")}',
                              style: const TextStyle(fontSize: 15)),
                        ]),
                      if (game.notes != null && game.notes!.isNotEmpty)
                        _buildDetailSection("Notes", Icons.note_alt_outlined, [
                          Text(game.notes!, style: const TextStyle(fontSize: 15)),
                        ]),
                      _buildDetailSection("Round Scores", Icons.scoreboard, [
                        _buildScoreList(game.team1, game.team1RoundScores, Colors.blue),
                        const SizedBox(height: 8),
                        _buildScoreList(
                            game.team2, game.team2RoundScores, Colors.deepOrange),
                      ]),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 28, color: Colors.deepPurple),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                  splashRadius: 24,
                ),
              ),
            ],
          ),
        ),
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
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete All',
                style: TextStyle(color: Colors.redAccent),
              )),
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
    final primaryColor = const Color(0xFF3A0CA3);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFA),
      appBar: AppBar(
        title: const Text(
          'Game History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 8,
        shadowColor: primaryColor.withOpacity(0.6),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear All',
            onPressed: clearHistory,
            splashRadius: 24,
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
      ),
      body: FutureBuilder<List<GameResult>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3A0CA3)));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No games played yet.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54)));
          }

          final history = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final game = history[index];
              final isDraw = game.score1 == game.score2;
              final isTeam1Winner = game.score1 > game.score2;

              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 400 + index * 90),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 18),
                    child: child,
                  ),
                ),
                child: GestureDetector(
                  onTap: () => showGameDetails(game),
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    shadowColor: primaryColor.withOpacity(0.3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.deepPurple.shade50.withOpacity(0.4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        title: Text(
                          '${game.team1}  vs  ${game.team2}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: primaryColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        subtitle: Text(
                          '${game.score1} : ${game.score2}  •  ${formatDate(game.date)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.8),
                                primaryColor.withOpacity(0.5),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.sports_esports,
                              color: Colors.white, size: 30),
                        ),
                        trailing: isDraw
                            ? Tooltip(
                                message: 'Draw',
                                child: const Icon(Icons.handshake,
                                    color: Colors.orange, size: 28),
                              )
                            : Tooltip(
                                message: isTeam1Winner
                                    ? '${game.team1} won'
                                    : '${game.team2} won',
                                child: Icon(
                                  Icons.emoji_events,
                                  color: isTeam1Winner
                                      ? Colors.blue
                                      : Colors.deepOrange,
                                  size: 28,
                                ),
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
