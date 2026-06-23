import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._();
  static ReminderService get instance => _instance;
  ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  SharedPreferences? _prefs;
  bool _initialized = false;
  final Map<String, Timer> _timers = {};

  Future<void> initialize() async {
    if (_initialized) return;
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: initSettings);
    _initialized = true;

    _restoreTimers();
  }

  void _restoreTimers() {
    final json = _prefs?.getString('reminders');
    if (json == null || json.isEmpty) return;
    final list = jsonDecode(json) as List<dynamic>;
    final reminders = list
        .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
        .where((r) => r.notifyAt.isAfter(DateTime.now()));
    for (final r in reminders) {
      _startTimer(r);
    }
  }

  void _startTimer(Reminder reminder) {
    _timers[reminder.id]?.cancel();
    final delay = reminder.notifyAt.difference(DateTime.now());
    if (delay <= Duration.zero) return;
    _timers[reminder.id] = Timer(delay, () {
      _fireNotification(reminder);
      _timers.remove(reminder.id);
    });
  }

  void _cancelTimer(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  Future<void> _fireNotification(Reminder reminder) async {
    await _plugin.show(
      id: reminder.id.hashCode,
      title: 'Volga Dream',
      body: '${reminder.activityTitle} начнётся через ${reminder.minutesBefore} мин.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Напоминания',
          channelDescription: 'Напоминания о событиях круиза',
          importance: Importance.high,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb || !Platform.isAndroid) return true;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return true;

    await androidPlugin.requestNotificationsPermission();
    await androidPlugin.requestExactAlarmsPermission();
    return true;
  }

  Future<List<Reminder>> getReminders() async {
    final json = _prefs?.getString('reminders');
    if (json == null || json.isEmpty) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => Reminder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<bool> hasReminder(String activityId) async {
    final reminders = await getReminders();
    return reminders.any((r) => r.activityId == activityId);
  }

  Future<int?> getReminderMinutes(String activityId) async {
    final reminders = await getReminders();
    final found = reminders.where((r) => r.activityId == activityId);
    if (found.isEmpty) return null;
    return found.first.minutesBefore;
  }

  Future<void> setReminder(Reminder reminder) async {
    final reminders = await getReminders();
    reminders.removeWhere((r) => r.id == reminder.id);
    reminders.add(reminder);
    await _saveAll(reminders);
    _startTimer(reminder);
    await _scheduleAlarm(reminder);
  }

  Future<void> removeReminder(String id) async {
    _cancelTimer(id);
    final reminders = await getReminders();
    reminders.removeWhere((r) => r.id == id);
    await _saveAll(reminders);
    await _cancelAlarm(id);
  }

  Future<void> removeReminderByActivity(String activityId) async {
    final reminders = await getReminders();
    final toRemove = reminders.where((r) => r.activityId == activityId).toList();
    reminders.removeWhere((r) => r.activityId == activityId);
    await _saveAll(reminders);
    for (final r in toRemove) {
      _cancelTimer(r.id);
      await _cancelAlarm(r.id);
    }
  }

  Future<void> _saveAll(List<Reminder> reminders) async {
    final json = jsonEncode(reminders.map((r) => r.toJson()).toList());
    await _prefs?.setString('reminders', json);
  }

  Future<void> showTestNotification() async {
    await requestPermissions();

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: 'Volga Dream',
      body: 'Тестовое уведомление',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Напоминания',
          channelDescription: 'Напоминания о событиях круиза',
          importance: Importance.high,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> _scheduleAlarm(Reminder reminder) async {
    final scheduledDate = reminder.notifyAt;
    if (scheduledDate.isBefore(DateTime.now())) return;

    await requestPermissions();

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _plugin.zonedSchedule(
        id: reminder.id.hashCode,
        title: 'Volga Dream',
        body: '${reminder.activityTitle} начнётся через ${reminder.minutesBefore} мин.',
        scheduledDate: tzDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Напоминания',
            channelDescription: 'Напоминания о событиях круиза',
            importance: Importance.high,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      try {
        await _plugin.zonedSchedule(
          id: reminder.id.hashCode,
          title: 'Volga Dream',
          body: '${reminder.activityTitle} начнётся через ${reminder.minutesBefore} мин.',
          scheduledDate: tzDate,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminder_channel',
              'Напоминания',
              channelDescription: 'Напоминания о событиях круиза',
              importance: Importance.high,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (e) {
        debugPrint('Failed to schedule alarm: $e');
      }
    }
  }

  Future<void> _cancelAlarm(String id) async {
    await _plugin.cancel(id: id.hashCode);
  }

  static DateTime parseActivityStart(DateTime dayDate, String timeRange) {
    final startStr = timeRange.split(' – ').first.trim();
    final parts = startStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return DateTime(dayDate.year, dayDate.month, dayDate.day, hours, minutes);
  }
}
