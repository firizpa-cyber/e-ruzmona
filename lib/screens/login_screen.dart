import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/glass_kit.dart';

// Вход (mock): имя + телефон + роль, либо демо-вход в один клик.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  UserRole _role = UserRole.parent;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit({bool demo = false}) {
    final state = context.read<AppState>();
    if (demo) {
      state.login(
          _role == UserRole.teacher ? 'Учитель' : 'Демо-родитель',
          role: _role);
      return;
    }
    if (_name.text.trim().isEmpty || _phone.text.trim().length < 6) {
      setState(() => _error = 'Введите имя и телефон (минимум 6 цифр)');
      return;
    }
    setState(() => _error = null);
    state.login(_name.text, role: _role);
  }

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.school,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('E-Ruznoma',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('Электронный дневник • ИСУО Таджикистана',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: Theme.of(context).hintColor)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: _roleCard(UserRole.parent, 'Родитель',
                                Icons.family_restroom_outlined)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _roleCard(UserRole.teacher, 'Учитель',
                                Icons.menu_book_outlined)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Column(
                        children: [
                          TextField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Имя',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(16))),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Телефон',
                              hintText: '+992 90 123 45 67',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(16))),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(_error!,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error)),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submit,
                              child: const Text('Войти'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _submit(demo: true),
                              child: const Text('Демо-вход'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Демо-режим: данные вымышлены и хранятся только на устройстве.',
                      textAlign: TextAlign.center,
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

  Widget _roleCard(UserRole role, String label, IconData icon) {
    final selected = _role == role;
    return GlassCard(
      onTap: () => setState(() => _role = role),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Icon(icon,
              size: 30,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).hintColor),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.normal)),
          const SizedBox(height: 4),
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }
}
