import 'package:flutter/material.dart';
import '../data/mock_emis_repository.dart';
import '../models/models.dart';

// Единое состояние MVP: несколько детей в одном аккаунте,
// переключение в один клик, светлая/тёмная тема.
class AppState extends ChangeNotifier {
  final _repo = MockEmisRepository();

  late final List<Child> children;
  String _selectedChildId = '';
  ThemeMode _themeMode = ThemeMode.system;

  AppState() {
    children = _repo.getChildren();
    _selectedChildId = children.first.id;
  }

  Child get selectedChild =>
      children.firstWhere((c) => c.id == _selectedChildId);

  ThemeMode get themeMode => _themeMode;

  void selectChild(String id) {
    if (id == _selectedChildId) return;
    _selectedChildId = id;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  List<Grade> get grades => _repo.getGrades(_selectedChildId);
  Map<String, List<Lesson>> get schedule =>
      _repo.getWeekSchedule(_selectedChildId);
  List<Homework> get homework => _repo.getHomework(_selectedChildId);
  List<AppNotification> get notifications =>
      _repo.getNotifications(_selectedChildId);

  double get average {
    if (grades.isEmpty) return 0;
    final sum = grades.fold<int>(0, (p, g) => p + g.value);
    return sum / grades.length;
  }
}
