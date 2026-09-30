# E-Ruznoma — электронный дневник (Flutter + Web + TestFlight)

Кроссплатформенное приложение: iOS (TestFlight) + Web (Vercel).
Интеграция с ИСУО (EMIS) Таджикистана сейчас — **mock** (`lib/data/mock_emis_repository.dart`),
интерфейс уже готов к замене на реальный API без переделки экранов.

## Структура
```
lib/
  main.dart                — вход, темы, нижняя навигация
  theme/app_theme.dart     — Clean UI, светлая/тёмная, закруглённые карточки
  models/models.dart       — Child, Grade, Lesson, Homework, AppNotification
  data/mock_emis_repository.dart — mock EMIS, несколько детей
  providers/app_state.dart — выбранный ребёнок, средний балл, тема
  widgets/
    child_switcher_header.dart — шапка: переключение детей в 1 клик
    ui_kit.dart — GradeBadge (5-зелёная,4-синяя,3-оранжевая,2-красная), AverageProgress
  screens/tabs.dart — Оценки, Расписание, Домашка, Уведомления
ios/ExportOptions.plist
.github/workflows/ios-testflight.yml — настоящий TestFlight (нужен платный Apple Developer)
.github/workflows/deploy_ios_free.yml — бесплатная бета: unsigned IPA в Artifacts + Firebase/Diawi
codemagic.yaml — альтернатива: облачная сборка без своего Mac
vercel.json — деплой Flutter Web на Vercel (build/web)
```

## Дизайн (по ТЗ)
- Clean UI, закруглённые карточки (radius 18), крупный шрифт
- Цвета оценок: 5-зелёная, 4-синяя, 3-оранжевая, 2-красная
- Прогресс-бар среднего балла (шкала 2..5)
- Шапка с ChoiceChip для нескольких детей

## Локальный запуск (Flutter 3.47.5 уже стоит в `D:\flutter`)
```powershell
$env:Path = "D:\flutter\bin;" + $env:Path
flutter pub get
flutter analyze; flutter test
flutter build web --release
```

## Vercel (Web) — live: https://web-five-teal-bmrwp838zu.vercel.app
1. `flutter build web --release`
2. `npx vercel deploy ./build/web --prod --yes`
   (`vercel.json`: `outputDirectory: build/web` + SPA-rewrite; собирать локально,
   т.к. в облаке Vercel нет Flutter).

## iOS: бесплатная бета и настоящий TestFlight
См. `TESTFLIGHT_INSTRUCTION.md`:
- **Вариант 1 (бесплатно):** `deploy_ios_free.yml` → unsigned IPA в Artifacts →
  установка через Sideloadly / Diawi / Firebase App Distribution.
- **Вариант 2 ($99/год):** `ios-testflight.yml` → подписанная сборка прямо
  в App Store Connect, тестеры получают пуш в TestFlight за 10–15 минут.

## Замена mock на EMIS
1. Создать `EmisApiClient` с методами как у `MockEmisRepository`.
2. Подставить в `AppState` вместо mock.
3. Добавить авторизацию родителя (логин/пароль EMIS, токен в secure storage).
