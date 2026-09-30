import 'package:flutter_test/flutter_test.dart';
import 'package:e_ruzmona/models/models.dart';
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

  test('login/logout + role', () {
    final s = AppState();
    expect(s.isLoggedIn, isFalse);
    s.login('Тест', role: UserRole.teacher);
    expect(s.isLoggedIn, isTrue);
    expect(s.parentName, 'Тест');
    expect(s.isTeacher, isTrue);
    s.switchRole(UserRole.parent);
    expect(s.isTeacher, isFalse);
    s.logout();
    expect(s.isLoggedIn, isFalse);
  });

  test('grades term filter', () {
    final s = AppState();
    s.setGradeTerm('II четверть');
    expect(s.filteredGrades.every((g) => g.term == 'II четверть'), isTrue);
    expect(s.filteredGrades, isNotEmpty);
  });

  test('attendance percent + absences', () {
    final s = AppState();
    expect(s.attendance.length, 20);
    expect(s.attendancePercent, inInclusiveRange(0, 100));
    expect(s.absenceCount, greaterThanOrEqualTo(0));
  });

  test('teacher grade visible to parent', () {
    final s = AppState();
    final before = s.grades.length;
    s.addGrade(childId: 'c1', subject: 'Алгебра', value: 5);
    expect(s.grades.length, before + 1);
    s.addGrade(childId: 's02', subject: 'Алгебра', value: 4);
    expect(s.studentGrades('s02').length, 1);
  });

  test('teacher homework visible to parent class', () {
    final s = AppState();
    final before = s.homework.length;
    s.assignHomework(
      className: '7 «А»',
      subject: 'Алгебра',
      task: 'Повторить главу 3',
      due: DateTime(2026, 10, 5),
    );
    expect(s.homework.length, before + 1);
  });

  test('teacher attendance mark cycles + reflects on child', () {
    final s = AppState();
    final date = DateTime(2026, 9, 30);
    expect(s.classStatus('t7a', 's01', date), 'present');
    s.cycleMark('t7a', 's01', date);
    expect(s.classStatus('t7a', 's01', date), 'late');
    final rec = s.attendance.firstWhere(
        (r) =>
            r.date.year == 2026 &&
            r.date.month == 9 &&
            r.date.day == 30,
        orElse: () => AttendanceRecord(
            childId: 'c1', date: date, status: 'none'));
    expect(rec.status, 'late');
  });

  test('goal + smart notifications + insights', () {
    final s = AppState();
    s.setGoal(4.5);
    expect(s.goal, 4.5);
    final ids = s.notifications.map((n) => n.id).toSet();
    expect(ids, contains('s-briefing'));
    expect(ids, contains('s-goal'));
    expect(s.insights, isNotEmpty);
    expect(s.weeklyTrend.length, 4);
    expect(s.upcomingEvents, isNotEmpty);
    expect(s.shareReport(), contains('E-Ruznoma'));
  });
}
