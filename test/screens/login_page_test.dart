import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roowanglow/screens/login_page.dart';

void main() {
  group('LoginPage Tests', () {
    late LoginPage loginPage;

    setUp(() {
      loginPage = const LoginPage();
    });

    testWidgets('Login form validation works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: loginPage));

      // Test empty form submission
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Test invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Test short password
      await tester.enterText(find.byType(TextFormField).last, '12345');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('Login error handling works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: loginPage));

      // Enter error email to trigger error
      await tester.enterText(
        find.byType(TextFormField).first,
        'error@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Log In'));
      await tester.pump(const Duration(seconds: 2));

      expect(
        find.text('Invalid credentials. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('Password visibility toggle works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: loginPage));

      // Initially password should be obscured, so check the icon
      final passwordField = find.byType(TextFormField).last;

      // اختبار إذا كانت الأيقونة تمثل إخفاء كلمة المرور في البداية (يجب أن تكون العيون مغلقة)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Toggle visibility (اضغط على أيقونة العين)
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // بعد التبديل، يجب أن تظهر أيقونة العين المفتوحة
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Loading state is shown during login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: loginPage));

      // Enter valid credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      // Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for loading to complete
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
