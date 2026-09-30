import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/glass_kit.dart';

// ---------- МОИ КЛАССЫ ----------
class TeacherClassesScreen extends StatelessWidget {
  const TeacherClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final classes = state.teacherClasses;
    final today = DateTime.now();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Row(
            children: [
              CircleAvatar(
                  radius: 26,
                  child: Text(state.parentName.isEmpty
                      ? 'У'
                      : state.parentName[0])),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.parentName,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('Учитель • классов: ${classes.length}',
                        style: TextStyle(
                            color: Theme.of(context).hintColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final tc in classes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ClassDetailScreen(classId: tc.id))),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 24, child: Text(tc.name.split(' ')[0])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Класс ${tc.name}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium),
                        Text(
                            '${tc.subject} • учеников: ${tc.students.length}',
                            style: TextStyle(
                                color: Theme.of(context).hintColor)),
                        Text(
                            'Сегодня: ${state.classPresentCount(tc.id, today)}/${tc.students.length} присутствуют',
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------- КЛАСС: посещаемость + оценки ----------
class ClassDetailScreen extends StatelessWidget {
  final String classId;
  const ClassDetailScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tc =
        state.teacherClasses.firstWhere((c) => c.id == classId);
    final today = DateTime.now();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('Класс ${tc.name}')),
      body: GlassBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Сегодня ${DateFormat('d MMM', 'ru').format(today)} • ${tc.subject}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                        'Присутствуют: ${state.classPresentCount(tc.id, today)} из ${tc.students.length}. Нажмите на статус, чтобы сменить: был → опоздал → отсутствует → болеет.'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final s in tc.students)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                            child: Text(s.firstName[0])),
                        const SizedBox(width: 10),
                        Expanded(child: Text(s.fullName)),
                        IconButton(
                          tooltip: 'Поставить оценку',
                          icon: const Icon(Icons.grade_outlined),
                          onPressed: () => _gradeDialog(
                              context, state, tc, s),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => state.cycleMark(
                              tc.id, s.id, today),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: attendanceColor(
                                      state.classStatus(
                                          tc.id, s.id, today),
                                      context)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                    attendanceIcon(state.classStatus(
                                        tc.id, s.id, today)),
                                    size: 18,
                                    color: attendanceColor(
                                        state.classStatus(
                                            tc.id, s.id, today),
                                        context)),
                                const SizedBox(width: 4),
                                Text(
                                    attendanceLabel(state
                                        .classStatus(
                                            tc.id, s.id, today)),
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _gradeDialog(BuildContext context, AppState state,
      TeacherClass tc, Student s) {
    int value = 5;
    String subject = tc.subject;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(s.fullName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: subject,
                items: [tc.subject, 'Контрольная работа']
                    .map((e) => DropdownMenuItem(
                        value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) =>
                    setD(() => subject = v ?? subject),
                decoration:
                    const InputDecoration(labelText: 'Работа'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var v = 2; v <= 5; v++)
                    ChoiceChip(
                      label: Text('$v'),
                      selected: value == v,
                      onSelected: (_) => setD(() => value = v),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Отмена')),
            FilledButton(
              onPressed: () {
                state.addGrade(
                    childId: s.childId ?? s.id,
                    subject: subject,
                    value: value);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Оценка «$value» записана${s.childId == null ? ' в журнал класса' : ' и видна родителю'}')));
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- ЖУРНАЛ ----------
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String? _classId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final classes = state.teacherClasses;
    _classId ??= classes.first.id;
    final tc = classes.firstWhere((c) => c.id == _classId);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final c in classes)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${c.name} • ${c.subject}'),
                    selected: _classId == c.id,
                    onSelected: (_) =>
                        setState(() => _classId = c.id),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final s in tc.students)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(child: Text(s.firstName[0])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(s.fullName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        Text(
                          _journalLine(
                              state, s.childId ?? s.id),
                          style: TextStyle(
                              color:
                                  Theme.of(context).hintColor,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ..._lastBadges(state, s.childId ?? s.id),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _journalLine(AppState state, String id) {
    final list = state.studentGrades(id);
    if (list.isEmpty) return 'Оценок пока нет';
    final avg =
        list.fold<int>(0, (p, g) => p + g.value) / list.length;
    return 'Оценок: ${list.length} • сред: ${avg.toStringAsFixed(1)}';
  }

  List<Widget> _lastBadges(AppState state, String id) {
    final list = state.studentGrades(id);
    if (list.isEmpty) return [];
    final last = [...list]
      ..sort((a, b) => b.date.compareTo(a.date));
    return [
      for (final g in last.take(3))
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: GlassGradeBadge(value: g.value, size: 32),
        ),
    ];
  }
}

// ---------- ЗАДАНИЯ ----------
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  String? _classId;
  String? _subject;
  final _task = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _task.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final classes = state.teacherClasses;
    _classId ??= classes.first.id;
    final tc = classes.firstWhere((c) => c.id == _classId);
    _subject ??= tc.subject;
    if (![tc.subject, 'Другое'].contains(_subject)) {
      _subject = tc.subject;
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Новое задание',
                  style:
                      Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in classes)
                    ChoiceChip(
                      label: Text(c.name),
                      selected: _classId == c.id,
                      onSelected: (_) => setState(() {
                        _classId = c.id;
                        _subject = c.subject;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _subject,
                items: [tc.subject, 'Другое']
                    .map((e) => DropdownMenuItem(
                        value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _subject = v),
                decoration:
                    const InputDecoration(labelText: 'Предмет'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _task,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Текст задания',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Сдать: ${DateFormat('d MMM', 'ru').format(_due)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _due,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() => _due = picked);
                      }
                    },
                    child: const Text('Выбрать дату'),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_task.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Введите текст задания')));
                      return;
                    }
                    state.assignHomework(
                      className: tc.name,
                      subject: _subject ?? tc.subject,
                      task: _task.text.trim(),
                      due: _due,
                    );
                    _task.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Задано классу ${tc.name} — родители увидят в «Домашке»')));
                  },
                  child: const Text('Задать классу'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
