import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daydream_digital_diary/views/settings/privacy_policy_screen.dart';

void main() {
  testWidgets('PrivacyPolicyScreen renders complete policy in English without Thai content', (tester) async {
    // Set a realistic phone size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyPolicyScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Header and Badges
    expect(find.text("DAYDREAM DIGITAL DIARY"), findsOneWidget);
    expect(find.text("Privacy Policy"), findsOneWidget);
    expect(find.text("Effective date: October 23, 2026"), findsOneWidget);
    expect(find.text("Daydream Legal"), findsOneWidget);

    // Verify Key Sections
    expect(find.text("Information we collect"), findsOneWidget);
    expect(find.text("How we use your information"), findsOneWidget);
    expect(find.text("How your information is stored and shared"), findsOneWidget);
    expect(find.text("Data retention"), findsOneWidget);
    expect(find.text("Deleting your account and data"), findsOneWidget);
    expect(find.text("Your rights"), findsOneWidget);
    expect(find.text("Children's privacy"), findsOneWidget);
    expect(find.text("Security"), findsOneWidget);
    expect(find.text("Changes to this policy"), findsOneWidget);
    expect(find.text("Contact us"), findsOneWidget);

    // Verify that NO Thai text is present
    expect(find.textContaining("นโยบายความเป็นส่วนตัว"), findsNothing);
    expect(find.textContaining("ข้อมูลที่เราเก็บรวบรวม"), findsNothing);

    // Verify Table entries (Mobile card format on this screen size)
    expect(find.text("Account information"), findsOneWidget);
    expect(find.text("Profile picture"), findsOneWidget);
    expect(find.text("Diary content"), findsOneWidget);
    expect(find.text("Photos"), findsOneWidget);
    expect(find.text("Mood logs"), findsOneWidget);

    // Scroll down to check Understood button and Contact
    await tester.ensureVisible(find.text("Understood"));
    await tester.pumpAndSettle();
    expect(find.text("Understood"), findsOneWidget);
    expect(find.text("support@daydreamdiary.app"), findsOneWidget);
  });
}
