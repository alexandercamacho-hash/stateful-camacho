import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stateful_lab_camacho/main.dart';

void main() {
  testWidgets(
    'preloads items, updates the total and respects quantity limits',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CartScreen()));

      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Total: PHP 311.00'), findsOneWidget);

      // Rice: 60.00 x 2 becomes 60.00 x 3, so the total grows by 60.00.
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(CartItemTile, 'Rice'),
          matching: find.byTooltip('Increase quantity'),
        ),
      );
      await tester.pump();
      expect(find.text('Total: PHP 371.00'), findsOneWidget);

      // Milk is already at the minimum of 1, so the minus button is disabled.
      final Finder milkTile = find.widgetWithText(CartItemTile, 'Milk');
      await tester.tap(
        find.descendant(
          of: milkTile,
          matching: find.byTooltip('Decrease quantity'),
        ),
      );
      await tester.pump();
      expect(
        find.descendant(of: milkTile, matching: find.text('1')),
        findsOneWidget,
      );
      expect(find.text('Total: PHP 371.00'), findsOneWidget);
    },
  );

  testWidgets('validates input, adds an item and clears checked items', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CartScreen()));

    // Empty form: both fields should show their validation message.
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    expect(find.text('Enter an item name'), findsOneWidget);
    expect(find.text('Enter a price greater than 0'), findsOneWidget);

    // Invalid price: the name is fine but the price is not.
    await tester.enterText(find.byType(TextField).at(0), 'Bread');
    await tester.enterText(find.byType(TextField).at(1), 'abc');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    expect(find.text('Enter an item name'), findsNothing);
    expect(find.text('Enter a price greater than 0'), findsOneWidget);

    // Valid input: the item is added, the fields are cleared and the total
    // includes the new line (311.00 + 25.50).
    await tester.enterText(find.byType(TextField).at(1), '25.50');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    expect(find.text('Bread'), findsOneWidget);
    expect(find.text('Total: PHP 336.50'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      isEmpty,
    );

    // Eggs is pre-checked, so clearing removes it.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Clear checked'));
    await tester.pump();
    expect(find.text('Eggs'), findsNothing);
    expect(find.text('Total: PHP 240.50'), findsOneWidget);

    // Let the SnackBars finish so no timers are left pending.
    await tester.pump(const Duration(seconds: 5));
  });
}
