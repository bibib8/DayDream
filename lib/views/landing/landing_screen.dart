import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/polka_dot_painter.dart';
import '../../providers/diary_provider.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DiaryProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEDF5FC),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Subtle Polka Dots Canvas Background
          const CustomPaint(
            painter: WelcomePolkaDotPainter(),
          ),

          // 2. Top Lace Ribbon attached to top edge
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Image.asset(
                'assets/images/lace_top.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          // 3. Bottom Lace Ribbon attached to bottom edge
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Image.asset(
                'assets/images/lace_bottom.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          // 4. Centered Logo & Responsive Action Buttons
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo: "Daydream digital diary" with Calligraphic Swashes
                  Image.asset(
                    'assets/images/welcome_logo.png',
                    width: 290,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),

                  // Dynamic Buttons based on login status:
                  if (prov.isAuthenticated) ...[
                    // Case 1: Already Logged In -> 1 button "Open My Diary"
                    WelcomePillButton(
                      label: "Open My Diary",
                      backgroundColor: const Color(0xFFFFFDF0),
                      onPressed: () => prov.setNavIndex(2), // Enter Bookshelf
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => prov.logout(),
                      child: Text(
                        "Logged in as ${prov.user.penName} • Tap to Log out",
                        style: AppTypography.sans(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Case 2: Not Logged In -> 2 buttons "Sign In" and "New Account"
                    WelcomePillButton(
                      label: "Sign In",
                      backgroundColor: const Color(0xFFFFFDF0),
                      onPressed: () => prov.openAuth(isSignUp: false),
                    ),
                    const SizedBox(height: 12),
                    WelcomePillButton(
                      label: "New Account",
                      backgroundColor: const Color(0xFFEAF4FF),
                      onPressed: () => prov.openAuth(isSignUp: true),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom button styled with the soft cream pill shape and thin dark navy border
class WelcomePillButton extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const WelcomePillButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  State<WelcomePillButton> createState() => _WelcomePillButtonState();
}

class _WelcomePillButtonState extends State<WelcomePillButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 220,
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: const Color(0xFF26374A),
                width: 1.4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(38, 55, 74, 0.08),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: AppTypography.sans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF26374A),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
