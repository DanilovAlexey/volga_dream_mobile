import 'package:flutter_test/flutter_test.dart';
import 'package:volga_dream/main.dart';
import 'package:volga_dream/services/service_interfaces.dart';

class _MockNotificationService implements INotificationService {
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> scheduleReminder({
    required String activityId,
    required String title,
    required String body,
    required DateTime startTime,
    int minutesBefore = 15,
  }) async => true;
  @override
  Future<void> showTestNotification() async {}
  @override
  Future<void> cancelReminder(String activityId) async {}
  @override
  void dispose() {}
}

void main() {
  testWidgets('App shows next tour screen on launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(VolgaDreamApp(
      notificationService: _MockNotificationService(),
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Не удалось загрузить информацию о туре'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });
}
