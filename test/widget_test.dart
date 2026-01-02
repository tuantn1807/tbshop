import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tbshop/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(MyApp());

    // Kiểm tra app có MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
