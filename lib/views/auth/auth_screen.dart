import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/polka_dot_painter.dart';
import '../../providers/diary_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _isPasswordVisible = false;
  bool? _lastProvSignUpMode;

  final _penNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _resetFields() {
    _penNameController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prov = Provider.of<DiaryProvider>(context);
    if (_lastProvSignUpMode != prov.isSignUpMode) {
      _lastProvSignUpMode = prov.isSignUpMode;
      _isSignUp = prov.isSignUpMode;
      _resetFields();
    }
  }

  @override
  void dispose() {
    _penNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(DiaryProvider prov) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final penName = _penNameController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email"),
          backgroundColor: Color(0xFF26374A),
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 8 characters long"),
          backgroundColor: Color(0xFF991B1B),
        ),
      );
      return;
    }

    bool success;
    if (_isSignUp) {
      success = await prov.signUp(
        email: email,
        password: password,
        penName: penName.isEmpty ? 'Sweet Dreamer' : penName,
      );
    } else {
      success = await prov.signIn(
        email: email,
        password: password,
      );
    }

    if (!mounted) return;

    if (success) {
      _resetFields();
    } else if (prov.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.errorMessage!),
          backgroundColor: const Color(0xFF991B1B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DiaryProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEDF5FC),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Subtle Polka Dots Background
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

          // 4. Delicate Back Button at Top-Left
          Positioned(
            top: 14,
            left: 16,
            child: SafeArea(
              child: InkWell(
                onTap: () => prov.setNavIndex(0), // Back to Welcome screen
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.92),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromRGBO(38, 55, 74, 0.3),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(38, 55, 74, 0.08),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: Color(0xFF26374A),
                  ),
                ),
              ),
            ),
          ),

          // 5. Centered Vintage Form Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 390),
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF26374A),
                    width: 1.4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(38, 55, 74, 0.10),
                      blurRadius: 22,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Image.asset(
                      _isSignUp
                          ? 'assets/images/title_create_account.png'
                          : 'assets/images/title_welcome_back.png',
                      height: 27,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 5),

                    // Subtitle
                    Text(
                      _isSignUp ? "Let’s get you started" : "sign in to your account",
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: const Color(0xFF26374A),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Optional Pen Name Field for Sign Up
                    if (_isSignUp) ...[
                      TextField(
                        controller: _penNameController,
                        style: AppTypography.sans(fontSize: 13, color: const Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          labelText: "Pen Name",
                          hintText: "Enter your pen name",
                          labelStyle: AppTypography.sans(
                            fontSize: 11.5,
                            color: const Color(0xFF26374A),
                            fontWeight: FontWeight.w500,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: true,
                          fillColor: const Color(0xFFFFFDF2),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Color(0xFF26374A), width: 1.3),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Color(0xFF26374A), width: 1.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTypography.sans(fontSize: 13, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        hintText: "your.email@example.com",
                        labelStyle: AppTypography.sans(
                          fontSize: 11.5,
                          color: const Color(0xFF26374A),
                          fontWeight: FontWeight.w500,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: true,
                        fillColor: const Color(0xFFFFFDF2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF26374A), width: 1.3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF26374A), width: 1.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password Field (At least 8 chars)
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: AppTypography.sans(fontSize: 13, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        labelText: "Password (min. 8 characters)",
                        hintText: "Enter at least 8 characters",
                        labelStyle: AppTypography.sans(
                          fontSize: 11.5,
                          color: const Color(0xFF26374A),
                          fontWeight: FontWeight.w500,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: true,
                        fillColor: const Color(0xFFFFFDF2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 17,
                            color: const Color(0xFF6C8299),
                          ),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF26374A), width: 1.3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF26374A), width: 1.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Primary Button: "Open My Diary" or "Begin My Journey"
                    AuthPillButton(
                      label: _isSignUp ? "Begin My Journey" : "Open My Diary",
                      isLoading: prov.isLoading,
                      backgroundColor: const Color(0xFFFFFDF0),
                      onPressed: () => _submit(prov),
                    ),
                    const SizedBox(height: 12),

                    // Switch Mode Link
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                            _resetFields();
                          });
                          prov.clearError();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text.rich(
                            TextSpan(
                              text: _isSignUp
                                  ? "Already have an account? "
                                  : "Don't have an account? ",
                              style: AppTypography.sans(
                                fontSize: 11.5,
                                color: const Color(0xFF6C8299),
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: _isSignUp ? "Sign In" : "Create New",
                                  style: AppTypography.sans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF26374A),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Pill Button with micro-animation for hover and press
class AuthPillButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const AuthPillButton({
    super.key,
    required this.label,
    this.isLoading = false,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  State<AuthPillButton> createState() => _AuthPillButtonState();
}

class _AuthPillButtonState extends State<AuthPillButton> {
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
          if (!widget.isLoading) widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 190,
            padding: const EdgeInsets.symmetric(vertical: 10.5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: const Color(0xFF26374A),
                width: 1.3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(38, 55, 74, 0.08),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF26374A)),
                    ),
                  )
                : Text(
                    widget.label,
                    style: AppTypography.sans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF26374A),
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
