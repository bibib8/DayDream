import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:daydream_digital_diary/providers/diary_provider.dart';
import 'package:daydream_digital_diary/widgets/settings_dialog.dart';

void main() {
  testWidgets('SettingsDialog renders user info, Privacy Policy, Log Out, and Delete Account', (tester) async {
    final provider = DiaryProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => SettingsDialog.show(ctx, provider),
                child: const Text("Open Settings"),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Open Settings"));
    await tester.pumpAndSettle();

    expect(find.text("Settings & Account"), findsOneWidget);
    expect(find.text("Privacy Policy & Terms"), findsOneWidget);
    expect(find.text("Log Out"), findsOneWidget);
    expect(find.text("Delete Account"), findsOneWidget);

    // Verify avatar camera badge and tap to open photo picker sheet
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.camera_alt_rounded));
    await tester.pumpAndSettle();
    expect(find.text("Change Profile Photo"), findsOneWidget);
    expect(find.text("Choose from Gallery"), findsOneWidget);
    expect(find.text("Take a Photo"), findsOneWidget);

    // Dismiss bottom sheet by tapping barrier
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    // Open Privacy Policy
    await tester.tap(find.text("Privacy Policy & Terms"));
    await tester.pumpAndSettle();
    expect(find.text("Privacy Policy"), findsOneWidget);
    expect(find.text("Understood"), findsOneWidget);

    // Ensure Understood is visible and tap to dismiss
    await tester.ensureVisible(find.text("Understood"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Understood"));
    await tester.pumpAndSettle();

    // Verify Save button is visible
    expect(find.text("Save"), findsOneWidget);

    // Tap Log Out to open confirmation dialog
    await tester.ensureVisible(find.text("Log Out"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Log Out"));
    await tester.pumpAndSettle();
    expect(find.text("Are you sure you want to sign out of your account?"), findsOneWidget);
    expect(find.text("Stay"), findsOneWidget);

    // Tap Stay to dismiss logout confirmation
    await tester.tap(find.text("Stay"));
    await tester.pumpAndSettle();


    // Ensure Delete Account button is visible in scrollview and tap
    await tester.ensureVisible(find.text("Delete Account"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Delete Account"));
    await tester.pumpAndSettle();
    expect(find.text("Delete Account?"), findsOneWidget);
    expect(find.text("Delete Permanently"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
  });
}
