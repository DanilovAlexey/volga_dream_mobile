import 'package:flutter_test/flutter_test.dart';
import 'package:volga_dream/main.dart';

void main() {
  testWidgets('App shows Volga Dream title', (WidgetTester tester) async {
    await tester.pumpWidget(const VolgaDreamApp());
    expect(find.text('Volga Dream'), findsOneWidget);
  });
}
