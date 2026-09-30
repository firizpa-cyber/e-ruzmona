import '../models/models.dart';

// Mock ИСУО (EMIS). Заменить на реальный EmisApiClient без изменения UI:
// UI работает только с этими методами.
class MockEmisRepository {
  List<Child> getChildren() => const [
        Child(
          id: 'c1',
          firstName: 'Амина',
          lastName: 'Юсупова',
          schoolClass: '7 «А»',
          schoolName: 'Школа № 12, Душанбе',
        ),
        Child(
          id: 'c2',
          firstName: 'Омар',
          lastName: 'Юсупов',
          schoolClass: '4 «Б»',
          schoolName: 'Школа № 12, Душанбе',
        ),
      ];

  List<Grade> getGrades(String childId) {
    if (childId == 'c2') {
      return [
        Grade(subject: 'Математика', value: 5, date: DateTime(2026, 9, 29)),
        Grade(subject: 'Чтение', value: 4, date: DateTime(2026, 9, 29)),
        Grade(subject: 'Русский язык', value: 4, date: DateTime(2026, 9, 28)),
        Grade(subject: 'Окружающий мир', value: 5, date: DateTime(2026, 9, 27)),
      ];
    }
    return [
      Grade(subject: 'Алгебра', value: 5, date: DateTime(2026, 9, 29)),
      Grade(subject: 'Геометрия', value: 4, date: DateTime(2026, 9, 29)),
      Grade(subject: 'Физика', value: 4, date: DateTime(2026, 9, 28)),
      Grade(subject: 'История', value: 5, date: DateTime(2026, 9, 27)),
      Grade(subject: 'Химия', value: 3, date: DateTime(2026, 9, 26)),
      Grade(subject: 'Английский', value: 5, date: DateTime(2026, 9, 25)),
    ];
  }

  Map<String, List<Lesson>> getWeekSchedule(String childId) {
    List<Lesson> day(List<Lesson> l) => l;
    return {
      'Пн': day(const [
        Lesson(order: 1, subject: 'Математика', time: '08:00–08:45', room: '204', teacher: 'С. Рахимова'),
        Lesson(order: 2, subject: 'Русский язык', time: '08:55–09:40', room: '204', teacher: 'И. Петрова'),
        Lesson(order: 3, subject: 'История', time: '09:55–10:40', room: '310', teacher: 'Д. Назаров'),
      ]),
      'Вт': day(const [
        Lesson(order: 1, subject: 'Физика', time: '08:00–08:45', room: '208', teacher: 'А. Собиров'),
        Lesson(order: 2, subject: 'Алгебра', time: '08:55–09:40', room: '204', teacher: 'С. Рахимова'),
        Lesson(order: 3, subject: 'Английский', time: '09:55–10:40', room: '112', teacher: 'М. Джонс'),
      ]),
      'Ср': day(const [
        Lesson(order: 1, subject: 'Химия', time: '08:00–08:45', room: '209', teacher: 'Л. Каримова'),
        Lesson(order: 2, subject: 'Геометрия', time: '08:55–09:40', room: '204', teacher: 'С. Рахимова'),
        Lesson(order: 3, subject: 'Физкультура', time: '09:55–10:40', room: 'Зал', teacher: 'О. Алиев'),
      ]),
      'Чт': day(const [
        Lesson(order: 1, subject: 'Биология', time: '08:00–08:45', room: '210', teacher: 'Н. Шарипова'),
        Lesson(order: 2, subject: 'Литература', time: '08:55–09:40', room: '204', teacher: 'И. Петрова'),
      ]),
      'Пт': day(const [
        Lesson(order: 1, subject: 'Информатика', time: '08:00–08:45', room: '105', teacher: 'Т. Холов'),
        Lesson(order: 2, subject: 'Таджикский язык', time: '08:55–09:40', room: '204', teacher: 'Г. Мирзоева'),
      ]),
    };
  }

  List<Homework> getHomework(String childId) => [
        Homework(subject: 'Алгебра', task: '№ 245–247, стр. 78', dueDate: DateTime(2026, 10, 1)),
        Homework(subject: 'Английский', task: 'Выучить слова Unit 4', dueDate: DateTime(2026, 10, 1)),
        Homework(subject: 'Физика', task: '§12, вопросы 1–4', dueDate: DateTime(2026, 10, 2), done: true),
        Homework(subject: 'История', task: 'Подготовить рассказ §8', dueDate: DateTime(2026, 10, 2)),
      ];

  List<AppNotification> getNotifications(String childId) => [
        AppNotification(
          id: 'n1',
          title: 'Новая оценка: Алгебра — 5',
          body: 'Учительница С. Рахимова выставила оценку.',
          createdAt: DateTime(2026, 9, 29, 14, 20),
        ),
        AppNotification(
          id: 'n2',
          title: 'Домашнее задание на завтра',
          body: '3 задания к 1 октября.',
          createdAt: DateTime(2026, 9, 29, 12, 5),
        ),
        AppNotification(
          id: 'n3',
          title: 'Родительское собрание',
          body: '2 октября в 18:00, каб. 204.',
          createdAt: DateTime(2026, 9, 28, 9, 0),
          read: true,
        ),
      ];
}
