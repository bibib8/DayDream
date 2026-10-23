import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:daydream_digital_diary/data/models/mood_model.dart';
import 'package:daydream_digital_diary/providers/diary_provider.dart';
import 'package:daydream_digital_diary/views/mood/mood_tracker_screen.dart';

void main() {
  group('MoodLogItem Helper Tests', () {
    test('matchesMonth correctly identifies matching year and month', () {
      final item = MoodLogItem(
        day: 15,
        date: '2026-09-15',
        moodKey: 'calm',
        note: 'Peaceful day',
      );

      expect(item.matchesMonth(2026, 9), isTrue);
      expect(item.matchesMonth(2026, 10), isFalse);
      expect(item.matchesMonth(2025, 9), isFalse);
      expect(item.dayOfMonth, 15);
    });
  });

  group('MoodTrackerScreen Month Navigation Tests', () {
    testWidgets('Renders current month initially, locks future next button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final diaryProv = DiaryProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: diaryProv),
          ],
          child: const MaterialApp(
            home: MoodTrackerScreen(),
          ),
        ),
      );

      final now = DateTime.now();
      const monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final currentMonthTitle = "${monthNames[now.month - 1]} ${now.year}";

      // Verify current month header exists
      expect(find.text(currentMonthTitle), findsOneWidget);

      // Verify Next button tooltip indicates locked/disabled state
      expect(find.byTooltip("Future month locked"), findsOneWidget);
      expect(find.byTooltip("Previous Month"), findsOneWidget);
      // "This Month" badge should NOT be visible when already on current month
      expect(find.text("This Month"), findsNothing);
    });

    testWidgets('Tapping Previous Month slides to previous month and unlocks This Month button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final diaryProv = DiaryProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: diaryProv),
          ],
          child: const MaterialApp(
            home: MoodTrackerScreen(),
          ),
        ),
      );

      // Tap Previous Month button
      await tester.tap(find.byTooltip("Previous Month"));
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final prevMonth = DateTime(now.year, now.month - 1, 1);
      const monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final prevMonthTitle = "${monthNames[prevMonth.month - 1]} ${prevMonth.year}";

      // Should now show previous month
      expect(find.text(prevMonthTitle), findsOneWidget);

      // "This Month" pill should now appear
      expect(find.text("This Month"), findsOneWidget);

      // Next Month button should now be enabled with "Next Month" tooltip
      expect(find.byTooltip("Next Month"), findsOneWidget);

      // Tap "This Month" to jump back
      await tester.tap(find.text("This Month"));
      await tester.pumpAndSettle();

      final currentMonthTitle = "${monthNames[now.month - 1]} ${now.year}";
      expect(find.text(currentMonthTitle), findsOneWidget);
    });

    testWidgets('Can swipe PageView horizontally to change month',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final diaryProv = DiaryProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: diaryProv),
          ],
          child: const MaterialApp(
            home: MoodTrackerScreen(),
          ),
        ),
      );

      // Fling from left to right across the PageView to go to previous month
      final pageViewFinder = find.byType(PageView);
      expect(pageViewFinder, findsOneWidget);

      await tester.fling(pageViewFinder, const Offset(500, 0), 1000);
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final prevMonth = DateTime(now.year, now.month - 1, 1);
      const monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final prevMonthTitle = "${monthNames[prevMonth.month - 1]} ${prevMonth.year}";

      expect(find.text(prevMonthTitle), findsOneWidget);
    });
  });
}
