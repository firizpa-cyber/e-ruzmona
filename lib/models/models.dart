// E-Ruznoma models — соответствуют будущему EMIS API, сейчас mock.
class Child {
  final String id;
  final String firstName;
  final String lastName;
  final String schoolClass;
  final String schoolName;
  final String? avatarUrl;
  const Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.schoolClass,
    required this.schoolName,
    this.avatarUrl,
  });
  String get fullName => '$firstName $lastName';
}

class Grade {
  final String subject;
  final int value; // 2..5
  final DateTime date;
  final String term; // 'I четверть' | 'II четверть'
  const Grade({
    required this.subject,
    required this.value,
    required this.date,
    this.term = 'I четверть',
  });
}

class Lesson {
  final int order;
  final String subject;
  final String time; // "08:00–08:45"
  final String room;
  final String teacher;
  final String? homework;
  const Lesson({
    required this.order,
    required this.subject,
    required this.time,
    required this.room,
    required this.teacher,
    this.homework,
  });
}

class Homework {
  final String id;
  final String subject;
  final String task;
  final DateTime dueDate;
  const Homework({
    required this.id,
    required this.subject,
    required this.task,
    required this.dueDate,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });
}
