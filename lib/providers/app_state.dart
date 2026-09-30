import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_emis_repository.dart';
import '../models/models.dart';

// Единое состояние: вход, несколько детей в одном аккаунте,
// переключение в один клик, светлая/тёмная тема, фильтры, persistence.
class AppState extends ChangeNotifier {
  final _repo = MockEmisRepository();
  SharedPreferences? _prefs;

  late final List<Child> children;
  String _selectedChildId = '';
  ThemeMode _themeMode = ThemeMode.system;
  bool _loggedIn = false;
  String _parentName = '';

  String gradeTerm = 'Все';
  String gradeSubject = 'Все';
  String scheduleDay = '';
  String homeworkFilter = 'Все';

  final Set<String> _doneHomework = {};
  final Set<String> _readNotifications = {};

  AppState() {
    children = _repo.getChildren();
    _selectedChildId = children.first.id;
    scheduleDay = todayDayName;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    _loggedIn = p.getBool('logged_in') ?? false;
    _parentName = p.getString('parent_name') ?? '';
    _selectedChildId = p.getString('child_id') ?? children.first.id;
    if (!children.any((c) => c.id == _selectedChildId)) {
      _selectedChildId = children.first.id;
    }
    final theme = p.getString('theme') ?? 'system';
    _themeMode = theme == 'dark'
        ? ThemeMode.dark
        : theme == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    _doneHomework.addAll(p.getStringList('done_hw') ?? []);
    _readNotifications.addAll(p.getStringList('read_n') ?? []);
    notifyListeners();
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setBool('logged_in', _loggedIn);
    await p.setString('parent_name', _parentName);
    await p.setString('child_id', _selectedChildId);
    await p.setString(
        'theme',
        _themeMode == ThemeMode.dark
            ? 'dark'
            : _themeMode == ThemeMode.light
                ? 'light'
                : 'system');
    await p.setStringList('done_hw', _doneHomework.toList());
    await p.setStringList('read_n', _readNotifications.toList());
  }

  // --- auth ---
  bool get isLoggedIn => _loggedIn;
  String get parentName => _parentName;

  void login(String name) {
    _parentName = name.trim().isEmpty ? 'Родитель' : name.trim();
    _loggedIn = true;
    _save();
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    _save();
    notifyListeners();
  }

  // --- child ---
  Child get selectedChild =>
      children.firstWhere((c) => c.id == _selectedChildId);

  void selectChild(String id) {
    if (id == _selectedChildId) return;
    _selectedChildId = id;
    gradeSubject = 'Все';
    _save();
    notifyListeners();
  }

  // --- theme ---
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _save();
    notifyListeners();
  }

  // --- grades ---
  List<Grade> get grades => _repo.getGrades(_selectedChildId);

  List<String> get subjects =>
      grades.map((g) => g.subject).toSet().toList()..sort();

  List<Grade> get filteredGrades {
    var list = grades;
    if (gradeTerm != 'Все') {
      list = list.where((g) => g.term == gradeTerm).toList();
    }
    if (gradeSubject != 'Все') {
      list = list.where((g) => g.subject == gradeSubject).toList();
    }
    list = List.of(list)..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void setGradeTerm(String v) {
    gradeTerm = v;
    notifyListeners();
  }

  void setGradeSubject(String v) {
    gradeSubject = v;
    notifyListeners();
  }

  double get average {
    if (grades.isEmpty) return 0;
    final sum = grades.fold<int>(0, (p, g) => p + g.value);
    return sum / grades.length;
  }

  double subjectAverage(String subject) {
    final list = grades.where((g) => g.subject == subject).toList();
    if (list.isEmpty) return 0;
    return list.fold<int>(0, (p, g) => p + g.value) / list.length;
  }

  int countGrade(int value) =>
      grades.where((g) => g.value == value).length;

  // --- schedule ---
  static const weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];

  static String get todayDayName {
    final w = DateTime.now().weekday; // 1=Пн .. 7=Вс
    if (w >= 1 && w <= 5) return weekDays[w - 1];
    return weekDays[0];
  }

  Map<String, List<Lesson>> get schedule =>
      _repo.getWeekSchedule(_selectedChildId);

  List<Lesson> get dayLessons => schedule[scheduleDay] ?? [];

  List<Lesson> get todayLessons => schedule[todayDayName] ?? [];

  void setScheduleDay(String v) {
    scheduleDay = v;
    notifyListeners();
  }

  // --- homework ---
  List<Homework> get homework => _repo.getHomework(_selectedChildId);

  bool isDone(Homework h) => _doneHomework.contains('$_selectedChildId:${h.id}');

  void toggleHomework(Homework h) {
    final key = '$_selectedChildId:${h.id}';
    if (!_doneHomework.remove(key)) _doneHomework.add(key);
    _save();
    notifyListeners();
  }

  int get pendingHomework =>
      homework.where((h) => !isDone(h)).length;

  int get tomorrowHomework {
    final t = DateTime.now().add(const Duration(days: 1));
    return homework
        .where((h) =>
            !isDone(h) &&
            h.dueDate.year == t.year &&
            h.dueDate.month == t.month &&
            h.dueDate.day == t.day)
        .length;
  }

  List<Homework> get filteredHomework {
    switch (homeworkFilter) {
      case 'На завтра':
        final t = DateTime.now().add(const Duration(days: 1));
        return homework
            .where((h) =>
                h.dueDate.year == t.year &&
                h.dueDate.month == t.month &&
                h.dueDate.day == t.day)
            .toList();
      case 'Выполненные':
        return homework.where(isDone).toList();
      case 'Осталось':
        return homework.where((h) => !isDone(h)).toList();
      default:
        return homework;
    }
  }

  void setHomeworkFilter(String v) {
    homeworkFilter = v;
    notifyListeners();
  }

  // --- notifications ---
  List<AppNotification> get notifications =>
      _repo.getNotifications(_selectedChildId);

  bool isRead(AppNotification n) => _readNotifications.contains(n.id);

  int get unreadCount =>
      notifications.where((n) => !isRead(n)).length;

  void toggleRead(AppNotification n) {
    if (!_readNotifications.remove(n.id)) _readNotifications.add(n.id);
    _save();
    notifyListeners();
  }

  void markAllRead() {
    _readNotifications.addAll(notifications.map((n) => n.id));
    _save();
    notifyListeners();
  }
}
