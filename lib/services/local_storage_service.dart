import 'package:hive/hive.dart';
import '../models/game_result.dart';
class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService._internal();
  LocalStorageService._internal();

  static const String boxName = 'game_history';
  late Box<GameResult> _box;

  Future<void> init() async {
    _box = Hive.box<GameResult>(boxName);
  }

  Future<void> insertGame(GameResult game) async {
    await _box.add(game);
  }
  Future<void> removeGameAt(int index) async {
  final box = Hive.box<GameResult>('game_results');
  await box.deleteAt(index);
}

Future<void> clearHistory() async {
  final box = Hive.box<GameResult>('game_results');
  await box.clear();
}


  List<GameResult> getHistory() {
    return _box.values.toList().reversed.toList();
  } 
}
