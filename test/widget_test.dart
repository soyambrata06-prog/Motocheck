// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:motocheck/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MotoCheckApp());

    // Verify that the Home screen is displayed.
    expect(find.text('Home Screen (Tab 1)'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}


