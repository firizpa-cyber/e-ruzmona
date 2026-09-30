import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/ui_kit.dart';

// ---------- ГЛАВНАЯ (дашборд) ----------
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.selectedChild;
    final recent = state.filteredGrades.take(3).toList();
    final today = state.todayLessons;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RoundedCard(
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
              AverageProgress(average: state.average),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('«5»: ${state.countGrade(5)}')),
                  Chip(label: Text('«4»: ${state.countGrade(4)}')),
                  Chip(label: Text('«3»: ${state.countGrade(3)}')),
                  Chip(label: Text('«2»: ${state.countGrade(2)}')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionTitle(
          title: 'Сегодня (${AppState.todayDayName}): ${today.length} ур.',
          actionLabel: 'Расписание',
          onAction: () => onNavigate(2),
        ),
        if (today.isEmpty)
          const EmptyState(text: 'Сегодня уроков нет')
        else
          for (final l in today.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RoundedCard(
                onTap: () => onNavigate(2),
                child: Row(
                  children: [
                    CircleAvatar(child: Text('${l.order}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.subject,
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          Text('${l.time} • ${l.room}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 4),
        SectionTitle(
          title: 'Домашка: осталось ${state.pendingHomework}',
          actionLabel: 'Открыть',
          onAction: () => onNavigate(3),
        ),
        RoundedCard(
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
          title: 'Последние оценки',
          actionLabel: 'Все оценки',
          onAction: () => onNavigate(1),
        ),
        if (recent.isEmpty)
          const EmptyState(text: 'Оценок пока нет')
        else
          for (final g in recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RoundedCard(
                onTap: () => onNavigate(1),
                child: Row(
                  children: [
                    GradeBadge(value: g.value, size: 40),
                    const SizedBox(width: 12),
                    Expanded(child: Text(g.subject)),
                    Text(
                      DateFormat('d MMM', 'ru').format(g.date),
                      style:
                          TextStyle(color: Theme.of(context).hintColor),
                    ),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RoundedCard(child: AverageProgress(average: state.average)),
        const SizedBox(height: 12),
        RoundedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Среднее по предметам',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              for (final s in state.subjects)
                SubjectBar(
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
              child: RoundedCard(
                child: Row(
                  children: [
                    GradeBadge(value: g.value),
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

// ---------- РАСПИСАНИЕ ----------
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final days = state.schedule.keys.toList();
    final lessons = state.dayLessons;
    return ListView(
      padding: const EdgeInsets.all(16),
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
              child: RoundedCard(
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
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
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
      padding: const EdgeInsets.all(16),
      children: [
        RoundedCard(
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
              child: RoundedCard(
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

// ---------- УВЕДОМЛЕНИЯ ----------
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.notifications;
    return Scaffold(
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
      body: list.isEmpty
          ? const EmptyState(text: 'Уведомлений нет')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final n in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RoundedCard(
                      onTap: () => state.toggleRead(n),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            state.isRead(n)
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: state.isRead(n)
                                ? Theme.of(context).hintColor
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: TextStyle(
                                    fontWeight: state.isRead(n)
                                        ? FontWeight.normal
                                        : FontWeight.w700,
                                    fontSize: 16,
                                  ),
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
    );
  }
}
