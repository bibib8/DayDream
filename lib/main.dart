import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'providers/diary_provider.dart';
import 'views/landing/landing_screen.dart';
import 'views/auth/auth_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/editor/diary_editor_screen.dart';
import 'views/mood/mood_tracker_screen.dart';

import 'views/diary/diary_entries_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
      ],
      child: const DaydreamApp(),
    ),
  );
}

class DaydreamApp extends StatelessWidget {
  const DaydreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daydream Digital Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.cloudWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.denimBlue,
          primary: AppColors.denimBlue,
          secondary: AppColors.skyBlue,
          surface: AppColors.cloudWhite,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              return Scaffold(
                backgroundColor: const Color(0xFFE8EEF5),
                body: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 430, maxHeight: 920),
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(38, 55, 74, 0.15),
                          blurRadius: 30,
                          offset: Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFD0DDEB), width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: child!,
                  ),
                ),
              );
            }
            return child!;
          },
        );
      },
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  final List<Widget> _screens = const [
    LandingScreen(),      // 0
    AuthScreen(),         // 1
    DashboardScreen(),    // 2 (Home / Bookshelf)
    DiaryEditorScreen(),  // 3 (Journal Editor)
    MoodTrackerScreen(),  // 4 (Mood Calendar)
    DiaryEntriesScreen(), // 5 (Diary Book Overview / Pages List)
  ];

  @override
  Widget build(BuildContext context) {
    final diaryProv = Provider.of<DiaryProvider>(context);
    final currentIndex = diaryProv.currentNavIndex;

    final showNavBar = currentIndex >= 2;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: showNavBar
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFF26374A), width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(color: Color.fromRGBO(38, 55, 74, 0.08), blurRadius: 10, offset: Offset(0, -2)),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: (currentIndex == 5 ? 0 : (currentIndex - 2)).clamp(0, 2),
                onTap: (index) {
                  if (index == 0) {
                    diaryProv.setNavIndex(2);
                  } else {
                    diaryProv.setNavIndex(index + 2);
                  }
                },
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF26374A),
                unselectedItemColor: const Color(0xFF758A9E),
                selectedLabelStyle: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.w500),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.auto_stories_outlined),
                    activeIcon: Icon(Icons.auto_stories),
                    label: 'Bookshelf',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.edit_note_outlined),
                    activeIcon: Icon(Icons.edit_note),
                    label: 'Editor',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    activeIcon: Icon(Icons.calendar_month),
                    label: 'Mood',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

