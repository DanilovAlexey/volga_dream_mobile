# AGENTS.md

## Проект

Прототип Flutter-приложения **Volga Dream** — расписание круиза по Волге.
Мультиплатформенное: Android, iOS, Linux, macOS, web, Windows.

- **Видение продукта:** `.opencode/plans/start.md` — прочитать перед работой
- **Точка входа:** `lib/main.dart` → `NextTourScreen` (стартовый экран)
- **SDK:** Dart ^3.11.5, Flutter stable
- **Линтер:** `package:flutter_lints/flutter.yaml` — кастомные правила в `analysis_options.yaml` закомментированы
- **Тема:** Material Design 3, seed `Color(0xFF0C484C)` (фирменный цвет бренда из логотипа), gold accent `Color(0xFFbbab8e)` (из CSS сайта)
- **Тема описана в:** `lib/main.dart` — `theme:` блок `ThemeData` с кастомными:
  - `textTheme`: заголовки — Goldenbook, body — Raleway (через `GoogleFonts.ralewayTextTheme()`)
  - `filledButtonTheme`: стиль как на сайте (uppercase, letter-spacing, border-radius 3px)
  - Цвета: `display`/`headline`/`title` — `#202024`, body — из `colorScheme.onSurface`

## Архитектура

```
lib/
  models/
    cruise.dart       # Activity, DayItinerary, Cruise (с JSON-сериализацией)
    tour.dart         # TourInfo (id UUID, name, shipName, startDate, endDate)
  screens/
    next_tour_screen.dart        # Стартовый экран: hero-секция + название тура
    schedule_screen.dart         # Расписание с TabBar по дням
    activity_detail_screen.dart  # Детали активности
  services/
    service_interfaces.dart      # ITourService, ICruiseService — абстракции
    service_locator.dart         # ServiceLocator — фабрика сервисов (--dart-define USE_MOCKS)
    tour_service.dart            # Мок TourService (implements ITourService)
    tour_api_service.dart        # HTTP TourApiService (implements ITourService)
    cruise_service.dart          # Мок CruiseService (implements ICruiseService)
    cruise_api_service.dart      # HTTP CruiseApiService (implements ICruiseService)
```

**Навигация:** `NextTourScreen` → (кнопка "Подробнее") → `ScheduleScreen` → (onTap) → `ActivityDetailScreen`

**Сервисы подменяются через `ServiceLocator`** в `main.dart` в зависимости от `--dart-define=USE_MOCKS`:
- `true` — моки (`TourService` + `CruiseService`) — данные вшиты, без сервера
- `false` / не указан — реальные HTTP (`TourApiService` на `localhost:8080/cruise/nearest` + `CruiseApiService` на `localhost:8080/cruise`)

Экраны принимают сервисы через конструктор (инъекция):
```dart
NextTourScreen(tourService:, cruiseService:)
ScheduleScreen(cruiseService:)
```

**Нет state management** (setState), **нет роутинга** (Navigator.push).
Новые экраны, сервисы и модели добавлять в соответствующие директории.

## CORS (Chrome)

При локальном запуске в Chrome `Image.network()` может выдавать CORS-ошибку из-за ограничений браузера. Чтобы избежать этого, используй в мок-данных `imageUrl` с реального сервера, который отдаёт корректные заголовки:
```
https://volgadream.ru/wp-content/uploads/2024/10/znakomstvo-s-volgoj-gl-2026-scaled.webp
```

Альтернатива — запускать Chrome без CORS:
```powershell
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

## Команды (PowerShell)

```powershell
flutter pub get                          # зависимости (http, cupertino_icons, flutter_lints)
flutter analyze                          # линтер + типы
flutter test                             # все тесты
flutter test test/widget_test.dart       # конкретный тест
flutter run                              # запуск (реальный сервер)
flutter run --dart-define=USE_MOCKS=true  # запуск с моками (без сервера)
flutter run -d chrome --dart-define=USE_MOCKS=true  # Chrome + моки
flutter build apk                        # сборка APK
```

## Тесты

- Единственный файл: `test/widget_test.dart` — проверяет, что NextTourScreen показывает ошибку загрузки (нет сервера в тестах) и кнопку повтора
- Нет интеграционных тестов, фикстур, тестовых сервисов
- При добавлении фич писать widget-тесты по тому же шаблону

## Шрифты

- **Goldenbook** (кастомный woff2 с сайта) — для заголовка "VOLGA DREAM"
- Bundled как asset-шрифты в `pubspec.yaml`:
  ```yaml
  fonts:
    - family: Goldenbook
      fonts:
        - asset: assets/fonts/Goldenbook.woff2
        - asset: assets/fonts/Goldenbook-light.woff2
          weight: 300
  ```
- Файлы: `assets/fonts/Goldenbook.woff2` (regular), `assets/fonts/Goldenbook-light.woff2` (weight 300)
- **Raleway** — для body-текста (через `GoogleFonts.ralewayTextTheme()` в `main.dart`)
- **Montserrat** — резервный шрифт (загружается сайтом, но в приложении не используется)
- `google_fonts` версии 8.1.0 в зависимостях — для загрузки Raleway

## Стиль

- Стандартный Material Design 3 (MaterialApp, Scaffold), сине-голубая тема
- Dart: `camelCase`, `const`-конструкторы, `super.key`
- При добавлении пакетов — сначала `flutter pub add`
