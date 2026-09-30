import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/ui_kit.dart';
import 'tabs.dart';

// Вкладка «Ещё»: дети, уведомления, оформление, о приложении, выход.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle(title: 'Мои дети'),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: state.selectedChild.id,
          onChanged: (v) =>
              v != null ? state.selectChild(v) : null,
          child: Column(
            children: [
              for (final c in state.children)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RoundedCard(
                    onTap: () => state.selectChild(c.id),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(c.firstName[0],
                              style:
                                  const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(c.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              Text(
                                  '${c.schoolClass} • ${c.schoolName}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .hintColor)),
                            ],
                          ),
                        ),
                        Radio<String>(value: c.id),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const SectionTitle(title: 'Сервис'),
        const SizedBox(height: 8),
        RoundedCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: Badge(
                  isLabelVisible: state.unreadCount > 0,
                  label: Text('${state.unreadCount}'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                title: const Text('Уведомления'),
                subtitle: state.unreadCount == 0
                    ? const Text('Всё прочитано')
                    : Text('Непрочитанных: ${state.unreadCount}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(state.themeMode == ThemeMode.dark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined),
                title: const Text('Тёмная тема'),
                value: state.themeMode == ThemeMode.dark,
                onChanged: (_) => state.toggleTheme(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const SectionTitle(title: 'Аккаунт'),
        const SizedBox(height: 8),
        RoundedCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(state.parentName),
                subtitle: Text(
                    'Детей в аккаунте: ${state.children.length}'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('О приложении'),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('E-Ruznoma 0.1.0'),
                    content: const Text(
                        'Электронный дневник с интеграцией ИСУО (EMIS) Таджикистана.\n\nДемо-режим: все данные вымышлены и хранятся только на устройстве.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Закрыть'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Выйти',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
                onTap: () => state.logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
