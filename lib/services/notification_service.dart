import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'service_interfaces.dart';

class NotificationService implements INotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: settings);
  }

  @override
  Future<bool> scheduleReminder({
    required String activityId,
    required String title,
    required String body,
    required DateTime startTime,
    int minutesBefore = 15,
  }) async {
    final notifyTime = startTime.subtract(Duration(minutes: minutesBefore));

    if (notifyTime.isBefore(DateTime.now())) {
      return false;
    }

    final androidDetails = AndroidNotificationDetails(
      'cruise_reminders',
      'Напоминания о круизе',
      channelDescription: 'Уведомления о предстоящих мероприятиях',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = activityId.hashCode;
    final tzTime = tz.TZDateTime.from(notifyTime, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    return true;
  }

  @override
  Future<void> cancelReminder(String activityId) async {
    await _plugin.cancel(id: activityId.hashCode);
  }

  @override
  void dispose() {
    _plugin.cancelAll();
  }
}
