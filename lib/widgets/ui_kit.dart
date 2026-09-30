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
  const RoundedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }
}
