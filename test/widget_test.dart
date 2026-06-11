import 'package:flutter_test/flutter_test.dart';
import 'package:volga_dream/main.dart';

void main() {
  testWidgets('App shows next tour screen on launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VolgaDreamApp());
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Следующий тур'), findsOneWidget);
    expect(find.text('Подробнее'), findsOneWidget);
  });
}
