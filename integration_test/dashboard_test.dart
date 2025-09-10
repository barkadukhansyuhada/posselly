import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:selly_clone/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard Integration Test', () {
    testWidgets('Login and verify quick actions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for the splash screen to settle.
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Use valid credentials to log in
      const email = 'syuhadabarka31@gmail.com';
      const password = 'qwerty';

      final loginButtonFinder = find.byKey(const Key('loginButton'));

      if (tester.any(loginButtonFinder)) {
        // We are on the login screen, proceed with login
        await tester.enterText(find.byType(TextField).at(0), email);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(1), password);
        await tester.pumpAndSettle();

        // Dismiss the keyboard
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Ensure the login button is visible before tapping
        await tester.ensureVisible(loginButtonFinder);
        await tester.pumpAndSettle();
        
        await tester.tap(loginButtonFinder);
        
        // Wait for navigation to the dashboard.
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // Verify we are on the dashboard.
      final bottomNavBarFinder = find.byType(BottomNavigationBar);
      expect(bottomNavBarFinder, findsOneWidget, reason: 'BottomNavigationBar not found. Login may have failed.');
      
      // Tap the "Buat Invoice" button and verify navigation
      final createInvoiceButton = find.text('Buat Invoice');
      await tester.ensureVisible(createInvoiceButton);
      await tester.pumpAndSettle();
      await tester.tap(createInvoiceButton);
      await tester.pumpAndSettle();
      expect(find.text('Invoice'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Tap the "Tambah Produk" button and verify navigation
      final addProductButton = find.text('Tambah Produk');
      await tester.ensureVisible(addProductButton);
      await tester.pumpAndSettle();
      await tester.tap(addProductButton);
      await tester.pumpAndSettle();
      expect(find.text('Produk'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Tap the "Buka Keyboard" button and verify navigation
      final openKeyboardButton = find.text('Buka Keyboard');
      await tester.ensureVisible(openKeyboardButton);
      await tester.pumpAndSettle();
      await tester.tap(openKeyboardButton);
      await tester.pumpAndSettle();
      expect(find.text('Keyboard'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    });
  });
}
