import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/more_screen.dart';
import 'screens/tabs.dart';
import 'screens/teacher_screens.dart';
import 'theme/app_theme.dart';
import 'widgets/child_switcher_header.dart';
import 'widgets/glass_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  final state = AppState();
  await state.init();
  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const ERuznomaApp(),
    ),
  );
}

class ERuznomaApp extends StatelessWidget {
  const ERuznomaApp({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return MaterialApp(
      title: 'E-Ruznoma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: app.themeMode,
      home: app.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final unread = app.unreadCount;
    final teacher = app.isTeacher;

    final pages = teacher
        ? <Widget>[
            const TeacherClassesScreen(),
            const JournalScreen(),
            const AssignmentsScreen(),
            const MoreScreen(),
          ]
        : <Widget>[
            DashboardScreen(onNavigate: _go),
            const GradesScreen(),
            const ScheduleScreen(),
            const HomeworkScreen(),
            const MoreScreen(),
          ];
    if (_index >= pages.length) _index = 0;

    final destinations = teacher
        ? const [
            NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: 'Классы'),
            NavigationDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book),
                label: 'Журнал'),
            NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Задания'),
            NavigationDestination(
                icon: Icon(Icons.menu_outlined),
                selectedIcon: Icon(Icons.menu),
                label: 'Ещё'),
          ]
        : const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Главная'),
            NavigationDestination(
                icon: Icon(Icons.grade_outlined),
                selectedIcon: Icon(Icons.grade),
                label: 'Оценки'),
            NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Расписание'),
            NavigationDestination(
                icon: Icon(Icons.home_work_outlined),
                selectedIcon: Icon(Icons.home_work),
                label: 'Домашка'),
            NavigationDestination(
                icon: Icon(Icons.menu_outlined),
                selectedIcon: Icon(Icons.menu),
                label: 'Ещё'),
          ];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(teacher ? 'Кабинет учителя' : 'Электронный дневник'),
        actions: [
          IconButton(
            tooltip: 'Уведомления',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const NotificationsScreen()),
            ),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (!teacher)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: ChildSwitcherHeader(),
                ),
              Expanded(
                child: IndexedStack(index: _index, children: pages),
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: GlassCard(
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: NavigationBar(
            height: 62,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: _index,
            labelBehavior:
                NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: _go,
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
