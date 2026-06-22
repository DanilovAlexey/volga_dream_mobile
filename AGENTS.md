# AGENTS.md

## Проект

Прототип Flutter-приложения **Volga Dream** — расписание круиза по Волге.
Мультиплатформенное: Android, iOS, Linux, macOS, web, Windows.

- **Видение продукта:** `.opencode/plans/start.md` — прочитать перед работой
- **Точка входа:** `lib/main.dart` → `NextTourScreen` (стартовый экран)
- **SDK:** Dart ^3.11.5, Flutter stable
- **Линтер:** `package:flutter_lints/flutter.yaml` — кастомные правила в `analysis_options.yaml` закомментированы
- **Тема:** Material Design 3, seed `Color(0xFF0C484C)`, gold accent `Color(0xFFbbab8e)`
  - `textTheme`: заголовки — Goldenbook (bundled asset), body — Raleway (GoogleFonts)
  - `filledButtonTheme`: uppercase, letter-spacing 2.2, border-radius 3px
  - Цвета: `display`/`headline`/`title` — `#202024`, body — из `colorScheme.onSurface`

## Архитектура

```
lib/
  models/
    cruise.dart       # Activity, DayItinerary, Cruise (JSON serialization)
    tour.dart         # TourInfo (scheduleId, name, shipName, dates, imageUrl)
  screens/
    next_tour_screen.dart        # Hero section + tour info
    schedule_screen.dart         # TabBar per day
    activity_detail_screen.dart  # Activity details
  services/
    service_interfaces.dart      # ITourService, ICruiseService
    service_locator.dart         # Factory: --dart-define=USE_MOCKS
    {tour,cruise}_service.dart   # Mocks (hardcoded data, Russian)
    {tour,cruise}_api_service.dart  # HTTP (localhost:8080)
```

**Навигация:** `NextTourScreen` → (кнопка "Подробнее") → `ScheduleScreen` → (onTap) → `ActivityDetailScreen`

**Mock toggle:** `--dart-define=USE_MOCKS=true` (default false = localhost:8080)
- Mock tour dates: 2026-07-01 to 2026-07-05 (фиксированные — важно для тестов)
- `HttpException` класс: `lib/services/cruise_api_service.dart:42`

**Сервисы через конструктор:**
```dart
NextTourScreen(tourService:, cruiseService:)
ScheduleScreen(cruiseService:)
```

**Нет state management** (setState), **нет роутинга** (Navigator.push).

## CORS (Chrome)

`Image.network()` может выдавать CORS в Chrome. Использовать либо реальный URL в `imageUrl` с корректными заголовками, либо запускать без CORS:
```powershell
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

## Команды (PowerShell)

```powershell
flutter pub get
flutter analyze                          # линтер + типы
flutter test                             # все тесты
flutter test test/widget_test.dart       # конкретный тест
flutter run                              # реальный сервер
flutter run --dart-define=USE_MOCKS=true  # моки, без сервера
flutter run -d chrome --dart-define=USE_MOCKS=true  # Chrome + моки
flutter build apk
flutter clean
```

## Тесты

- Единственный файл: `test/widget_test.dart` — русские строки: `'Не удалось загрузить информацию о туре'`, `'Повторить'`
- Проверяет, что NextTourScreen показывает ошибку загрузки (нет сервера в тестах) + кнопку повтора
- При добавлении фич писать widget-тесты по тому же шаблону

## Шрифты

- **Goldenbook** — кастомный, bundled в `pubspec.yaml`. Файлы: `assets/fonts/Goldenbook.{ttf,woff2}` (regular) + `Goldenbook-light.woff2` (weight 300)
- **Raleway** — body (через `GoogleFonts.ralewayTextTheme()`, пакет `google_fonts: ^8.1.0`)
- **Montserrat** — загружается сайтом, в приложении не используется

## Стиль

- Material Design 3 (MaterialApp, Scaffold)
- `const`-конструкторы, `super.key`
- Новые пакеты — через `flutter pub add`
- Новые экраны, сервисы и модели — в соответствующие директории `lib/`
