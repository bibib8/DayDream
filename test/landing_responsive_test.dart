import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:daydream_digital_diary/providers/diary_provider.dart';
import 'package:daydream_digital_diary/views/landing/landing_screen.dart';
import 'package:daydream_digital_diary/views/auth/auth_screen.dart';

void main() {
  group('Lace Ribbon Responsive Sizing Tests', () {
    testWidgets('Desktop: LandingScreen restricts lace height to 52 and repeats horizontally',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DiaryProvider()),
          ],
          child: const MaterialApp(
            home: LandingScreen(),
          ),
        ),
      );

      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      // Should find lace_top and lace_bottom
      final laceImages = imageWidgets.where((img) {
        final provider = img.image;
        if (provider is AssetImage) {
          return provider.assetName.contains('lace_');
        }
        return false;
      }).toList();

      expect(laceImages.length, 2);
      for (final lace in laceImages) {
        expect(lace.height, 52);
        expect(lace.fit, BoxFit.fitHeight);
        expect(lace.repeat, ImageRepeat.repeatX);
      }
    });

    testWidgets('Mobile: LandingScreen preserves fitWidth for lace ribbons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DiaryProvider()),
          ],
          child: const MaterialApp(
            home: LandingScreen(),
          ),
        ),
      );

      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      final laceImages = imageWidgets.where((img) {
        final provider = img.image;
        if (provider is AssetImage) {
          return provider.assetName.contains('lace_');
        }
        return false;
      }).toList();

      expect(laceImages.length, 2);
      for (final lace in laceImages) {
        expect(lace.height, isNull);
        expect(lace.fit, BoxFit.fitWidth);
        expect(lace.repeat, ImageRepeat.noRepeat);
      }
    });

    testWidgets('Desktop: AuthScreen restricts lace height to 52 and repeats horizontally',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DiaryProvider()),
          ],
          child: const MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      final laceImages = imageWidgets.where((img) {
        final provider = img.image;
        if (provider is AssetImage) {
          return provider.assetName.contains('lace_');
        }
        return false;
      }).toList();

      expect(laceImages.length, 2);
      for (final lace in laceImages) {
        expect(lace.height, 52);
        expect(lace.fit, BoxFit.fitHeight);
        expect(lace.repeat, ImageRepeat.repeatX);
      }
    });
  });
}
