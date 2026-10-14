import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daydream_digital_diary/core/constants/cover_gradients.dart';
import 'package:daydream_digital_diary/data/models/diary_model.dart';
import 'package:daydream_digital_diary/widgets/diary_cover_view.dart';

void main() {
  group('Cover Gradient Tests', () {
    test('kCoverGradients contains all 6 presets matching user mockup', () {
      expect(kCoverGradients.length, 6);
      expect(kCoverGradients.map((p) => p.id), containsAll([
        'blush_rose',
        'buttercream',
        'periwinkle_dream',
        'sweet_lilac',
        'powder_sky',
        'vintage_pearl',
      ]));
    });

    test('DiaryModel parses comma-separated gradient hex correctly', () {
      final diary = DiaryModel.fromJson({
        'id': 'test_gradient',
        'title': 'Gradient Test',
        'cover_color': '#FFF0F7,#FBCFE8',
      });

      expect(diary.gradientColors, isNotNull);
      expect(diary.gradientColors!.length, 2);
      expect(diary.gradientColors![0], const Color(0xFFFFF0F7));
      expect(diary.gradientColors![1], const Color(0xFFFBCFE8));
      expect(diary.coverColorHex, '#FFF0F7,#FBCFE8');

      final gradient = diary.gradient;
      expect(gradient.colors, [const Color(0xFFFFF0F7), const Color(0xFFFBCFE8)]);
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
    });

    test('DiaryModel backwards compatibility with single hex color generates subtle gradient', () {
      final diary = DiaryModel.fromJson({
        'id': 'test_single',
        'title': 'Single Color Test',
        'cover_color': '#E5F1FC',
      });

      expect(diary.gradientColors, isNull);
      expect(diary.color, const Color(0xFFE5F1FC));
      expect(diary.gradient.colors.length, 2);
      expect(diary.gradient.colors[1], const Color(0xFFE5F1FC));
    });

    testWidgets('DiaryCoverView does not display default book emoji 📖 when emoji is null', (tester) async {
      final diary = DiaryModel(
        id: 'clean_diary',
        title: 'Clean Minimal Diary',
        subtitle: 'No emoji, no photo',
        coverStyle: 'blush-rose',
        color: const Color(0xFFFFF0F7),
        accent: const Color(0xFF26374A),
        entriesCount: 0,
        lastEdited: 'Now',
        pattern: 'classic',
        isPrivate: false,
        description: '',
        coverEmoji: null,
        coverImageUrl: null,
        coverText: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                height: 140,
                child: DiaryCoverView.fromDiary(diary: diary),
              ),
            ),
          ),
        ),
      );

      expect(find.text("📖"), findsNothing);
    });
  });
}
