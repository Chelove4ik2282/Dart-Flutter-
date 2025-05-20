import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // Импортируем только HomePage
import 'pages/setup_page.dart';
import 'pages/game_page.dart'; // Убираем префикс
import 'pages/history_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/game_result.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(GameResultAdapter()); // Твой адаптер для GameResult

  await Hive.openBox<GameResult>('game_history');

  await LocalStorageService.instance.init();

  runApp(TabooGameApp());
}


class TabooGameApp extends StatelessWidget {
  const TabooGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taboo Game',
      theme: ThemeData(primarySwatch: Colors.purple),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/setup': (_) => const SetupPage(),
        '/game': (_) => const SetupPage(), // Вызываем SetupPage как дефолтный маршрут для начала
        '/history': (_) => const HistoryPage(),
      },
    );
  }
}
