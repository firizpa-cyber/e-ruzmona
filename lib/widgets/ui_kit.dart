import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Круглая цветная плашка оценки: 5-зелёная, 4-синяя, 3-оранжевая, 2-красная.
class GradeBadge extends StatelessWidget {
  final int value;
  final double size;
  const GradeBadge({super.key, required this.value, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = gradeColor(value, brightness);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

// Визуальный прогресс-бар среднего балла (шкала 2..5 -> 0..1).
class AverageProgress extends StatelessWidget {
  final double average;
  const AverageProgress({super.key, required this.average});

  @override
  Widget build(BuildContext context) {
    final progress = ((average - 2) / 3).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Средний балл',
                style: Theme.of(context).textTheme.titleMedium),
            Text(
              average.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class RoundedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const RoundedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: card,
    );
  }
}

// Заголовок секции.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionTitle({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

// Пустое состояние списков.
class EmptyState extends StatelessWidget {
  final String text;
  const EmptyState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined,
                size: 48, color: Theme.of(context).hintColor),
            const SizedBox(height: 12),
            Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).hintColor)),
          ],
        ),
      ),
    );
  }
}

// Горизонтальная полоса среднего балла по предмету (шкала 2..5).
class SubjectBar extends StatelessWidget {
  final String subject;
  final double average;
  const SubjectBar({super.key, required this.subject, required this.average});

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
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
