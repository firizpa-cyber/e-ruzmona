// E-Ruznoma models — соответствуют будущему EMIS API, сейчас mock.
enum UserRole { parent, teacher }

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
  final bool smart; // сгенерировано движком инсайтов, а не EMIS
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.smart = false,
  });
}

// Посещаемость: 'present' | 'late' | 'absent' | 'sick'
class AttendanceRecord {
  final String childId;
  final DateTime date;
  final String status;
  const AttendanceRecord({
    required this.childId,
    required this.date,
    required this.status,
  });
}

// Событие школы: собрание, контрольная, каникулы...
class SchoolEvent {
  final String id;
  final String title;
  final String place;
  final DateTime date;
  final String kind; // 'meeting' | 'exam' | 'holiday' | 'sport' | 'other'
  const SchoolEvent({
    required this.id,
    required this.title,
    required this.place,
    required this.date,
    this.kind = 'other',
  });
}

// Ученик в классе учителя.
class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String? childId; // связь с ребёнком родителя (для Амины/Омара)
  const Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.childId,
  });
  String get fullName => '$firstName $lastName';
}

class TeacherClass {
  final String id;
  final String name; // '7 «А»'
  final String subject; // предмет учителя в этом классе
  final List<Student> students;
  const TeacherClass({
    required this.id,
    required this.name,
    required this.subject,
    required this.students,
  });
}

// Умный инсайт недели для дашборда.
class SmartInsight {
  final String icon; // ключ иконки
  final String title;
  final String text;
  final bool good;
  const SmartInsight({
    required this.icon,
    required this.title,
    required this.text,
    this.good = true,
  });
}
