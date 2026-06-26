import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/features/auth/providers/auth_provider.dart';
import 'package:marksmanmate/features/auth/screens/login_screen.dart';

class _IdleAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(isInitializing: false);
}

void main() {
  testWidgets('Login screen shows sign-in form', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_IdleAuthNotifier.new),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
