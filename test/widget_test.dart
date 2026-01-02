import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Dummy widget test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('OK'),
        ),
      ),
    );

    expect(find.text('OK'), findsOneWidget);
  });
}
