import 'package:flutter_test/flutter_test.dart';
import 'package:e_ruzmona/providers/app_state.dart';

void main() {
  test('average in valid range', () {
    final s = AppState();
    expect(s.average, inInclusiveRange(2.0, 5.0));
  });

  test('multiple children + switching resets subject filter', () {
    final s = AppState();
    expect(s.children.length, 2);
    s.setGradeSubject(s.subjects.first);
    s.selectChild(s.children.last.id);
    expect(s.selectedChild.id, s.children.last.id);
    expect(s.gradeSubject, 'Все');
  });

  test('homework toggle + filters', () {
    final s = AppState();
    final h = s.homework.first;
    expect(s.isDone(h), isFalse);
    s.toggleHomework(h);
    expect(s.isDone(h), isTrue);
    s.setHomeworkFilter('Выполненные');
    expect(s.filteredHomework.map((e) => e.id), contains(h.id));
    s.toggleHomework(h);
    expect(s.isDone(h), isFalse);
  });

  test('notifications read flow', () {
    final s = AppState();
    expect(s.unreadCount, s.notifications.length);
    s.toggleRead(s.notifications.first);
    expect(s.unreadCount, s.notifications.length - 1);
    s.markAllRead();
    expect(s.unreadCount, 0);
  });

  test('login/logout', () {
    final s = AppState();
    expect(s.isLoggedIn, isFalse);
    s.login('Тест');
    expect(s.isLoggedIn, isTrue);
    expect(s.parentName, 'Тест');
    s.logout();
    expect(s.isLoggedIn, isFalse);
  });

  test('grades term filter', () {
    final s = AppState();
    s.setGradeTerm('II четверть');
    expect(s.filteredGrades.every((g) => g.term == 'II четверть'), isTrue);
    expect(s.filteredGrades, isNotEmpty);
  });
}
