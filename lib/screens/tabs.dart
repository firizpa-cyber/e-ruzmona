import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/ui_kit.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final grades = state.grades;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RoundedCard(child: AverageProgress(average: state.average)),
        const SizedBox(height: 12),
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
                            style:
                                Theme.of(context).textTheme.titleMedium),
                        Text(
                          DateFormat('d MMM', 'ru').format(g.date),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Theme.of(context).hintColor),
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

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final schedule = state.schedule;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in schedule.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RoundedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final l in entry.value)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text('${l.order}')),
                      title: Text(l.subject),
                      subtitle: Text('${l.time} • ${l.room}\n${l.teacher}'),
                      isThreeLine: true,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final h in state.homework)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RoundedCard(
              child: Row(
                children: [
                  Icon(
                    h.done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: h.done
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h.subject,
                            style:
                                Theme.of(context).textTheme.titleMedium),
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

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final n in state.notifications)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RoundedCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  n.read
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: n.read
                      ? Theme.of(context).hintColor
                      : Theme.of(context).colorScheme.primary,
                ),
                title: Text(n.title),
                subtitle: Text(
                    '${n.body}\n${DateFormat('d MMM HH:mm', 'ru').format(n.createdAt)}'),
              ),
            ),
          ),
      ],
    );
  }
}
