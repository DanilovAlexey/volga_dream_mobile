# AGENTS.md

## Проект

Прототип Flutter-приложения **Volga Dream** — расписание круиза по Волге.
Мультиплатформенное: Android, iOS, Linux, macOS, web, Windows.

- **Видение продукта:** `.opencode/plans/start.md` — прочитать перед работой
- **Точка входа:** `lib/main.dart` → `NextTourScreen` (стартовый экран)
- **SDK:** Dart ^3.11.5, Flutter stable
- **Линтер:** `package:flutter_lints/flutter.yaml` — кастомные правила в `analysis_options.yaml` закомментированы
- **Тема:** Material Design 3, seed `Color(0xFF0D4F6E)`

## Архитектура

```
lib/
  models/
    cruise.dart       # Activity, DayItinerary, Cruise (с JSON-сериализацией)
    tour.dart         # TourInfo (id UUID, name, shipName, startDate, endDate)
  screens/
    next_tour_screen.dart        # Стартовый экран: название тура + дни до старта
    schedule_screen.dart         # Расписание с TabBar по дням
    activity_detail_screen.dart  # Детали активности
  services/
    cruise_service.dart     # CruiseService.getMockCruise() — мок-данные
    cruise_api_service.dart # CruiseApiService.fetchCruise() — HTTP GET /cruise на localhost:8080
    tour_service.dart       # TourService.fetchNearestTour() — мок с Future.delayed
```

**Навигация:** `NextTourScreen` → (кнопка "Подробнее") → `ScheduleScreen` → (onTap) → `ActivityDetailScreen`

**При старте:** `NextTourScreen` вызывает `TourService.fetchNearestTour()`, который имитирует два запроса:
1. `GET /tours/nearest?date=...` → UUID
2. `GET /tours/{id}` → TourInfo

**ScheduleScreen** использует `CruiseApiService.fetchCruise()` — реальный HTTP-запрос к серверу (`http://localhost:8080/cruise` по умолчанию). При отсутствии сервера показывается ошибка с кнопкой "Повторить".

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
flutter run                              # запуск
flutter build apk                        # сборка APK
```

## Тесты

- Единственный файл: `test/widget_test.dart` — проверяет, что NextTourScreen показывает "Следующий тур" и "Подробнее" после загрузки
- Нет интеграционных тестов, фикстур, тестовых сервисов
- При добавлении фич писать widget-тесты по тому же шаблону

## Стиль

- Стандартный Material Design 3 (MaterialApp, Scaffold), сине-голубая тема
- Dart: `camelCase`, `const`-конструкторы, `super.key`
- При добавлении пакетов — сначала `flutter pub add`
