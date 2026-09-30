import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

// Компактная шапка (одна строка ~56px): аватар + имя/класс + смена ребёнка.
class CompactChildBar extends StatelessWidget {
  const CompactChildBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.selectedChild;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _pickChild(context, state),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              child: Text(child.firstName[0],
                  style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    child.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${child.schoolClass} • ${child.schoolName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.swap_horiz,
                color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  void _pickChild(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in state.children)
              ListTile(
                dense: true,
                leading: CircleAvatar(child: Text(c.firstName[0])),
                title: Text(c.fullName,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(c.schoolClass,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: c.id == state.selectedChild.id
                    ? Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  state.selectChild(c.id);
                  Navigator.of(ctx).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
