import 'package:aquarythu/features/auth/auth_provider.dart';
import 'package:aquarythu/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

// 1. Create a Mock for AuthNotifier
class MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  late MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
  });

  testWidgets('LoginScreen enters text and calls signIn', (WidgetTester tester) async {
    // 2. Setup the mock behavior
    when(() => mockAuthNotifier.signIn(any(), any()))
        .thenAnswer((_) async => true);

    // 3. Build the LoginScreen wrapped in the Provider
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthNotifier>.value(
          value: mockAuthNotifier,
          child: const LoginScreen(),
        ),
      ),
    );

    // 4. Find widgets
    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');

    // 5. Interact with widgets
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(loginButton);

    // 6. Rebuild to process the tap
    await tester.pump();

    // 7. Verify that signIn was called with correct values
    verify(() => mockAuthNotifier.signIn('test@example.com', 'password123')).called(1);
  });

  testWidgets('LoginScreen shows error snackbar on failure', (WidgetTester tester) async {
    // Setup mock to fail
    when(() => mockAuthNotifier.signIn(any(), any()))
        .thenAnswer((_) async => false);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthNotifier>.value(
          value: mockAuthNotifier,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'fail@test.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    
    // Pump frames to allow async operation to complete and SnackBar to appear
    await tester.pumpAndSettle();

    // Verify SnackBar appears
    expect(find.text('Login failed. Please check your credentials.'), findsOneWidget);
  });
}