import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

// Шапка главного экрана: переключение между детьми в один клик.
class ChildSwitcherHeader extends StatelessWidget {
  const ChildSwitcherHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'E-Ruznoma',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Сменить тему',
              onPressed: state.toggleTheme,
              icon: Icon(
                state.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
          ],
        ),
        Text(
          state.selectedChild.schoolName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.children.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final child = state.children[i];
              final selected = child.id == state.selectedChild.id;
              return ChoiceChip(
                label: Text('${child.firstName} • ${child.schoolClass}'),
                selected: selected,
                avatar: CircleAvatar(
                  child: Text(child.firstName[0]),
                ),
                onSelected: (_) => state.selectChild(child.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
