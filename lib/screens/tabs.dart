import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/glass_kit.dart';

// ---------- ГЛАВНАЯ ----------
class DashboardScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Доброй ночи';
    if (h < 12) return 'Доброе утро';
    if (h < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  IconData _insightIcon(String key) {
    switch (key) {
      case 'trend_up':
        return Icons.trending_up;
      case 'trend_down':
        return Icons.trending_down;
      case 'star':
        return Icons.star_outline;
      case 'focus':
        return Icons.center_focus_strong_outlined;
      default:
        return Icons.event_available_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.selectedChild;
    final recent = state.filteredGrades.take(3).toList();
    final today = state.todayLessons;
    final live = state.currentLesson;
    final trend = state.weeklyTrend.where((v) => v > 0).toList();
    final events = state.upcomingEvents.take(2).toList();
    final att = state.attendance.take(7).toList().reversed.toList();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Приветствие + средний балл
        SolidCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_greeting()}, ${state.parentName}!',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('${child.fullName} • ${child.schoolClass}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor)),
              const SizedBox(height: 12),
              Row(
                children: [
                  GlassRing(
                      progress: (state.average - 2) / 3,
                      center: state.average.toStringAsFixed(2)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Средний балл'),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (var v = 5; v >= 2; v--)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('«$v»: ${state.countGrade(v)}',
                                    style: const TextStyle(fontSize: 12)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Live-урок
        if (live != null) ...[
          const SizedBox(height: 12),
          SolidCard(
            onTap: () => onNavigate(2),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Сейчас идёт урок',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('${live.subject} • ${live.time}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                Text('каб. ${live.room}'),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        SectionTitle(
            title: 'Сегодня (${AppState.todayDayName})',
            actionLabel: 'Расписание',
            onAction: () => onNavigate(2)),
        if (today.isEmpty)
          const EmptyState(text: 'Сегодня уроков нет')
        else
          SolidCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                for (final l in today)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                        radius: 18, child: Text('${l.order}')),
                    title: Text(l.subject),
                    trailing: Text(l.time,
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12)),
                    onTap: () => onNavigate(2),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SectionTitle(
            title: 'Умная сводка',
            actionLabel: 'Оценки',
            onAction: () => onNavigate(1)),
        for (final ins in state.insights)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SolidCard(
              child: Row(
                children: [
                  Icon(_insightIcon(ins.icon),
                      color: ins.good
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ins.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        Text(ins.text,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (trend.length >= 2) ...[
          const SizedBox(height: 4),
          SolidCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Динамика балла по неделям',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TrendChart(
                    points: trend,
                    labels: const ['1 сен', '2 сен', '3 сен', '4 сен']),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        SectionTitle(
            title: 'Посещаемость: ${state.attendancePercent.toStringAsFixed(0)}%',
            actionLabel: 'Вся лента',
            onAction: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AttendanceScreen()))),
        SolidCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AttendanceScreen())),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final r in att)
                Column(
                  children: [
                    Icon(attendanceIcon(r.status),
                        color: attendanceColor(r.status, context),
                        size: 26),
                    const SizedBox(height: 4),
                    Text('${r.date.day}.${r.date.month}',
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionTitle(
            title: 'Домашка: осталось ${state.pendingHomework}',
            actionLabel: 'Открыть',
            onAction: () => onNavigate(3)),
        SolidCard(
          onTap: () => onNavigate(3),
          child: Row(
            children: [
              Icon(Icons.home_work_outlined,
                  color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.tomorrowHomework == 0
                      ? 'На завтра ничего не задано'
                      : 'На завтра: ${state.tomorrowHomework} зад.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionTitle(
            title: 'Ближайшие события',
            actionLabel: 'Все',
            onAction: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const EventsScreen()))),
        if (events.isEmpty)
          const EmptyState(text: 'Событий нет')
        else
          for (final e in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SolidCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const EventsScreen())),
                child: Row(
                  children: [
                    CircleAvatar(child: Text('${e.date.day}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium),
                          Text(
                              '${DateFormat('d MMM HH:mm', 'ru').format(e.date)} • ${e.place}',
                              style: TextStyle(
                                  color: Theme.of(context).hintColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 12),
        SectionTitle(
            title: 'Последние оценки',
            actionLabel: 'Все оценки',
            onAction: () => onNavigate(1)),
        if (recent.isEmpty)
          const EmptyState(text: 'Оценок пока нет')
        else
          for (final g in recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SolidCard(
                onTap: () => onNavigate(1),
                child: Row(
                  children: [
                    GlassGradeBadge(value: g.value, size: 42),
                    const SizedBox(width: 12),
                    Expanded(child: Text(g.subject)),
                    Text(DateFormat('d MMM', 'ru').format(g.date),
                        style: TextStyle(
                            color: Theme.of(context).hintColor)),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

// ---------- ОЦЕНКИ ----------
class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final grades = state.filteredGrades;
    const terms = ['Все', 'I четверть', 'II четверть'];
    const goals = [0.0, 4.0, 4.5, 5.0];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SolidCard(
          child: Row(
            children: [
              GlassRing(
                  progress: (state.average - 2) / 3,
                  center: state.average.toStringAsFixed(2)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Средний балл',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                        '«5»: ${state.countGrade(5)}  «4»: ${state.countGrade(4)}  «3»: ${state.countGrade(3)}  «2»: ${state.countGrade(2)}'),
                    TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(
                            text: state.shareReport()));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Табель скопирован — можно отправить')));
                        }
                      },
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Поделиться табелем'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SolidCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Цель по баллу',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (state.goal > 0)
                    Text(state.average >= state.goal ? '🏆' : '🎯',
                        style: const TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final g in goals)
                    ChoiceChip(
                      label: Text(g == 0 ? 'Нет' : g.toStringAsFixed(1)),
                      selected: state.goal == g,
                      onSelected: (_) => state.setGoal(g),
                    ),
                ],
              ),
              if (state.goal > 0) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value:
                        ((state.average - 2) / (state.goal - 2)).clamp(0.0, 1.0),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.average >= state.goal
                      ? 'Цель достигнута! Поставьте новую.'
                      : 'До цели осталось ${(state.goal - state.average).toStringAsFixed(2)}',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SolidCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Среднее по предметам',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final s in state.subjects)
                _SubjectBar(
                    subject: s, average: state.subjectAverage(s)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final t in terms)
              ChoiceChip(
                label: Text(t),
                selected: state.gradeTerm == t,
                onSelected: (_) => state.setGradeTerm(t),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Все предметы'),
                  selected: state.gradeSubject == 'Все',
                  onSelected: (_) => state.setGradeSubject('Все'),
                ),
              ),
              for (final s in state.subjects)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: state.gradeSubject == s,
                    onSelected: (_) => state.setGradeSubject(s),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (grades.isEmpty)
          const EmptyState(text: 'В этой четверти оценок нет')
        else
          for (final g in grades)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SolidCard(
                child: Row(
                  children: [
                    GlassGradeBadge(value: g.value),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.subject,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium),
                          Text(
                            '${DateFormat('d MMM yyyy', 'ru').format(g.date)} • ${g.term}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color:
                                        Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _SubjectBar extends StatelessWidget {
  final String subject;
  final double average;
  const _SubjectBar({required this.subject, required this.average});

  @override
  Widget build(BuildContext context) {
    final progress = ((average - 2) / 3).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(subject)),
              Text(average.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- РАСПИСАНИЕ ----------
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final days = state.schedule.keys.toList();
    final lessons = state.dayLessons;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final d in days)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(d),
                    selected: state.scheduleDay == d,
                    onSelected: (_) => state.setScheduleDay(d),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (lessons.isEmpty)
          const EmptyState(text: 'В этот день уроков нет')
        else
          for (final l in lessons)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SolidCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        radius: 22, child: Text('${l.order}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.subject,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium),
                          Text('${l.time} • каб. ${l.room}'),
                          Text(l.teacher,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).hintColor)),
                          if (l.homework != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.home_work_outlined,
                                      size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                      child: Text('Д/з: ${l.homework}')),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

// ---------- ДОМАШКА ----------
class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    const filters = ['Все', 'На завтра', 'Осталось', 'Выполненные'];
    final list = state.filteredHomework;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SolidCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Осталось: ${state.pendingHomework}',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('На завтра: ${state.tomorrowHomework}',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final f in filters)
              ChoiceChip(
                label: Text(f),
                selected: state.homeworkFilter == f,
                onSelected: (_) => state.setHomeworkFilter(f),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          const EmptyState(text: 'Заданий нет — можно отдыхать!')
        else
          for (final h in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SolidCard(
                child: Row(
                  children: [
                    Checkbox(
                      value: state.isDone(h),
                      onChanged: (_) => state.toggleHomework(h),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.subject,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    decoration: state.isDone(h)
                                        ? TextDecoration.lineThrough
                                        : null,
                                  )),
                          Text(h.task),
                          Text(
                            'Сдать: ${DateFormat('d MMM', 'ru').format(h.dueDate)}',
                            style: TextStyle(
                                color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

// ---------- ПОСЕЩАЕМОСТЬ (родитель) ----------
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.attendance;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Посещаемость')),
      body: GlassBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              SolidCard(
                child: Row(
                  children: [
                    GlassRing(
                        progress: state.attendancePercent / 100,
                        center:
                            '${state.attendancePercent.toStringAsFixed(0)}%'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Присутствие',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium),
                          Text(
                              '20 учебных дней • пропусков: ${state.absenceCount}'),
                          Text(
                              '${state.selectedChild.fullName} • ${state.selectedChild.schoolClass}',
                              style: TextStyle(
                                  color: Theme.of(context).hintColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final r in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SolidCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(attendanceIcon(r.status),
                            color:
                                attendanceColor(r.status, context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                              DateFormat('EEEE, d MMM', 'ru')
                                  .format(r.date),
                              style: const TextStyle(fontSize: 15)),
                        ),
                        Text(attendanceLabel(r.status),
                            style: TextStyle(
                                color: attendanceColor(r.status, context),
                                fontWeight: FontWeight.w600)),
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
}

// ---------- СОБЫТИЯ ----------
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  IconData _kindIcon(String kind) {
    switch (kind) {
      case 'meeting':
        return Icons.groups_outlined;
      case 'exam':
        return Icons.quiz_outlined;
      case 'holiday':
        return Icons.beach_access_outlined;
      case 'sport':
        return Icons.sports_soccer_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.upcomingEvents;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('События школы')),
      body: GlassBackground(
        child: SafeArea(
          child: list.isEmpty
              ? const EmptyState(text: 'Событий нет')
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (final e in list)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 10),
                        child: SolidCard(
                          child: Row(
                            children: [
                              CircleAvatar(
                                  radius: 24,
                                  child: Icon(_kindIcon(e.kind))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(e.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    Text(
                                        '${DateFormat('d MMM HH:mm', 'ru').format(e.date)} • ${e.place}',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .hintColor)),
                                  ],
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
}

// ---------- УВЕДОМЛЕНИЯ ----------
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.notifications;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: state.markAllRead,
              child: const Text('Прочитать все'),
            ),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          child: list.isEmpty
              ? const EmptyState(text: 'Уведомлений нет')
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (final n in list)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 10),
                        child: SolidCard(
                          onTap: () => state.toggleRead(n),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(
                                state.isRead(n)
                                    ? Icons.notifications_none
                                    : (n.smart
                                        ? Icons.auto_awesome
                                        : Icons.notifications_active),
                                color: state.isRead(n)
                                    ? Theme.of(context).hintColor
                                    : Theme.of(context)
                                        .colorScheme
                                        .primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            style: TextStyle(
                                              fontWeight:
                                                  state.isRead(n)
                                                      ? FontWeight.normal
                                                      : FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        if (n.smart)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8),
                                            ),
                                            child: const Text('умное',
                                                style: TextStyle(
                                                    fontSize: 11)),
                                          ),
                                      ],
                                    ),
                                    Text(n.body),
                                    Text(
                                      DateFormat('d MMM HH:mm', 'ru')
                                          .format(n.createdAt),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .hintColor),
                                    ),
                                  ],
                                ),
                              ),
                              if (!state.isRead(n))
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    shape: BoxShape.circle,
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
}
