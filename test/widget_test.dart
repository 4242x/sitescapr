import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitescapr/main.dart';

void main() {
  testWidgets('SiteScaprApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SiteScaprApp());
    // Just verify the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
