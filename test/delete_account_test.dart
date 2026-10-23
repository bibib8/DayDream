import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:daydream_digital_diary/providers/diary_provider.dart';
import 'package:daydream_digital_diary/widgets/settings_dialog.dart';

class MockFailingDiaryProvider extends DiaryProvider {
  final Completer<bool> completer = Completer<bool>();
  bool deleteCalled = false;

  @override
  Future<bool> deleteAccount() async {
    deleteCalled = true;
    final result = await completer.future;
    return result;
  }
}

class MockSuccessDiaryProvider extends DiaryProvider {
  final Completer<bool> completer = Completer<bool>();
  bool deleteCalled = false;

  @override
  Future<bool> deleteAccount() async {
    deleteCalled = true;
    final result = await completer.future;
    return result;
  }
}

void main() {
  testWidgets('SettingsDialog shows loading indicator while deleting and red SnackBar on failure', (tester) async {
    final mockProvider = MockFailingDiaryProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DiaryProvider>.value(value: mockProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => SettingsDialog.show(ctx, mockProvider),
                child: const Text("Open Settings"),
              ),
            ),
          ),
        ),
      ),
    );

    // Open Settings dialog
    await tester.tap(find.text("Open Settings"));
    await tester.pumpAndSettle();

    // Tap Delete Account in settings
    await tester.ensureVisible(find.text("Delete Account"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Delete Account"));
    await tester.pumpAndSettle();

    expect(find.text("Delete Account?"), findsOneWidget);
    expect(find.text("Delete Permanently"), findsOneWidget);

    // Tap Delete Permanently
    await tester.tap(find.text("Delete Permanently"));
    await tester.pump(); // Start async delete, should now show CircularProgressIndicator

    expect(mockProvider.deleteCalled, isTrue);
    // While deleting: loading state is shown and text "Delete Permanently" is replaced by spinner
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text("Delete Permanently"), findsNothing);

    // Complete with failure
    mockProvider.completer.complete(false);
    await tester.pumpAndSettle();

    // Red SnackBar should appear with error message
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Failed to delete account"), findsOneWidget);

    // SnackBar background color should be red (0xFFDC2626)
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, const Color(0xFFDC2626));

    // Button should be back to "Delete Permanently"
    expect(find.text("Delete Permanently"), findsOneWidget);
  });

  testWidgets('SettingsDialog closes both confirmation and settings dialogs on success', (tester) async {
    final mockProvider = MockSuccessDiaryProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DiaryProvider>.value(value: mockProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => SettingsDialog.show(ctx, mockProvider),
                child: const Text("Open Settings"),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Open Settings"));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text("Delete Account"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Delete Account"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Delete Permanently"));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete with success
    mockProvider.completer.complete(true);
    await tester.pumpAndSettle();

    // Confirmation dialog and Settings dialog should be closed
    expect(find.text("Delete Account?"), findsNothing);
    expect(find.text("Settings & Account"), findsNothing);
  });

  test('DiaryProvider.deleteAccount() sets errorMessage and returns false on failure without logging out', () async {
    final provider = DiaryProvider();
    expect(provider.errorMessage, isNull);

    final result = await provider.deleteAccount();

    expect(result, isFalse);
    expect(provider.errorMessage, isNotNull);
    expect(provider.errorMessage, contains("User not authenticated"));
    expect(provider.isLoading, isFalse);
  });
}
