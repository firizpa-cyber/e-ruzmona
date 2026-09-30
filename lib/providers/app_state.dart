import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_emis_repository.dart';
import '../models/models.dart';

String _dkey(DateTime d) => '${d.year}-${d.month}-${d.day}';

// Единое состояние: роли, дети, журнал учителя, цели,
// посещаемость, умные уведомления и инсайты, persistence.
class AppState extends ChangeNotifier {
  final _repo = MockEmisRepository();
  SharedPreferences? _prefs;

  late final List<Child> children;
  String _selectedChildId = '';
  ThemeMode _themeMode = ThemeMode.system;
  bool _loggedIn = false;
  String _parentName = '';
  UserRole _role = UserRole.parent;

  String gradeTerm = 'Все';
  String gradeSubject = 'Все';
  String scheduleDay = '';
  String homeworkFilter = 'Все';
  double _goal = 0;

  final Set<String> _doneHomework = {};
  final Set<String> _readNotifications = {};
  final Map<String, String> _attOverrides = {}; // childId:dkey -> status
  final List<String> _extraGrades = []; // childId|subject|value|dkey|term
  final List<String> _extraHomework = []; // className|subject|task|dkey
  final Map<String, String> _teacherMarks = {}; // classId:dkey:studentId -> status

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
    _role = (p.getString('role') ?? 'parent') == 'teacher'
        ? UserRole.teacher
        : UserRole.parent;
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
    _goal = p.getDouble('goal') ?? 0;
    _doneHomework.addAll(p.getStringList('done_hw') ?? []);
    _readNotifications.addAll(p.getStringList('read_n') ?? []);
    _extraGrades.addAll(p.getStringList('extra_grades') ?? []);
    _extraHomework.addAll(p.getStringList('extra_hw') ?? []);
    for (final e in p.getStringList('att_over') ?? []) {
      final parts = e.split('|');
      if (parts.length == 3) _attOverrides['${parts[0]}:${parts[1]}'] = parts[2];
    }
    for (final e in p.getStringList('tch_marks') ?? []) {
      final parts = e.split('|');
      if (parts.length == 4) {
        _teacherMarks['${parts[0]}:${parts[1]}:${parts[2]}'] = parts[3];
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setBool('logged_in', _loggedIn);
    await p.setString('parent_name', _parentName);
    await p.setString(
        'role', _role == UserRole.teacher ? 'teacher' : 'parent');
    await p.setString('child_id', _selectedChildId);
    await p.setString(
        'theme',
        _themeMode == ThemeMode.dark
            ? 'dark'
            : _themeMode == ThemeMode.light
                ? 'light'
                : 'system');
    await p.setDouble('goal', _goal);
    await p.setStringList('done_hw', _doneHomework.toList());
    await p.setStringList('read_n', _readNotifications.toList());
    await p.setStringList('extra_grades', _extraGrades);
    await p.setStringList('extra_hw', _extraHomework);
    await p.setStringList(
        'att_over',
        _attOverrides.entries
            .map((e) => '${e.key.split(':')[0]}|${e.key.split(':')[1]}|${e.value}')
            .toList());
    await p.setStringList(
        'tch_marks',
        _teacherMarks.entries
            .map((e) {
              final k = e.key.split(':');
              return '${k[0]}|${k[1]}|${k[2]}|${e.value}';
            })
            .toList());
  }

  // --- auth + role ---
  bool get isLoggedIn => _loggedIn;
  String get parentName => _parentName;
  UserRole get role => _role;
  bool get isTeacher => _role == UserRole.teacher;

  void login(String name, {UserRole role = UserRole.parent}) {
    _parentName = name.trim().isEmpty ? 'Родитель' : name.trim();
    _role = role;
    _loggedIn = true;
    _save();
    notifyListeners();
  }

  void switchRole(UserRole r) {
    _role = r;
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

  // --- goal ---
  double get goal => _goal;
  void setGoal(double v) {
    _goal = v;
    _save();
    notifyListeners();
  }

  // --- grades (mock + оценки учителя) ---
  List<Grade> get grades {
    final base = _repo.getGrades(_selectedChildId);
    final extras = <Grade>[];
    for (final e in _extraGrades) {
      final parts = e.split('|');
      if (parts.length == 5 && parts[0] == _selectedChildId) {
        final dp = parts[3].split('-').map(int.parse).toList();
        extras.add(Grade(
          subject: parts[1],
          value: int.parse(parts[2]),
          date: DateTime(dp[0], dp[1], dp[2]),
          term: parts[4],
        ));
      }
    }
    return [...base, ...extras];
  }

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

  /// Динамика среднего балла по неделям сентября (для графика).
  List<double> get weeklyTrend {
    final buckets = <List<int>>[[], [], [], []];
    for (final g in grades.where((e) => e.date.month == 9)) {
      final b = ((g.date.day - 1) / 7).floor().clamp(0, 3);
      buckets[b].add(g.value);
    }
    return [
      for (final b in buckets)
        b.isEmpty
            ? 0
            : b.reduce((a, c) => a + c) / b.length
    ];
  }

  /// Текстовая сводка-табель для «Поделиться».
  String shareReport() {
    final c = selectedChild;
    final sb = StringBuffer()
      ..writeln('E-Ruznoma • Табель')
      ..writeln('${c.fullName}, ${c.schoolClass}')
      ..writeln('Средний балл: ${average.toStringAsFixed(2)}');
    for (final s in subjects) {
      sb.writeln('$s — ${subjectAverage(s).toStringAsFixed(1)}');
    }
    sb.writeln('Посещаемость: ${attendancePercent.toStringAsFixed(0)}%');
    return sb.toString();
  }

  // --- schedule ---
  static const weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];

  static String get todayDayName {
    final w = DateTime.now().weekday;
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

  /// Урок, который идёт прямо сейчас (по времени звонков), либо null.
  Lesson? get currentLesson {
    if (todayLessons.isEmpty) return null;
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    for (final l in todayLessons) {
      final parts = l.time.split('–');
      if (parts.length != 2) continue;
      int toMin(String t) {
        final p = t.split(':');
        return int.parse(p[0]) * 60 + int.parse(p[1]);
      }

      try {
        if (nowMin >= toMin(parts[0]) && nowMin <= toMin(parts[1])) {
          return l;
        }
      } catch (_) {}
    }
    return null;
  }

  // --- homework (mock + задания учителя) ---
  List<Homework> get homework {
    final base = _repo.getHomework(_selectedChildId);
    final extras = <Homework>[];
    final cls = selectedChild.schoolClass;
    for (final e in _extraHomework) {
      final parts = e.split('|');
      if (parts.length == 4 && parts[0] == cls) {
        final dp = parts[3].split('-').map(int.parse).toList();
        extras.add(Homework(
          id: 'x${extras.length}',
          subject: parts[1],
          task: parts[2],
          dueDate: DateTime(dp[0], dp[1], dp[2]),
        ));
      }
    }
    return [...base, ...extras];
  }

  bool isDone(Homework h) =>
      _doneHomework.contains('$_selectedChildId:${h.id}');

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

  // --- attendance (parent) ---
  List<AttendanceRecord> get attendance {
    final base = _repo.getAttendance(_selectedChildId);
    return [
      for (final r in base)
        AttendanceRecord(
          childId: r.childId,
          date: r.date,
          status: _attOverrides['$_selectedChildId:${_dkey(r.date)}'] ??
              r.status,
        ),
    ];
  }

  double get attendancePercent {
    final a = attendance;
    if (a.isEmpty) return 100;
    final present =
        a.where((r) => r.status == 'present' || r.status == 'late').length;
    return present * 100 / a.length;
  }

  int get absenceCount =>
      attendance.where((r) => r.status == 'absent').length;

  // --- events ---
  List<SchoolEvent> get events => _repo.getEvents();

  List<SchoolEvent> get upcomingEvents {
    final now = DateTime.now().subtract(const Duration(days: 1));
    final list = events.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  // --- teacher ---
  List<TeacherClass> get teacherClasses => _repo.getTeacherClasses();

  String classStatus(String classId, String studentId, DateTime date) =>
      _teacherMarks['$classId:${_dkey(date)}:$studentId'] ?? 'present';

  void cycleMark(String classId, String studentId, DateTime date) {
    const order = ['present', 'late', 'absent', 'sick'];
    final key = '$classId:${_dkey(date)}:$studentId';
    final cur = _teacherMarks[key] ?? 'present';
    _teacherMarks[key] =
        order[(order.indexOf(cur) + 1) % order.length];
    // Если ученик связан с ребёнком родителя — отражаем и там.
    for (final tc in teacherClasses) {
      if (tc.id != classId) continue;
      for (final s in tc.students) {
        if (s.id == studentId && s.childId != null) {
          _attOverrides['${s.childId}:${_dkey(date)}'] =
              _teacherMarks[key]!;
        }
      }
    }
    _save();
    notifyListeners();
  }

  int classPresentCount(String classId, DateTime date) {
    final tc = teacherClasses.firstWhere((c) => c.id == classId);
    return tc.students
        .where((s) {
          final st = classStatus(classId, s.id, date);
          return st == 'present' || st == 'late';
        })
        .length;
  }

  void addGrade(
      {required String childId,
      required String subject,
      required int value}) {
    final now = DateTime.now();
    _extraGrades.add(
        '$childId|$subject|$value|${_dkey(now)}|I четверть');
    _save();
    notifyListeners();
  }

  /// Оценки ученика по id (для журнала учителя; включает незарегистрированных).
  List<Grade> studentGrades(String id) {
    final out = <Grade>[];
    if (children.any((c) => c.id == id)) {
      out.addAll(_repo.getGrades(id));
    }
    for (final e in _extraGrades) {
      final parts = e.split('|');
      if (parts.length == 5 && parts[0] == id) {
        final dp = parts[3].split('-').map(int.parse).toList();
        out.add(Grade(
          subject: parts[1],
          value: int.parse(parts[2]),
          date: DateTime(dp[0], dp[1], dp[2]),
          term: parts[4],
        ));
      }
    }
    return out;
  }

  void assignHomework(
      {required String className,
      required String subject,
      required String task,
      required DateTime due}) {
    _extraHomework.add('$className|$subject|$task|${_dkey(due)}');
    _save();
    notifyListeners();
  }

  // --- smart notifications + insights ---
  List<AppNotification> get notifications {
    final base = _repo.getNotifications(_selectedChildId);
    final smart = <AppNotification>[];
    final now = DateTime.now();
    final morning = DateTime(now.year, now.month, now.day, 8, 0);

    smart.add(AppNotification(
      id: 's-briefing',
      title: 'Утренний брифинг',
      body:
          'Сегодня ${todayLessons.length} ур., несделанной домашки: $pendingHomework, средний балл ${average.toStringAsFixed(2)}.',
      createdAt: morning,
      smart: true,
    ));
    if (pendingHomework > 0) {
      smart.add(AppNotification(
        id: 's-hw',
        title: 'Напоминание о домашке',
        body:
            'Осталось $pendingHomework зад., из них на завтра: $tomorrowHomework. Не откладывайте на вечер!',
        createdAt: morning.add(const Duration(hours: 10)),
        smart: true,
      ));
    }
    final recent = filteredGrades.take(5).toList();
    if (recent.isNotEmpty && recent.first.value == 5) {
      smart.add(AppNotification(
        id: 's-praise',
        title: 'Так держать! 🎉',
        body:
            'Последняя оценка — «5» по предмету ${recent.first.subject}. Похвалите ребёнка!',
        createdAt: morning.add(const Duration(hours: 6)),
        smart: true,
      ));
    }
    final bad = recent.where((g) => g.value <= 3).toList();
    if (bad.isNotEmpty) {
      smart.add(AppNotification(
        id: 's-alert',
        title: 'Предмет требует внимания',
        body:
            '«${bad.first.value}» по предмету ${bad.first.subject}. Загляните в раздел «Оценки».',
        createdAt: morning.add(const Duration(hours: 7)),
        smart: true,
      ));
    }
    if (absenceCount > 0) {
      smart.add(AppNotification(
        id: 's-att',
        title: 'Пропуски без причины: $absenceCount',
        body:
            'Посещаемость ${attendancePercent.toStringAsFixed(0)}%. Проверьте ленту посещаемости.',
        createdAt: morning.add(const Duration(hours: 9)),
        smart: true,
      ));
    }
    if (_goal > 0) {
      final left = _goal - average;
      smart.add(AppNotification(
        id: 's-goal',
        title: left <= 0
            ? 'Цель достигнута! 🏆'
            : 'До цели ${_goal.toStringAsFixed(1)} осталось ${left.toStringAsFixed(2)}',
        body: left <= 0
            ? 'Средний балл ${average.toStringAsFixed(2)} — выше цели. Поставьте новую!'
            : 'Текущий средний балл ${average.toStringAsFixed(2)}.',
        createdAt: morning.add(const Duration(hours: 11)),
        smart: true,
      ));
    }
    final all = [...base, ...smart];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

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

  /// Умная сводка недели для дашборда.
  List<SmartInsight> get insights {
    final out = <SmartInsight>[];
    final trend = weeklyTrend.where((v) => v > 0).toList();
    if (trend.length >= 2) {
      final diff = trend.last - trend.first;
      out.add(SmartInsight(
        icon: diff >= 0 ? 'trend_up' : 'trend_down',
        title: diff >= 0 ? 'Балл растёт' : 'Балл снижается',
        text:
            'Динамика за месяц: ${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(2)} к среднему баллу.',
        good: diff >= 0,
      ));
    }
    if (subjects.isNotEmpty) {
      var best = subjects.first;
      var worst = subjects.first;
      for (final s in subjects) {
        if (subjectAverage(s) > subjectAverage(best)) best = s;
        if (subjectAverage(s) < subjectAverage(worst)) worst = s;
      }
      out.add(SmartInsight(
        icon: 'star',
        title: 'Сильная сторона — $best',
        text: 'Средний балл ${subjectAverage(best).toStringAsFixed(1)}.',
        good: true,
      ));
      if (worst != best) {
        out.add(SmartInsight(
          icon: 'focus',
          title: 'Фокус недели — $worst',
          text:
              'Средний балл ${subjectAverage(worst).toStringAsFixed(1)}. 20 минут повторения в день исправят ситуацию.',
          good: false,
        ));
      }
    }
    out.add(SmartInsight(
      icon: 'attendance',
      title: 'Посещаемость ${attendancePercent.toStringAsFixed(0)}%',
      text: absenceCount == 0
          ? 'Без пропусков за последние 20 учебных дней. Отлично!'
          : 'Пропусков: $absenceCount за последние 20 учебных дней.',
      good: absenceCount == 0,
    ));
    return out;
  }
}
