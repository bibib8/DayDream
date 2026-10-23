import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_typography.dart';
import '../core/services/supabase_repository.dart';
import '../providers/diary_provider.dart';
import '../views/settings/privacy_policy_screen.dart';
import 'user_avatar_view.dart';

class SettingsDialog extends StatefulWidget {
  final DiaryProvider provider;

  const SettingsDialog({super.key, required this.provider});

  static Future<void> show(BuildContext context, DiaryProvider prov) {
    return showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(38, 55, 74, 0.45),
      builder: (ctx) => SettingsDialog(provider: prov),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _penNameCtrl;
  bool _isSavingName = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _penNameCtrl = TextEditingController(text: widget.provider.user.penName);
  }

  @override
  void dispose() {
    _penNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePenName() async {
    final newName = _penNameCtrl.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isSavingName = true);
    await widget.provider.updatePenName(newName);
    if (!mounted) return;
    setState(() => _isSavingName = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pen name updated! ✨"),
        backgroundColor: Color(0xFF26374A),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);

    try {
      final Uint8List bytes = await picked.readAsBytes();

      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image exceeds 2 MB! Please select a smaller photo."),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        setState(() => _isUploadingAvatar = false);
        return;
      }

      final fileName = "avatar_${DateTime.now().millisecondsSinceEpoch}_${picked.name}";
      final url = await widget.provider.uploadImage(bytes, fileName);
      await widget.provider.updateAvatarUrl(url);

      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile photo updated! 📷✨"),
          backgroundColor: Color(0xFF26374A),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to upload avatar: $e"),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _showAvatarPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEF6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF26374A), width: 1.3),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(38, 55, 74, 0.16),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "Change Profile Photo",
                  style: AppTypography.sans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F1FC),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF26374A), width: 1),
                    ),
                    child: const Icon(Icons.photo_library_outlined, size: 20, color: Color(0xFF26374A)),
                  ),
                  title: Text(
                    "Choose from Gallery",
                    style: AppTypography.sans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                  ),
                  onTap: () {
                    Navigator.pop(bCtx);
                    _pickAndUploadAvatar(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F1FC),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF26374A), width: 1),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, size: 20, color: Color(0xFF26374A)),
                  ),
                  title: Text(
                    "Take a Photo",
                    style: AppTypography.sans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                  ),
                  onTap: () {
                    Navigator.pop(bCtx);
                    _pickAndUploadAvatar(ImageSource.camera);
                  },
                ),
                if (widget.provider.user.avatar.toLowerCase().startsWith('http'))
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDC2626), width: 1),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFDC2626)),
                    ),
                    title: Text(
                      "Reset to Default Avatar",
                      style: AppTypography.sans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626)),
                    ),
                    onTap: () async {
                      Navigator.pop(bCtx);
                      await widget.provider.updateAvatarUrl("🩵");
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  void _showPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _confirmDeleteAccount() {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(38, 55, 74, 0.55),
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => PopScope(
          canPop: !isDeleting,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFEF6),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFDC2626), width: 1.4),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(220, 38, 38, 0.15),
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFDC2626), width: 1.1),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Delete Account?",
                        style: AppTypography.sans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "This action cannot be undone. All your diaries, scrapbook entries, moods, and photos will be permanently deleted from the cloud.",
                    style: AppTypography.sans(
                      fontSize: 13,
                      color: const Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton(
                        onPressed: isDeleting ? null : () => Navigator.pop(dialogCtx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF26374A),
                          side: const BorderSide(color: Color(0xFF26374A), width: 1.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        ),
                        child: Text("Cancel", style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      ElevatedButton(
                        onPressed: isDeleting
                            ? null
                            : () async {
                                setDialogState(() => isDeleting = true);
                                final success = await widget.provider.deleteAccount();
                                if (!dialogCtx.mounted) return;
                                if (success) {
                                  Navigator.pop(dialogCtx); // Close confirmation
                                  if (mounted) {
                                    Navigator.pop(context); // Close Settings dialog
                                  }
                                } else {
                                  setDialogState(() => isDeleting = false);
                                  if (mounted) {
                                    final errorMsg = widget.provider.errorMessage ?? "Failed to delete account";
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMsg),
                                        backgroundColor: const Color(0xFFDC2626),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          disabledBackgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        ),
                        child: isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Delete Permanently",
                                style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(38, 55, 74, 0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.fromLTRB(26, 26, 24, 22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEF6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF26374A), width: 1.3),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(38, 55, 74, 0.12),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color.fromRGBO(38, 55, 74, 0.04),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/title_logout.png',
                height: 38,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to sign out of your account?",
                style: AppTypography.sans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    hoverColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text(
                        "Stay",
                        style: AppTypography.sans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF26374A), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(38, 55, 74, 0.08),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          widget.provider.logout();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8.5),
                          child: Text(
                            "Log Out",
                            style: AppTypography.sans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.provider.user;
    final email = SupabaseRepository.currentUser?.email ?? user.handle;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEF6),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF26374A), width: 1.4),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(38, 55, 74, 0.16),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined, size: 20, color: Color(0xFF26374A)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "Settings & Account",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 20, color: Color(0xFF6C8299)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // User Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26374A), width: 1.1),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _isUploadingAvatar ? null : _showAvatarPickerModal,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          UserAvatarView(
                            avatar: user.avatar,
                            size: 48,
                            borderWidth: 1.2,
                          ),
                          if (_isUploadingAvatar)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(38, 55, 74, 0.45),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF26374A),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.4),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.penName,
                            style: AppTypography.sans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              fontSize: 11.5,
                              color: const Color(0xFF6C8299),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Pen Name Edit Section
              Text(
                "Pen Name",
                style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _penNameCtrl,
                        style: AppTypography.sans(fontSize: 13),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFF241F3E), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFF241F3E), width: 1.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      constraints: const BoxConstraints(minWidth: 72),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFF0F7FD),
                            Color(0xFFDEF1FE),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF241F3E), width: 1.6),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(38, 55, 74, 0.04),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSavingName ? null : _savePenName,
                          borderRadius: BorderRadius.circular(18),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _isSavingName
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF241F3E)),
                                    )
                                  : Text(
                                      "Save",
                                      style: AppTypography.sans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF241F3E),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Privacy Policy Tile
              InkWell(
                onTap: _showPrivacyPolicy,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.privacy_tip_outlined, size: 16, color: Color(0xFF26374A)),
                          const SizedBox(width: 8),
                          Text(
                            "Privacy Policy & Terms",
                            style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // App Version
              Center(
                child: Text(
                  "Daydream v1.0.0 (Build 1)",
                  style: AppTypography.sans(fontSize: 11, color: const Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 18),

              // Account Actions: Log Out & Delete Account
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout_rounded, size: 15),
                      label: Text("Log Out", style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF26374A),
                        side: const BorderSide(color: Color(0xFF26374A), width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _confirmDeleteAccount,
                      icon: const Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFDC2626)),
                      label: Text(
                        "Delete Account",
                        style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626)),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626), width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
