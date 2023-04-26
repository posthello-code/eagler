import 'package:eagler/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('there should be a "start" button for sheduling requests',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(RequesterPage());
    await tester.pumpAndSettle();
    // find the login button
    dynamic loginButton = find.widgetWithText(ElevatedButton, 'Send');
    // verify that the login button is present
    expect(loginButton, findsOneWidget);
  });
}
