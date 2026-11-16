import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:excess_baggage_calculator/main.dart';

void main() {
  const cases = [
    _CalculationCase(
      name: 'economy with excess weight',
      weight: '25',
      ticketClass: 'Economy Class',
      rate: '15',
      expectedExcessWeight: '5.00 kg',
      expectedCharge: 'RM 75.00',
      expectedTotal: 'RM 81.00',
    ),
    _CalculationCase(
      name: 'economy within allowance',
      weight: '18',
      ticketClass: 'Economy Class',
      rate: '15',
      expectedExcessWeight: '0.00 kg',
      expectedCharge: 'RM 0.00',
      expectedTotal: 'RM 0.00',
    ),
    _CalculationCase(
      name: 'business with excess weight',
      weight: '55',
      ticketClass: 'Business Class',
      rate: '12',
      expectedExcessWeight: '15.00 kg',
      expectedCharge: 'RM 180.00',
      expectedTotal: 'RM 194.40',
    ),
    _CalculationCase(
      name: 'business with decimal excess weight',
      weight: '42.5',
      ticketClass: 'Business Class',
      rate: '12',
      expectedExcessWeight: '2.50 kg',
      expectedCharge: 'RM 30.00',
      expectedTotal: 'RM 32.40',
    ),
  ];

  for (final calculationCase in cases) {
    testWidgets('calculates ${calculationCase.name}', (tester) async {
      await tester.pumpWidget(const ExcessBaggageCalculatorApp());

      await tester.enterText(find.byKey(const ValueKey('weightField')), calculationCase.weight);
      if (calculationCase.ticketClass == 'Business Class') {
        final classDropdown = find.byKey(const ValueKey('classDropdown'));
        await tester.ensureVisible(classDropdown);
        await tester.tap(classDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Business Class').last);
        await tester.pumpAndSettle();
      }
      final rateField = find.byKey(const ValueKey('rateField'));
      await tester.ensureVisible(rateField);
      await tester.enterText(rateField, calculationCase.rate);
      final calculateButton = find.text('Calculate Fee');
      await tester.ensureVisible(calculateButton);
      await tester.tap(calculateButton);
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.byKey(const ValueKey('Excess weight'))).data,
        calculationCase.expectedExcessWeight,
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('Excess charge'))).data,
        calculationCase.expectedCharge,
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('totalPayable'))).data,
        calculationCase.expectedTotal,
      );
    });
  }

  testWidgets('rejects invalid input without showing a calculated total', (tester) async {
    await tester.pumpWidget(const ExcessBaggageCalculatorApp());
    await tester.enterText(find.byKey(const ValueKey('weightField')), '0');
    final rateField = find.byKey(const ValueKey('rateField'));
    await tester.ensureVisible(rateField);
    await tester.enterText(rateField, '15');
    final calculateButton = find.text('Calculate Fee');
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    expect(find.text('The baggage weight must be greater than zero.'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const ValueKey('totalPayable'))).data, '—');
  });

  testWidgets('stacks result cards on narrow mobile screens without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ExcessBaggageCalculatorApp());
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('Excess weight')),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    final weightRect = tester.getRect(find.byKey(const ValueKey('Excess weight')));
    final chargeRect = tester.getRect(find.byKey(const ValueKey('Excess charge')));
    final totalRect = tester.getRect(find.byKey(const ValueKey('totalPayable')));
    expect(chargeRect.top, greaterThan(weightRect.bottom));
    expect(totalRect.right, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('places result cards side by side on desktop screens', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ExcessBaggageCalculatorApp());

    final weightRect = tester.getRect(find.byKey(const ValueKey('Excess weight')));
    final chargeRect = tester.getRect(find.byKey(const ValueKey('Excess charge')));
    expect(weightRect.top, chargeRect.top);
    expect(chargeRect.left, greaterThan(weightRect.right));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the two result cards side by side on tablet screens', (tester) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ExcessBaggageCalculatorApp());

    final weightRect = tester.getRect(find.byKey(const ValueKey('Excess weight')));
    final chargeRect = tester.getRect(find.byKey(const ValueKey('Excess charge')));
    expect(weightRect.top, chargeRect.top);
    expect(chargeRect.left, greaterThan(weightRect.right));
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigates from Home to About and back to Home', (tester) async {
    await tester.pumpWidget(const ExcessBaggageCalculatorApp());

    expect(find.text('Trip details'), findsOneWidget);
    await tester.tap(find.text('About').first);
    await tester.pumpAndSettle();
    expect(find.text('Author information'), findsOneWidget);

    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
    expect(find.text('Trip details'), findsOneWidget);
  });

  testWidgets('shows author information and a tappable planned repository URL', (tester) async {
    await tester.pumpWidget(const ExcessBaggageCalculatorApp());
    await tester.tap(find.text('About').first);
    await tester.pumpAndSettle();

    expect(find.text('Anis Natasya Binti Mohamad Nasir'), findsOneWidget);
    expect(find.text('2023466258'), findsOneWidget);
    expect(
      find.text('CS266 BACHELOR OF INFORMATION SYSTEMS (HONS.) INFORMATION SYSTEMS ENGINEERING'),
      findsOneWidget,
    );
    expect(find.text('© 2026 Excess Baggage Calculator. All Rights Reserved.'), findsOneWidget);
    expect(
      find.text('https://github.com/anixnataxya/excess-baggage-calculator'),
      findsOneWidget,
    );

    final repositoryLink = find.byKey(const ValueKey('githubRepositoryLink'));
    expect(repositoryLink, findsOneWidget);
    await tester.ensureVisible(repositoryLink);
    await tester.tap(repositoryLink);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('About page fits mobile, tablet and desktop widths', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in [320.0, 800.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const ExcessBaggageCalculatorApp());
      await tester.tap(find.text('About').first);
      await tester.pumpAndSettle();

      expect(find.text('Author information'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'About page at $width px');
    }
  });

  testWidgets('shows and operates the correct navigation on mobile and desktop widths', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in [390.0, 800.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const ExcessBaggageCalculatorApp());

      final useRail = width >= 600;
      final navigation = find.byKey(
        ValueKey(useRail ? 'desktopNavigationRail' : 'mobileNavigationBar'),
      );
      expect(navigation, findsOneWidget, reason: 'Navigation visible at $width px');
      expect(
        useRail
            ? tester.widget<NavigationRail>(navigation).selectedIndex
            : tester.widget<NavigationBar>(navigation).selectedIndex,
        0,
      );

      await tester.tap(find.text('About').first);
      await tester.pumpAndSettle();
      expect(find.text('Author information'), findsOneWidget);
      expect(
        useRail
            ? tester.widget<NavigationRail>(navigation).selectedIndex
            : tester.widget<NavigationBar>(navigation).selectedIndex,
        1,
      );

      await tester.tap(find.text('Home').first);
      await tester.pumpAndSettle();
      expect(find.text('Trip details'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Navigation interaction at $width px');
    }
  });
}

class _CalculationCase {
  const _CalculationCase({
    required this.name,
    required this.weight,
    required this.ticketClass,
    required this.rate,
    required this.expectedExcessWeight,
    required this.expectedCharge,
    required this.expectedTotal,
  });

  final String name;
  final String weight;
  final String ticketClass;
  final String rate;
  final String expectedExcessWeight;
  final String expectedCharge;
  final String expectedTotal;
}
