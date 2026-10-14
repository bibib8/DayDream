import 'package:flutter/material.dart';

/// Reusable circular avatar widget that seamlessly handles both
/// uploaded photo URLs (Image.network) and playful emoji avatars.
class UserAvatarView extends StatelessWidget {
  final String avatar;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;

  const UserAvatarView({
    super.key,
    required this.avatar,
    this.size = 44,
    this.backgroundColor = const Color(0xFFE5F1FC),
    this.borderColor = const Color(0xFF26374A),
    this.borderWidth = 1.1,
  });

  bool get isImageUrl {
    final trimmed = avatar.trim().toLowerCase();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: ClipOval(
        child: isImageUrl
            ? Image.network(
                avatar,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    "🩵",
                    style: TextStyle(fontSize: size * 0.44),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.36,
                      height: size * 0.36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  avatar.isNotEmpty ? avatar : "🩵",
                  style: TextStyle(fontSize: size * 0.44),
                ),
              ),
      ),
    );
  }
}
