import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Градиентный фон с мягкими цветными пятнами (Liquid Glass сцена).
class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF0B1220), Color(0xFF16204A), Color(0xFF0B3B39)]
              : const [Color(0xFFE3EBFF), Color(0xFFF6F3FF), Color(0xFFE2F7F1)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _blob(dark ? const Color(0xFF4F6BFF).withValues(alpha: 0.45)
                : const Color(0xFF7BA7FF).withValues(alpha: 0.55), 230),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _blob(dark ? const Color(0xFF22C7A9).withValues(alpha: 0.30)
                : const Color(0xFFF9A8D4).withValues(alpha: 0.50), 260),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// Плотная цветная карточка контента (без прозрачности).
// Стекло (blur) используется только для навигации — GlassCard.
class SolidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const SolidCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.6),
            width: 1),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: card,
    );
  }
}

// Стеклянная карточка: blur + полупрозрачная заливка + светлая рамка.
// Использовать ТОЛЬКО для layout-хрома (нижняя навигация).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppTheme.glassFill(context),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(
                color: AppTheme.glassBorder(context), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: onTap,
      child: card,
    );
  }
}

// Стеклянная оценка с неоновым свечением.
class GlassGradeBadge extends StatelessWidget {
  final int value;
  final double size;
  const GlassGradeBadge({super.key, required this.value, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final color = gradeColor(value, Theme.of(context).brightness);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: color.withValues(alpha: 0.65), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        '$value',
        style: TextStyle(
            fontSize: size * 0.44,
            fontWeight: FontWeight.w800,
            color: color),
      ),
    );
  }
}

// Кольцо процента (посещаемость, цель).
class GlassRing extends StatelessWidget {
  final double progress; // 0..1
  final String center;
  final double size;
  const GlassRing(
      {super.key,
      required this.progress,
      required this.center,
      this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          track: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.15),
          bar: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: Text(center,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color bar;
  _RingPainter(
      {required this.progress, required this.track, required this.bar});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 7;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    final barPaint = Paint()
      ..color = bar
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, trackPaint);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -3.14159 / 2,
        2 * 3.14159 * progress, false, barPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// Мини-график динамики среднего балла.
class TrendChart extends StatelessWidget {
  final List<double> points; // значения 2..5
  final List<String> labels;
  final double height;
  const TrendChart(
      {super.key,
      required this.points,
      required this.labels,
      this.height = 100});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _TrendPainter(
          points: points,
          color: Theme.of(context).colorScheme.primary,
          grid: Theme.of(context).hintColor.withValues(alpha: 0.35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final l in labels)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(l,
                    style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).hintColor)),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final Color grid;
  _TrendPainter(
      {required this.points, required this.color, required this.grid});

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 14.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2 - 14;
    double nx(int i) => pad + w * (points.length == 1 ? 0.5 : i / (points.length - 1));
    double ny(double v) =>
        pad + h * (1 - ((v - 2) / 3).clamp(0.0, 1.0));
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var g = 0; g < 3; g++) {
      final y = pad + h * g / 2;
      canvas.drawLine(Offset(pad, y), Offset(pad + w, y), gridPaint);
    }
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = Offset(nx(i), ny(points[i]));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        final prev = Offset(nx(i - 1), ny(points[i - 1]));
        final mid = Offset((prev.dx + p.dx) / 2, (prev.dy + p.dy) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
        if (i == points.length - 1) path.lineTo(p.dx, p.dy);
      }
    }
    final area = Path.from(path)
      ..lineTo(nx(points.length - 1), pad + h)
      ..lineTo(nx(0), pad + h)
      ..close();
    canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.02)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    final dotPaint = Paint()..color = color;
    final holePaint = Paint()..color = const Color(0xFFFFFFFF);
    for (var i = 0; i < points.length; i++) {
      final p = Offset(nx(i), ny(points[i]));
      canvas.drawCircle(p, 4.5, dotPaint);
      canvas.drawCircle(p, 2, holePaint);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.points != points;
}

// Responsive bottom-sheet снизу вверх: закругление, ручка, адаптивная ширина.
Future<T?> showGlassSheet<T>(BuildContext context, Widget child) {
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 4,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
    ),
  );
}

// Заголовок секции + пустое состояние (glass-стиль наследует тему).
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionTitle(
      {super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final String text;
  const EmptyState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined,
                size: 44, color: Theme.of(context).hintColor),
            const SizedBox(height: 10),
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

// Статус посещаемости: цвет + иконка.
Color attendanceColor(String status, BuildContext context) {
  switch (status) {
    case 'present':
      return const Color(0xFF16A34A);
    case 'late':
      return const Color(0xFFD97706);
    case 'sick':
      return const Color(0xFF2563EB);
    default:
      return Theme.of(context).colorScheme.error;
  }
}

String attendanceLabel(String status) {
  switch (status) {
    case 'present':
      return 'Был(а)';
    case 'late':
      return 'Опоздал(а)';
    case 'sick':
      return 'Болеет';
    default:
      return 'Отсутствует';
  }
}

IconData attendanceIcon(String status) {
  switch (status) {
    case 'present':
      return Icons.check_circle;
    case 'late':
      return Icons.access_time;
    case 'sick':
      return Icons.healing_outlined;
    default:
      return Icons.cancel_outlined;
  }
}
