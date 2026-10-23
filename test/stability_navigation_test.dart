import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:daydream_digital_diary/data/models/diary_model.dart';
import 'package:daydream_digital_diary/data/models/entry_model.dart';
import 'package:daydream_digital_diary/main.dart';
import 'package:daydream_digital_diary/providers/diary_provider.dart';
import 'package:daydream_digital_diary/views/editor/diary_editor_screen.dart';
import 'package:daydream_digital_diary/views/settings/privacy_policy_screen.dart';

void main() {
  group('Issue 1: openEntry stability tests', () {
    test('openEntry returns early without RangeError when entries list is empty', () {
      final provider = DiaryProvider();
      // Ensure entries list is empty
      expect(provider.entries.isEmpty, isTrue);
      final initialNavIndex = provider.currentNavIndex;
      final initialActiveId = provider.activeEntryId;

      // Calling openEntry with nonexistent id on empty entries should not throw
      expect(() => provider.openEntry('non_existent_id'), returnsNormally);
      expect(provider.currentNavIndex, equals(initialNavIndex));
      expect(provider.activeEntryId, equals(initialActiveId));
    });

    test('openEntry returns early when entryId is not found in non-empty entries list', () {
      final provider = DiaryProvider();
      // Add a diary and an entry
      final diary = DiaryModel(
        id: 'd1',
        title: 'Test Diary',
        subtitle: 'sub',
        coverStyle: 'classic',
        color: Colors.blue,
        accent: const Color(0xFF26374A),
        entriesCount: 1,
        lastEdited: 'Today',
        pattern: 'classic',
        isPrivate: false,
        description: 'desc',
      );
      final entry = EntryModel(
        id: 'e1',
        diaryId: 'd1',
        title: 'Entry 1',
        content: 'Content 1',
        date: 'October 23, 2026',
        time: '12:00 PM',
        moodKey: 'happy',
        moodLabel: 'Happy',
        moodIcon: '😊',
      );

      provider.setNavIndex(2);
      provider.addDiaryForTesting(diary);
      provider.addEntryForTesting(entry);

      expect(provider.entries.length, equals(1));

      // Attempt to open an unknown id
      provider.openEntry('unknown_id');
      // Should not navigate to 3, navIndex should stay 2
      expect(provider.currentNavIndex, equals(2));
      expect(provider.activeEntryId, isNot('unknown_id'));

      // Now open the valid entry
      provider.openEntry('e1');
      expect(provider.currentNavIndex, equals(3));
      expect(provider.activeEntryId, equals('e1'));
      expect(provider.selectedDiaryId, equals('d1'));
    });
  });

  group('Issue 2: Android back button navigation with PopScope', () {
    Widget createTestApp(DiaryProvider provider) {
      return ChangeNotifierProvider<DiaryProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: MainNavigationShell(),
        ),
      );
    }

    testWidgets('canPop is true when currentNavIndex is 0 (welcome) or 2 (bookshelf)', (tester) async {
      final provider = DiaryProvider();
      await tester.pumpWidget(createTestApp(provider));
      await tester.pumpAndSettle();

      // Index 0: Welcome screen
      expect(provider.currentNavIndex, equals(0));
      var popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isTrue);

      // Index 2: Bookshelf
      provider.setNavIndex(2);
      await tester.pumpAndSettle();
      expect(provider.currentNavIndex, equals(2));
      popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isTrue);
    });

    testWidgets('canPop is false when currentNavIndex is 1, 3, 4, 5', (tester) async {
      final provider = DiaryProvider();
      await tester.pumpWidget(createTestApp(provider));
      await tester.pumpAndSettle();

      for (final index in [1, 3, 4, 5]) {
        provider.setNavIndex(index);
        await tester.pumpAndSettle();
        expect(provider.currentNavIndex, equals(index));
        final popScope = tester.widget<PopScope>(find.byType(PopScope));
        expect(popScope.canPop, isFalse, reason: 'Index $index should have canPop = false');
      }
    });

    testWidgets('System back on index 1 (auth) navigates back to index 0 (welcome)', (tester) async {
      final provider = DiaryProvider();
      await tester.pumpWidget(createTestApp(provider));
      await tester.pumpAndSettle();

      provider.setNavIndex(1);
      await tester.pumpAndSettle();
      expect(provider.currentNavIndex, equals(1));

      // Simulate system back button
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(provider.currentNavIndex, equals(0));
    });

    testWidgets('System back on index 4 (mood) navigates back to index 2 (bookshelf)', (tester) async {
      final provider = DiaryProvider();
      await tester.pumpWidget(createTestApp(provider));
      await tester.pumpAndSettle();

      provider.setNavIndex(4);
      await tester.pumpAndSettle();
      expect(provider.currentNavIndex, equals(4));

      // Simulate system back button
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(provider.currentNavIndex, equals(2));
    });

    testWidgets('System back on index 5 (diary entries) navigates back to index 2 (bookshelf)', (tester) async {
      final provider = DiaryProvider();
      await tester.pumpWidget(createTestApp(provider));
      await tester.pumpAndSettle();

      provider.setNavIndex(5);
      await tester.pumpAndSettle();
      expect(provider.currentNavIndex, equals(5));

      // Simulate system back button
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(provider.currentNavIndex, equals(2));
    });

    testWidgets('System back on index 3 (editor) flushes pending autosave and calls goBackFromEditor()', (tester) async {
      final provider = DiaryProvider();
      final diary = DiaryModel(
        id: 'd_test',
        title: 'Autosave Diary',
        subtitle: 'sub',
        coverStyle: 'classic',
        color: Colors.blue,
        accent: const Color(0xFF26374A),
        entriesCount: 1,
        lastEdited: 'Today',
        pattern: 'classic',
        isPrivate: false,
        description: 'desc',
      );
      final entry = EntryModel(
        id: 'e_test',
        diaryId: 'd_test',
        title: 'Original Title',
        content: 'Original Content',
        date: 'October 23, 2026',
        time: '12:00 PM',
        moodKey: 'happy',
        moodLabel: 'Happy',
        moodIcon: '😊',
      );
      provider.addDiaryForTesting(diary);
      provider.addEntryForTesting(entry);

      // Open from bookshelf (returnIndex will be 2)
      provider.openEntry('e_test', returnIndex: 2);
      expect(provider.currentNavIndex, equals(3));

      await tester.pumpWidget(createTestApp(provider));
      await tester.pumpAndSettle();

      // Find title TextField specifically within DiaryEditorScreen
      final editorTextFields = find.descendant(
        of: find.byType(DiaryEditorScreen),
        matching: find.byType(TextField),
      );
      expect(editorTextFields, findsWidgets);
      await tester.enterText(editorTextFields.first, 'Updated Saved Title');
      await tester.pump(); // Register change, marks _hasPendingChanges = true

      // Simulate system back button press while debounce timer is active
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify that navigation returned to 2 and title was flushed & saved
      expect(provider.currentNavIndex, equals(2));
      final savedEntry = provider.entries.firstWhere((e) => e.id == 'e_test');
      expect(savedEntry.title, equals('Updated Saved Title'));
    });

    testWidgets('Pushed route (PrivacyPolicyScreen) and dialogs pop cleanly without breaking navigation', (tester) async {
      final provider = DiaryProvider();
      provider.setNavIndex(1); // Auth screen (canPop is false)

      await tester.pumpWidget(createTestApp(provider));
      await tester.pumpAndSettle();

      final navContext = tester.element(find.byType(MainNavigationShell));

      // Push PrivacyPolicyScreen
      Navigator.of(navContext).push(
        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      expect(provider.currentNavIndex, equals(1));

      // Press system back button: should pop PrivacyPolicyScreen, NOT pop shell or change index to 0
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyScreen), findsNothing);
      expect(provider.currentNavIndex, equals(1)); // Still on Auth screen

      // Show a Dialog
      showDialog(
        context: navContext,
        builder: (ctx) => const AlertDialog(
          title: Text('Test Dialog'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);

      // System back should pop the dialog
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsNothing);
      expect(provider.currentNavIndex, equals(1));

      // Finally, pressing system back on Auth screen navigates to Welcome (0)
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(provider.currentNavIndex, equals(0));
    });
  });
}
