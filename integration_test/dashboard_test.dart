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
      
      // Verify the Quick Actions section is visible
      final quickActionsTitle = find.text('Aksi Cepat');
      expect(quickActionsTitle, findsOneWidget, reason: 'Quick Actions section not found');
      
      // Test each quick action button with better error handling
      await _testQuickAction(tester, 'Buat Invoice', 'Invoice');
      await _testQuickAction(tester, 'Tambah Produk', 'Produk');  
      await _testQuickAction(tester, 'Buka Keyboard', 'Keyboard');
      await _testQuickAction(tester, 'Hitung Ongkir', 'Hitung Ongkir');
    });
  });
}

/// Helper method to test quick action buttons with better error handling
Future<void> _testQuickAction(WidgetTester tester, String buttonText, String expectedScreenText) async {
  try {
    // Find the button
    final buttonFinder = find.text(buttonText);
    expect(buttonFinder, findsOneWidget, reason: 'Button "$buttonText" not found');
    
    // Scroll to make the button visible if needed
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();
    
    // Additional check to verify button is actually tappable
    final buttonWidget = tester.widget(buttonFinder);
    expect(buttonWidget, isNotNull, reason: 'Button widget "$buttonText" is null');
    
    // Tap the button
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    
    // Verify navigation occurred by checking for expected screen content
    if (expectedScreenText == 'Produk') {
      expect(find.text(expectedScreenText), findsWidgets, reason: 'Expected screen "$expectedScreenText" not found after tapping "$buttonText"');
    } else {
      expect(find.text(expectedScreenText), findsOneWidget, reason: 'Expected screen "$expectedScreenText" not found after tapping "$buttonText"');
    }
    
    // Navigate back to dashboard
    await tester.pageBack();
    await tester.pumpAndSettle();
    
    // Verify we're back on the dashboard
    expect(find.text('Aksi Cepat'), findsOneWidget, reason: 'Failed to return to dashboard after testing "$buttonText"');
    
  } catch (e) {
    throw Exception('Failed testing quick action "$buttonText": $e');
  }
}
