import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/glass_kit.dart';

// Вход: приветственный экран + форма входа в шторке снизу.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.school,
                          size: 52,
                          color:
                              Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Text('E-Ruznoma',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 32)),
                    const SizedBox(height: 6),
                    Text('Оценки • Расписание • Домашка',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color:
                                    Theme.of(context).hintColor)),
                    Text('Посещаемость • Умные уведомления',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color:
                                    Theme.of(context).hintColor)),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18)),
                        ),
                        onPressed: () => _openLoginSheet(context),
                        child: const Text('Войти',
                            style: TextStyle(fontSize: 17)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        context
                            .read<AppState>()
                            .login('Демо-родитель');
                      },
                      child: const Text('Демо-вход без регистрации'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Демо-режим: данные вымышлены и хранятся только на устройстве.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openLoginSheet(BuildContext context) {
    final name = TextEditingController();
    final phone = TextEditingController();
    var role = UserRole.parent;
    var error = '';
    showGlassSheet(
      context,
      StatefulBuilder(
        builder: (ctx, setS) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Вход',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _roleTile(ctx, 'Родитель',
                        Icons.family_restroom_outlined,
                        role == UserRole.parent, () {
                  setS(() => role = UserRole.parent);
                })),
                const SizedBox(width: 10),
                Expanded(
                    child: _roleTile(ctx, 'Учитель',
                        Icons.menu_book_outlined,
                        role == UserRole.teacher, () {
                  setS(() => role = UserRole.teacher);
                })),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Имя',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(16))),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                hintText: '+992 90 123 45 67',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(16))),
              ),
            ),
            if (error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color:
                          Theme.of(ctx).colorScheme.error)),
            ],
            const SizedBox(height: 14),
            FilledButton(
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (name.text.trim().isEmpty ||
                    phone.text.trim().length < 6) {
                  setS(() => error =
                      'Введите имя и телефон (минимум 6 цифр)');
                  return;
                }
                Navigator.of(ctx).pop();
                context
                    .read<AppState>()
                    .login(name.text, role: role);
              },
              child: const Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleTile(BuildContext context, String label, IconData icon,
      bool selected, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected
                  ? scheme.primary
                  : scheme.outlineVariant
                      .withValues(alpha: 0.6),
              width: selected ? 1.6 : 1),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected
                    ? scheme.primary
                    : Theme.of(context).hintColor),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
