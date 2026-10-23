import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'data/sample_data.dart';
import 'providers/diary_provider.dart';
import 'views/landing/landing_screen.dart';
import 'views/auth/auth_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/editor/diary_editor_screen.dart';
import 'views/mood/mood_tracker_screen.dart';
import 'views/diary/diary_entries_screen.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/user_avatar_view.dart';

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
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final GlobalKey<DiaryEditorScreenState> _editorKey = GlobalKey<DiaryEditorScreenState>();

  late final List<Widget> _screens = [
    const LandingScreen(),      // 0
    const AuthScreen(),         // 1
    const DashboardScreen(),    // 2 (Home / Bookshelf)
    DiaryEditorScreen(key: _editorKey),  // 3 (Journal Editor)
    const MoodTrackerScreen(),  // 4 (Mood Calendar)
    const DiaryEntriesScreen(), // 5 (Diary Book Overview / Pages List)
  ];

  @override
  Widget build(BuildContext context) {
    final diaryProv = Provider.of<DiaryProvider>(context);
    final currentIndex = diaryProv.currentNavIndex;
    final showNav = currentIndex >= 2;
    final canPop = currentIndex == 0 || currentIndex == 2;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (currentIndex == 3) {
          if (_editorKey.currentState != null) {
            await _editorKey.currentState!.flushSaveAndGoBack();
          } else {
            diaryProv.goBackFromEditor();
          }
        } else if (currentIndex == 4 || currentIndex == 5) {
          diaryProv.setNavIndex(2);
        } else if (currentIndex == 1) {
          diaryProv.setNavIndex(0);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 720;
          final selectedNavIdx = (currentIndex == 5 ? 0 : (currentIndex - 2)).clamp(0, 2);

          void onNavTap(int index) {
            if (index == 0) {
              diaryProv.setNavIndex(2);
            } else {
              diaryProv.setNavIndex(index + 2);
            }
          }

          // ─── TABLET & DESKTOP: VINTAGE SIDEBAR NAVIGATION ───
          if (isWideScreen && showNav) {
            return Scaffold(
              backgroundColor: const Color(0xFFEDF5FC),
              body: Row(
                children: [
                  _DesktopSideNav(
                    selectedIndex: selectedNavIdx,
                    onDestinationSelected: onNavTap,
                    user: diaryProv.user,
                    onSettingsTap: () => SettingsDialog.show(context, diaryProv),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: currentIndex,
                      children: _screens,
                    ),
                  ),
                ],
              ),
            );
          }

          // ─── MOBILE: BOTTOM NAVIGATION BAR ───
          return Scaffold(
            body: IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: showNav
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
                      currentIndex: selectedNavIdx,
                      onTap: onNavTap,
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
        },
      ),
    );
  }
}

/// Aesthetic vintage navigation rail for Tablet and Desktop views
class _DesktopSideNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final UserModel user;
  final VoidCallback onSettingsTap;

  const _DesktopSideNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.user,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFF26374A), width: 1.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(38, 55, 74, 0.04),
            blurRadius: 16,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            // Brand Mark / Official Logo
            Tooltip(
              message: "Daydream Digital Diary",
              child: InkWell(
                onTap: () => onDestinationSelected(0),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF26374A), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(38, 55, 74, 0.08),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Subtle divider
            Container(
              width: 38,
              height: 1.2,
              color: const Color(0xFF26374A).withValues(alpha: 0.12),
            ),
            const SizedBox(height: 20),

            // Navigation Items
            _SideNavItem(
              icon: Icons.auto_stories_outlined,
              activeIcon: Icons.auto_stories,
              label: 'Bookshelf',
              isSelected: selectedIndex == 0,
              onTap: () => onDestinationSelected(0),
            ),
            const SizedBox(height: 14),
            _SideNavItem(
              icon: Icons.edit_note_outlined,
              activeIcon: Icons.edit_note,
              label: 'Editor',
              isSelected: selectedIndex == 1,
              onTap: () => onDestinationSelected(1),
            ),
            const SizedBox(height: 14),
            _SideNavItem(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month,
              label: 'Mood',
              isSelected: selectedIndex == 2,
              onTap: () => onDestinationSelected(2),
            ),

            const Spacer(),

            // Bottom Profile / Settings Action
            Tooltip(
              message: "Settings (${user.penName})",
              child: InkWell(
                onTap: onSettingsTap,
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserAvatarView(
                        avatar: user.avatar,
                        size: 42,
                        borderWidth: 1.3,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Settings",
                        style: AppTypography.sans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C8299),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SideNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFFE5F1FC)
                : (_isHovered ? const Color(0xFFF1F6FB) : Colors.transparent),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF26374A)
                  : (_isHovered
                      ? const Color(0xFF26374A).withValues(alpha: 0.25)
                      : Colors.transparent),
              width: 1.2,
            ),
            boxShadow: widget.isSelected
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(38, 55, 74, 0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isSelected ? widget.activeIcon : widget.icon,
                size: 24,
                color: widget.isSelected
                    ? const Color(0xFF26374A)
                    : const Color(0xFF6C8299),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: AppTypography.sans(
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                  color: widget.isSelected
                      ? const Color(0xFF26374A)
                      : const Color(0xFF6C8299),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


