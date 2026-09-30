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
  const Grade({required this.subject, required this.value, required this.date});
}

class Lesson {
  final int order;
  final String subject;
  final String time; // "08:00–08:45"
  final String room;
  final String teacher;
  const Lesson({
    required this.order,
    required this.subject,
    required this.time,
    required this.room,
    required this.teacher,
  });
}

class Homework {
  final String subject;
  final String task;
  final DateTime dueDate;
  final bool done;
  const Homework({
    required this.subject,
    required this.task,
    required this.dueDate,
    this.done = false,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });
}
