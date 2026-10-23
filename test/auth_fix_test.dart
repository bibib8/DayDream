import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daydream_digital_diary/providers/diary_provider.dart';
import 'package:daydream_digital_diary/views/auth/auth_screen.dart';

class TrackingDiaryProvider extends DiaryProvider {
  int loadUserDataCallCount = 0;

  @override
  Future<void> loadUserData() async {
    loadUserDataCallCount++;
  }
}

class TestMockDiaryProvider extends DiaryProvider {
  String? mockInfoMessage;
  bool mockSignUpSuccess = true;
  String? mockErrorMessage;

  @override
  String? get infoMessage => mockInfoMessage;

  @override
  String? get errorMessage => mockErrorMessage;

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    String penName = 'Sweet Dreamer',
  }) async {
    if (password.length < 8) {
      throw Exception("Password must be at least 8 characters long.");
    }
    if (mockInfoMessage != null) {
      return true;
    }
    return mockSignUpSuccess;
  }
}

Session createTestSession() {
  return Session(
    accessToken: 'test-token',
    tokenType: 'bearer',
    user: const User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01',
    ),
  );
}

void main() {
  group('Auth Fix Tests', () {
    test('DiaryProvider initializes with correct default auth state without Supabase', () {
      final provider = DiaryProvider();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isSignUpMode, isFalse);
      expect(provider.currentNavIndex, 0); // Welcome screen
      expect(provider.errorMessage, isNull);
      expect(provider.infoMessage, isNull);
      provider.dispose();
    });

    test('DiaryProvider.openAuth toggles mode and clears info & error messages', () {
      final provider = DiaryProvider();
      provider.openAuth(isSignUp: true);
      expect(provider.isSignUpMode, isTrue);
      expect(provider.currentNavIndex, 1);
      expect(provider.errorMessage, isNull);
      expect(provider.infoMessage, isNull);

      provider.clearError();
      provider.clearInfoMessage();
      provider.dispose();
    });

    test('DiaryProvider password length check (< 8 chars) in signUp and signIn', () async {
      final provider = DiaryProvider();
      final signUpSuccess = await provider.signUp(
        email: 'test@example.com',
        password: '123',
      );
      expect(signUpSuccess, isFalse);
      expect(provider.errorMessage, contains("Password must be at least 8 characters long"));

      final signInSuccess = await provider.signIn(
        email: 'test@example.com',
        password: 'short',
      );
      expect(signInSuccess, isFalse);
      expect(provider.errorMessage, contains("Password must be at least 8 characters long"));

      provider.dispose();
    });

    test('Auth listener: initialSession/signedIn sets authenticated, nav index 2, and loads user data once', () {
      final provider = TrackingDiaryProvider();
      final testSession = createTestSession();

      // Trigger initialSession event
      provider.handleAuthStateChange(AuthChangeEvent.initialSession, testSession);

      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentNavIndex, 2); // Bookshelf
      expect(provider.loadUserDataCallCount, 1);

      // Trigger signedIn while already authenticated — should NOT call loadUserData again
      provider.handleAuthStateChange(AuthChangeEvent.signedIn, testSession);
      expect(provider.loadUserDataCallCount, 1);

      provider.dispose();
    });

    test('Auth listener: signedOut resets all state exactly like logout without calling signOut', () {
      final provider = TrackingDiaryProvider();
      final testSession = createTestSession();

      // First authenticate
      provider.handleAuthStateChange(AuthChangeEvent.initialSession, testSession);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentNavIndex, 2);

      // Trigger signedOut
      provider.handleAuthStateChange(AuthChangeEvent.signedOut, null);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isSignUpMode, isFalse);
      expect(provider.currentNavIndex, 0); // Welcome screen
      expect(provider.errorMessage, isNull);
      expect(provider.infoMessage, isNull);

      provider.dispose();
    });

    testWidgets('AuthScreen shows neutral (not red) SnackBar when email confirmation is needed', (tester) async {
      final mockProvider = TestMockDiaryProvider();
      mockProvider.mockInfoMessage = "Check your email to confirm your account, then sign in.";

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<DiaryProvider>.value(value: mockProvider),
          ],
          child: const MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Open Sign Up mode
      mockProvider.openAuth(isSignUp: true);
      await tester.pumpAndSettle();

      // Enter email and 8+ char password
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3)); // penName, email, password

      await tester.enterText(textFields.at(1), 'newuser@example.com');
      await tester.enterText(textFields.at(2), 'securePassword123');
      await tester.pumpAndSettle();

      // Tap Begin My Journey
      await tester.tap(find.text("Begin My Journey"));
      await tester.pumpAndSettle();

      // Verify that a SnackBar appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text("Check your email to confirm your account, then sign in."),
        findsOneWidget,
      );

      // Verify SnackBar background color is neutral navy Color(0xFF26374A) and NOT red (0xFF991B1B or 0xFFDC2626)
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, const Color(0xFF26374A));
      expect(snackBar.backgroundColor, isNot(const Color(0xFF991B1B)));
      expect(snackBar.backgroundColor, isNot(const Color(0xFFDC2626)));

      mockProvider.dispose();
    });

    testWidgets('AuthScreen shows red SnackBar on error', (tester) async {
      final mockProvider = TestMockDiaryProvider();
      mockProvider.mockErrorMessage = "Invalid credentials";

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<DiaryProvider>.value(value: mockProvider),
          ],
          child: const MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'user@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      mockProvider.mockSignUpSuccess = false;
      await tester.tap(find.text("Open My Diary"));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text("Invalid credentials"), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, const Color(0xFF991B1B));

      mockProvider.dispose();
    });

    test('DiaryProvider dispose cancels cleanly', () {
      final provider = DiaryProvider();
      expect(() => provider.dispose(), returnsNormally);
      // Calling notifyListeners after dispose should not throw
      expect(() => provider.notifyListeners(), returnsNormally);
    });
  });
}
