import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:daydream_digital_diary/main.dart';
import 'package:daydream_digital_diary/providers/diary_provider.dart';

void main() {
  testWidgets('Daydream app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ],
        child: const DaydreamApp(),
      ),
    );

    expect(find.byType(DaydreamApp), findsOneWidget);
  });
}
