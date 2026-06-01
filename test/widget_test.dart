import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fem_health/main.dart';

void main() {
  testWidgets('Onboarding screen renders on first launch', (WidgetTester tester) async {
    await tester.pumpWidget(const FemHealthApp());
    await tester.pumpAndSettle();

    // Should show onboarding since no shared preferences data exists
    expect(find.text('FemHealth'), findsOneWidget);
    expect(find.textContaining('companion'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Onboarding navigation works to step 2', (WidgetTester tester) async {
    await tester.pumpWidget(const FemHealthApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Why track with us?'), findsOneWidget);
    expect(find.text('Period Tracking'), findsOneWidget);
  });
}
