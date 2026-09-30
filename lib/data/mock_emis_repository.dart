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
        Grade(subject: 'Русский язык', value: 5, date: DateTime(2026, 9, 21)),
        Grade(subject: 'Окружающий мир', value: 5, date: DateTime(2026, 9, 27)),
        Grade(subject: 'Окружающий мир', value: 4, date: DateTime(2026, 9, 20)),
        Grade(subject: 'Математика', value: 4, date: DateTime(2026, 9, 22)),
        Grade(subject: 'Математика', value: 5, date: DateTime(2026, 9, 15)),
        Grade(subject: 'Чтение', value: 5, date: DateTime(2026, 9, 24)),
        Grade(subject: 'Английский', value: 4, date: DateTime(2026, 9, 26)),
        Grade(subject: 'Физкультура', value: 5, date: DateTime(2026, 9, 25)),
        Grade(subject: 'Рисование', value: 5, date: DateTime(2026, 9, 24)),
        Grade(
            subject: 'Математика',
            value: 5,
            date: DateTime(2026, 10, 27),
            term: 'II четверть'),
      ];
    }
    return [
      Grade(subject: 'Алгебра', value: 5, date: DateTime(2026, 9, 29)),
      Grade(subject: 'Геометрия', value: 4, date: DateTime(2026, 9, 29)),
      Grade(subject: 'Алгебра', value: 4, date: DateTime(2026, 9, 22)),
      Grade(subject: 'Алгебра', value: 5, date: DateTime(2026, 9, 15)),
      Grade(subject: 'Алгебра', value: 5, date: DateTime(2026, 9, 8)),
      Grade(subject: 'Геометрия', value: 5, date: DateTime(2026, 9, 23)),
      Grade(subject: 'Геометрия', value: 4, date: DateTime(2026, 9, 16)),
      Grade(subject: 'Физика', value: 4, date: DateTime(2026, 9, 28)),
      Grade(subject: 'Физика', value: 3, date: DateTime(2026, 9, 21)),
      Grade(subject: 'Физика', value: 4, date: DateTime(2026, 9, 14)),
      Grade(subject: 'История', value: 5, date: DateTime(2026, 9, 27)),
      Grade(subject: 'История', value: 5, date: DateTime(2026, 9, 20)),
      Grade(subject: 'Химия', value: 3, date: DateTime(2026, 9, 26)),
      Grade(subject: 'Химия', value: 4, date: DateTime(2026, 9, 19)),
      Grade(subject: 'Английский', value: 5, date: DateTime(2026, 9, 25)),
      Grade(subject: 'Английский', value: 4, date: DateTime(2026, 9, 18)),
      Grade(subject: 'Английский', value: 5, date: DateTime(2026, 9, 11)),
      Grade(subject: 'Русский язык', value: 4, date: DateTime(2026, 9, 24)),
      Grade(subject: 'Русский язык', value: 4, date: DateTime(2026, 9, 17)),
      Grade(subject: 'Литература', value: 5, date: DateTime(2026, 9, 23)),
      Grade(
          subject: 'Физика',
          value: 5,
          date: DateTime(2026, 10, 28),
          term: 'II четверть'),
      Grade(
          subject: 'Английский',
          value: 4,
          date: DateTime(2026, 10, 27),
          term: 'II четверть'),
    ];
  }

  Map<String, List<Lesson>> getWeekSchedule(String childId) {
    if (childId == 'c2') {
      return {
        'Пн': const [
          Lesson(order: 1, subject: 'Математика', time: '08:00–08:45', room: '104', teacher: 'Ф. Хамидова', homework: 'Стр. 42, № 5–7'),
          Lesson(order: 2, subject: 'Русский язык', time: '08:55–09:40', room: '104', teacher: 'Е. Соколова', homework: 'Упр. 31, словарные слова'),
          Lesson(order: 3, subject: 'Чтение', time: '09:55–10:40', room: '104', teacher: 'Е. Соколова', homework: 'Читать стр. 55–58'),
          Lesson(order: 4, subject: 'Физкультура', time: '10:50–11:35', room: 'Зал', teacher: 'О. Алиев'),
        ],
        'Вт': const [
          Lesson(order: 1, subject: 'Окружающий мир', time: '08:00–08:45', room: '104', teacher: 'Ф. Хамидова', homework: 'Стр. 30–32, вопросы'),
          Lesson(order: 2, subject: 'Математика', time: '08:55–09:40', room: '104', teacher: 'Ф. Хамидова', homework: 'Стр. 44, № 12–14'),
          Lesson(order: 3, subject: 'Таджикский язык', time: '09:55–10:40', room: '104', teacher: 'З. Рахмонова'),
          Lesson(order: 4, subject: 'Рисование', time: '10:50–11:35', room: '110', teacher: 'К. Умарова'),
        ],
        'Ср': const [
          Lesson(order: 1, subject: 'Русский язык', time: '08:00–08:45', room: '104', teacher: 'Е. Соколова', homework: 'Упр. 35'),
          Lesson(order: 2, subject: 'Чтение', time: '08:55–09:40', room: '104', teacher: 'Е. Соколова'),
          Lesson(order: 3, subject: 'Английский', time: '09:55–10:40', room: '112', teacher: 'Д. Эмомали', homework: 'Слова lesson 5'),
          Lesson(order: 4, subject: 'Физкультура', time: '10:50–11:35', room: 'Зал', teacher: 'О. Алиев'),
        ],
        'Чт': const [
          Lesson(order: 1, subject: 'Математика', time: '08:00–08:45', room: '104', teacher: 'Ф. Хамидова', homework: 'Стр. 46, № 3–5'),
          Lesson(order: 2, subject: 'Окружающий мир', time: '08:55–09:40', room: '104', teacher: 'Ф. Хамидова'),
          Lesson(order: 3, subject: 'Музыка', time: '09:55–10:40', room: '108', teacher: 'С. Вохидова'),
        ],
        'Пт': const [
          Lesson(order: 1, subject: 'Чтение', time: '08:00–08:45', room: '104', teacher: 'Е. Соколова', homework: 'Выучить стихотворение'),
          Lesson(order: 2, subject: 'Русский язык', time: '08:55–09:40', room: '104', teacher: 'Е. Соколова'),
          Lesson(order: 3, subject: 'Математика', time: '09:55–10:40', room: '104', teacher: 'Ф. Хамидова'),
          Lesson(order: 4, subject: 'Технология', time: '10:50–11:35', room: '111', teacher: 'К. Умарова'),
        ],
      };
    }
    return {
      'Пн': const [
        Lesson(order: 1, subject: 'Алгебра', time: '08:00–08:45', room: '204', teacher: 'С. Рахимова', homework: '№ 245–247, стр. 78'),
        Lesson(order: 2, subject: 'Русский язык', time: '08:55–09:40', room: '204', teacher: 'И. Петрова', homework: 'Упр. 112, правило §14'),
        Lesson(order: 3, subject: 'История', time: '09:55–10:40', room: '310', teacher: 'Д. Назаров', homework: '§8, вопросы 1–3'),
        Lesson(order: 4, subject: 'Физкультура', time: '10:55–11:40', room: 'Зал', teacher: 'О. Алиев'),
      ],
      'Вт': const [
        Lesson(order: 1, subject: 'Физика', time: '08:00–08:45', room: '208', teacher: 'А. Собиров', homework: '§12, вопросы 1–4'),
        Lesson(order: 2, subject: 'Алгебра', time: '08:55–09:40', room: '204', teacher: 'С. Рахимова', homework: '№ 250–252'),
        Lesson(order: 3, subject: 'Английский', time: '09:55–10:40', room: '112', teacher: 'М. Джонс', homework: 'Слова Unit 4'),
        Lesson(order: 4, subject: 'География', time: '10:55–11:40', room: '310', teacher: 'Д. Назаров', homework: 'Контурные карты, стр. 12'),
      ],
      'Ср': const [
        Lesson(order: 1, subject: 'Химия', time: '08:00–08:45', room: '209', teacher: 'Л. Каримова', homework: '§6, задача 3'),
        Lesson(order: 2, subject: 'Геометрия', time: '08:55–09:40', room: '204', teacher: 'С. Рахимова', homework: '№ 88–90'),
        Lesson(order: 3, subject: 'Литература', time: '09:55–10:40', room: '204', teacher: 'И. Петрова', homework: 'Читать гл. 3–4'),
        Lesson(order: 4, subject: 'Информатика', time: '10:55–11:40', room: '105', teacher: 'Т. Холов', homework: 'Презентация «Мой город»'),
      ],
      'Чт': const [
        Lesson(order: 1, subject: 'Биология', time: '08:00–08:45', room: '210', teacher: 'Н. Шарипова', homework: '§9, таблица'),
        Lesson(order: 2, subject: 'Литература', time: '08:55–09:40', room: '204', teacher: 'И. Петрова'),
        Lesson(order: 3, subject: 'Английский', time: '09:55–10:40', room: '112', teacher: 'М. Джонс', homework: 'WB p. 23, ex. 1–2'),
        Lesson(order: 4, subject: 'История', time: '10:55–11:40', room: '310', teacher: 'Д. Назаров'),
      ],
      'Пт': const [
        Lesson(order: 1, subject: 'Алгебра', time: '08:00–08:45', room: '204', teacher: 'С. Рахимова', homework: 'Подготовка к контрольной'),
        Lesson(order: 2, subject: 'Таджикский язык', time: '08:55–09:40', room: '204', teacher: 'Г. Мирзоева', homework: 'Иншо «Тирамоҳ»'),
        Lesson(order: 3, subject: 'Физика', time: '09:55–10:40', room: '208', teacher: 'А. Собиров', homework: 'Лабораторная № 2, отчёт'),
      ],
    };
  }

  List<Homework> getHomework(String childId) {
    if (childId == 'c2') {
      return [
        Homework(id: 'h1', subject: 'Математика', task: 'Стр. 42, № 5–7', dueDate: DateTime(2026, 10, 1)),
        Homework(id: 'h2', subject: 'Русский язык', task: 'Упр. 31, словарные слова', dueDate: DateTime(2026, 10, 1)),
        Homework(id: 'h3', subject: 'Чтение', task: 'Читать стр. 55–58', dueDate: DateTime(2026, 10, 2)),
        Homework(id: 'h4', subject: 'Окружающий мир', task: 'Стр. 30–32, вопросы', dueDate: DateTime(2026, 10, 2)),
      ];
    }
    return [
      Homework(id: 'h1', subject: 'Алгебра', task: '№ 245–247, стр. 78', dueDate: DateTime(2026, 10, 1)),
      Homework(id: 'h2', subject: 'Английский', task: 'Выучить слова Unit 4', dueDate: DateTime(2026, 10, 1)),
      Homework(id: 'h3', subject: 'Русский язык', task: 'Упр. 112, правило §14', dueDate: DateTime(2026, 10, 1)),
      Homework(id: 'h4', subject: 'Физика', task: '§12, вопросы 1–4', dueDate: DateTime(2026, 10, 2)),
      Homework(id: 'h5', subject: 'История', task: 'Подготовить рассказ §8', dueDate: DateTime(2026, 10, 2)),
      Homework(id: 'h6', subject: 'Химия', task: '§6, задача 3', dueDate: DateTime(2026, 10, 3)),
      Homework(id: 'h7', subject: 'Информатика', task: 'Презентация «Мой город»', dueDate: DateTime(2026, 10, 3)),
    ];
  }

  List<AppNotification> getNotifications(String childId) {
    final name = childId == 'c2' ? 'Омара' : 'Амины';
    final controlWork = childId == 'c2'
        ? 'В пятницу — проверочная по математике. Повторите таблицу умножения.'
        : 'В пятницу — контрольная по алгебре. Повторите главу 3.';
    return [
      AppNotification(
        id: 'n1',
        title: 'Новая оценка у $name',
        body: 'Выставлена оценка 5. Откройте раздел «Оценки».',
        createdAt: DateTime(2026, 9, 29, 14, 20),
      ),
      AppNotification(
        id: 'n2',
        title: 'Домашнее задание на завтра',
        body: 'Осталось невыполненных заданий — проверьте раздел «Домашка».',
        createdAt: DateTime(2026, 9, 29, 12, 5),
      ),
      AppNotification(
        id: 'n3',
        title: 'Родительское собрание',
        body: '2 октября в 18:00, каб. 204. Классный руководитель.',
        createdAt: DateTime(2026, 9, 28, 9, 0),
      ),
      AppNotification(
        id: 'n4',
        title: 'Проверочная работа',
        body: controlWork,
        createdAt: DateTime(2026, 9, 27, 16, 40),
      ),
      AppNotification(
        id: 'n5',
        title: 'Средний балл вырос',
        body: 'За неделю средний балл вырос на 0.12. Так держать!',
        createdAt: DateTime(2026, 9, 26, 10, 15),
      ),
    ];
  }
}
