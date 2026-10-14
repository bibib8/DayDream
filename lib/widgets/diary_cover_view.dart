import 'package:flutter/material.dart';
import '../core/constants/app_typography.dart';
import '../data/models/diary_model.dart';

/// A reusable, aesthetic Diary Cover Widget mimicking a vintage hardbound journal.
/// Displays cover photo, spine stitching line, optional emoji, and optional vintage cover title plate.
class DiaryCoverView extends StatelessWidget {
  final Color backgroundColor;
  final Gradient? gradient;
  final String? imageUrl;
  final String? emoji;
  final String? coverText;
  final double borderRadius;
  final double borderWidth;
  final double spineOffset;
  final double emojiSize;
  final double fontSize;
  final Widget? topAction;
  final bool showSpine;
  final VoidCallback? onTap;

  const DiaryCoverView({
    super.key,
    required this.backgroundColor,
    this.gradient,
    this.imageUrl,
    this.emoji,
    this.coverText,
    this.borderRadius = 12.0,
    this.borderWidth = 1.2,
    this.spineOffset = 10.0,
    this.emojiSize = 26.0,
    this.fontSize = 10.5,
    this.topAction,
    this.showSpine = true,
    this.onTap,
  });

  /// Factory from a DiaryModel
  factory DiaryCoverView.fromDiary({
    Key? key,
    required DiaryModel diary,
    double borderRadius = 12.0,
    double borderWidth = 1.2,
    double spineOffset = 10.0,
    double emojiSize = 26.0,
    double fontSize = 10.5,
    Widget? topAction,
    bool showSpine = true,
    VoidCallback? onTap,
  }) {
    return DiaryCoverView(
      key: key,
      backgroundColor: diary.color,
      gradient: diary.gradient,
      imageUrl: diary.coverImageUrl,
      emoji: diary.coverEmoji,
      coverText: diary.coverText,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      spineOffset: spineOffset,
      emojiSize: emojiSize,
      fontSize: fontSize,
      topAction: topAction,
      showSpine: showSpine,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final hasEmoji = emoji != null && emoji!.trim().isNotEmpty;
    final hasCoverText = coverText != null && coverText!.trim().isNotEmpty;

    Widget coverContent = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFF26374A), width: borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(38, 55, 74, 0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image (if any)
            if (hasImage)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: gradient == null ? backgroundColor : null,
                      gradient: gradient,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF26374A),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (ctx, err, stack) => Container(
                  decoration: BoxDecoration(
                    color: gradient == null ? backgroundColor : null,
                    gradient: gradient,
                  ),
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, size: 22, color: Color(0xFF758A9E)),
                  ),
                ),
              ),

            // 2. Subtle Darkening Overlay when image is active (for contrast)
            if (hasImage)
              Container(
                color: Colors.black.withValues(alpha: 0.12),
              ),

            // 3. Center Elements (Emoji & Vintage Title Plate)
            if (hasEmoji || hasCoverText)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Emoji
                      if (hasEmoji)
                        Text(
                          emoji!,
                          style: TextStyle(
                            fontSize: emojiSize,
                            height: 1.1,
                            shadows: hasImage
                                ? const [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                        ),

                      if (hasEmoji && hasCoverText)
                        const SizedBox(height: 6),

                    // Cover Text (Vintage Bookplate)
                    if (hasCoverText)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF26374A).withValues(alpha: 0.35),
                            width: 0.9,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: Text(
                          coverText!,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.serif(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 5. Optional Top-Right Action (Menu Button)
            if (topAction != null)
              Positioned(
                top: 2,
                right: 2,
                child: topAction!,
              ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: coverContent,
      );
    }

    return coverContent;
  }
}
