# AGENTS.md

## Проект

Прототип Flutter-приложения **Volga Dream** — расписание круиза по Волге.
Мультиплатформенное: Android, iOS, Linux, macOS, web, Windows.

- **Видение продукта:** `.opencode/plans/start.md` — прочитать перед работой
- **Точка входа:** `lib/main.dart`
- **SDK:** Dart ^3.11.5, Flutter stable
- **Тема:** Material Design 3, seed `Color(0xFF0D4F6E)` (сине-голубая)
- **Линтер:** `package:flutter_lints/flutter.yaml` — все кастомные правила в `analysis_options.yaml` закомментированы

## Архитектура (прототип)

```
lib/
  models/cruise.dart       # Activity, DayItinerary, Cruise
  screens/                 # schedule_screen, activity_detail_screen
  services/cruise_service  # CruiseService.getMockCruise() — мок-данные
```

- **Нет state management** (setState), **нет роутинга** (Navigator.push), **нет бэкенда** (мок-сервис)
- Новые экраны, сервисы и модели добавлять в соответствующие директории

## Команды

```powershell
flutter pub get                          # установить зависимости (нет сторонних пакетов, только Flutter SDK + flutter_lints)
flutter analyze                          # статический анализ (линтер + типы)
flutter test                             # все тесты
flutter test test/widget_test.dart       # конкретный тест
flutter run                              # запуск на устройстве/эмуляторе
flutter build apk                        # сборка APK
```

## Тесты

- Единственный файл: `test/widget_test.dart` (проверяет наличие "Volga Dream")
- Нет интеграционных тестов, фикстур, тестовых сервисов
- При добавлении фич писать widget-тесты по тому же шаблону

## Стиль

- Стандартный Material Design 3 (MaterialApp, Scaffold)
- Dart: `camelCase`, `const`-конструкторы, `super.key`
- При добавлении пакетов (state management, routing) — сначала `flutter pub add`
