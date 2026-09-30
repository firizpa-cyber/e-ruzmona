# Установка E-Ruznoma через Apple TestFlight — пошаговая инструкция

> Честно про «бесплатно»: сама загрузка в TestFlight требует платный
> **Apple Developer Program ($99/год)** — обойти это нельзя, Apple не даёт
> бесплатного TestFlight. Всё остальное уже сделано бесплатно:
> Flutter SDK установлен, проект собирается, Web-версия готова,
> CI-файлы настроены. Ниже — что бесплатно, а за что платит только Apple.

## Статус готовности (выполнено локально 30.09.2026)
- [x] Flutter 3.47.5 установлен (`D:\flutter`), `flutter doctor` OK
- [x] `flutter pub get`, `flutter analyze` — чисто, `flutter test` — пройдены
- [x] `flutter build web --release` — собран `build/web/`
- [x] `ios/` сгенерирован, Bundle ID `tj.emis.eRuzmona`
- [ ] Сборка IPA — только на облачном Mac (Windows не умеет собирать iOS)
- [ ] Загрузка в TestFlight — только с платным Apple Developer

Приложение распространяется **строго через TestFlight** (без App Store review для тестеров).

## Что нужно пользователю
1. iPhone/iPad с iOS 16+
2. Apple ID
3. Приложение **TestFlight** из App Store (бесплатно)
4. Приглашение: ссылка или email от разработчика

## Шаги установки
1. Установите **TestFlight**:
   App Store → поиск «TestFlight» → Загрузить.
2. Откройте **пригласительную ссылку** (её присылает разработчик)
   или примите приглашение по email → кнопка **View in TestFlight**.
3. В TestFlight нажмите **Accept / Принять** → **Install / Установить**.
4. Дождитесь загрузки → **Open / Открыть**.
5. Войдите в аккаунт родителя → выберите ребёнка в шапке
   (переключение между детьми — в один клик).
6. Обновления приходят в тот же TestFlight → кнопка **Update**.

## Частые вопросы
- **«Не открывается ссылка»** — открывайте её именно на iPhone в Safari,
  должен быть вход в Apple ID.
- **«Build expired / срок истёк»** — каждая сборка живёт 90 дней.
  Попросите новую ссылку или обновитесь в TestFlight.
- **«Redeem code»** — если дали код вместо ссылки: TestFlight → Redeem → ввести код.
- **Нет уведомлений TestFlight** — Настройки iPhone → TestFlight → Уведомления → Вкл.

## Для разработчика: как отправить сборку
### Вариант A — GitHub Actions (рекомендуется)
1. Купите **Apple Developer Program** ($99/год) → developer.apple.com.
   Бесплатного TestFlight не существует — это единственный платный шаг.
2. В App Store Connect создайте App → Bundle ID `tj.emis.eRuzmona`
   (уже прописан в `ios/Runner.xcodeproj`, менять не нужно).
3. Создайте API-ключ: App Store Connect → Users and Access → Integrations →
   App Store Connect API → Team Key. Сохраните Issuer ID, Key ID, .p8.
4. В GitHub → Settings → Secrets добавьте:
   `APPLE_TEAM_ID`, `APPSTORE_ISSUER_ID`,
   `APPSTORE_KEY_ID`, `APPSTORE_PRIVATE_KEY` (содержимое .p8).
   Workflow `.github/workflows/ios-testflight.yml` уже обновлён:
   analyze+tests, генерация ExportOptions.plist, `flutter build ipa`,
   загрузка `build/ios/ipa/Runner.ipa` через `upload-testflight-build@v3`.
5. Push в `main` → Actions → `iOS TestFlight`: GitHub поднимает виртуальный Mac,
   собирает подписанную сборку и по API-ключу передаёт её в App Store Connect.
   Через 10–15 минут автоматической обработки в Apple тестеры получат
   пуш-уведомление в TestFlight с предложением обновить приложение.
6. App Store Connect → TestFlight → добавить группу тестеров
   (Internal 1-100 чел. без ревью, External — с Beta Review) →
   разослать ссылку.

### Вариант B — Codemagic (без своего Mac)
1. Зарегистрируйтесь на codemagic.io → Add app → выбрать репо.
2. Подключите **App Store Connect integration** (Issuer ID + Key ID + .p8).
3. Workflow `ios-testflight` из `codemagic.yaml` уже готов:
   `flutter build ipa` → `submit_to_testflight: true`.
4. Start build → сборка появится в TestFlight за 10–20 мин.

## Вариант 1. Бесплатный «TestFlight» (без $99): GitHub Actions + Sideloadly/Diawi/Firebase

Файл `.github/workflows/deploy_ios_free.yml` уже создан. Вся сборка происходит
автоматически при пуше в `main` — нужен только бесплатный GitHub-аккаунт
(для публичного репо минуты macOS-раннера бесплатные).

### Как происходит деплой
1. Вы делаете `git push origin main`.
2. GitHub поднимает виртуальный Mac и за 3–5 минут собирает
   **неподписанную** IPA: `flutter build ipa --no-codesign`
   (подпись невозможна без платного Apple Developer — она делается позже на ПК).
3. Готовая `.ipa` кладётся в **Actions → Artifacts** (`ios-build-free`, хранится 14 дней).

### Как установить на iPhone (бесплатно, на выбор)
- **Вариант Б — через ПК (самый простой):** скачайте `.ipa` из Artifacts →
  установите через **Sideloadly** (Windows/Mac, нужен обычный бесплатный Apple ID).
  Sideloadly сам подпишет приложение вашим ID. Сертификат живёт 7 дней,
  потом повторить установку (5 минут). Подходит для 1–3 своих устройств.
- **Вариант В — по ссылке/QR:** загрузите `.ipa` на **Diawi.com** →
  получите ссылку и QR-код для тестера. Либо задайте секрет `DIAWI_TOKEN`
  в GitHub — тогда workflow сам зальёт сборку на Diawi при каждом пуше.
- **Вариант А — Firebase App Distribution:** создайте бесплатный проект в
  Firebase Console → добавьте iOS-приложение → Service Account key (JSON) →
  положите в секреты `GCP_SA_KEY` (содержимое JSON) и `FIREBASE_IOS_APP_ID`.
  Тогда workflow сам разошлёт сборку группе `testers`.
  Честная оговорка: Firebase лишь раздаёт файл — установка неподписанной IPA
  на iPhone всё равно идёт через Sideloadly (см. выше).

### Важно
- Локально на Windows iOS IPA **не собрать** — только облачный Mac (Actions/Codemagic).
  Папка `ios/` уже сгенерирована локально (`flutter create`), CI ничего не догенерирует.
- Bundle ID `tj.emis.eRuzmona` должен совпадать везде: Xcode, App Store Connect, CI-секреты.
- Прочие бесплатные раздачи без Apple:
  - Web-версия: https://web-five-teal-bmrwp838zu.vercel.app
    (пересборка: `flutter build web --release` → `npx vercel deploy ./build/web --prod`).
  - Android APK для тестеров: `flutter build apk --release` — бесплатно, без Apple.

## Вариант 2. Настоящий TestFlight (когда купите Apple Developer $99/год)

## Web на Vercel (бесплатно, работает сейчас)
1. `vercel login`
2. `npx vercel deploy ./build/web --prod --yes`
   (`vercel.json` уже настроен: `outputDirectory: build/web` + SPA-rewrite на `/index.html`).
3. Пересборка после правок: `flutter build web --release` → повторить deploy.
