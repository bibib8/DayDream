import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/diary_model.dart';
import '../../data/models/entry_model.dart';
import '../../data/models/mood_model.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/diary_form_dialog.dart';
import '../../widgets/settings_dialog.dart';
import '../../widgets/user_avatar_view.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProv = Provider.of<DiaryProvider>(context);
    final user = diaryProv.user;
    final diaries = diaryProv.diaries;
    final entries = diaryProv.entries;

    // Determine today's logged mood (if any)
    final now = DateTime.now();
    final todayMoodLog = diaryProv.moodHistory
        .where((m) => m.matchesMonth(now.year, now.month) && m.dayOfMonth == now.day)
        .toList();
    final todayMoodKey = todayMoodLog.isNotEmpty ? todayMoodLog.last.moodKey : null;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF5FC),
      body: Stack(
        children: [
          // 1. Top Lace Ribbon attached to top edge
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 52,
            child: SafeArea(
              bottom: false,
              child: Image.asset(
                'assets/images/lace_top.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // 2. Main Scrollable Viewport
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const SizedBox(height: 20),

                  // ─── CARD 1: USER GREETING & DAILY PROMPT ───
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF26374A), width: 1.4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(38, 55, 74, 0.04),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(38, 55, 74, 0.02),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: "Hi, Darling" Graphic + Log Out Pill Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/title_hi_darling.png',
                              height: 58,
                              fit: BoxFit.contain,
                            ),
                            _HoverPillButton(
                              onTap: () => SettingsDialog.show(context, diaryProv),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.settings_outlined, size: 14, color: Color(0xFF26374A)),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Settings",
                                    style: AppTypography.sans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF26374A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // User Pen Name & Date with Avatar
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => SettingsDialog.show(context, diaryProv),
                              child: Tooltip(
                                message: "Open Settings",
                                child: UserAvatarView(
                                  avatar: user.avatar,
                                  size: 44,
                                  borderWidth: 1.2,
                                ),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                                    style: AppTypography.sans(
                                      fontSize: 13,
                                      color: const Color(0xFF6C8299),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Daily Prompt Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F1FC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF26374A), width: 1.3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(38, 55, 74, 0.03),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Daily Prompt",
                                    style: AppTypography.sans(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  _HoverTextAction(
                                    onTap: diaryProv.cyclePrompt,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.shuffle_rounded, size: 16, color: Color(0xFF26374A)),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Shuffle",
                                          style: AppTypography.sans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF26374A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => diaryProv.startFromDailyPrompt(),
                                hoverColor: Colors.transparent,
                                child: Text(
                                  diaryProv.currentPrompt,
                                  style: AppTypography.sans(
                                    fontSize: 13,
                                    color: const Color(0xFF475569),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _HoverPillButton(
                                onTap: () => diaryProv.startFromDailyPrompt(),
                                backgroundColor: const Color(0xFFFFFDF0),
                                border: Border.all(color: const Color(0xFF26374A), width: 1.3),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF26374A)),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Answer Prompt",
                                      style: AppTypography.sans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF26374A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 4 Stat Counters Row
                        Row(
                          children: [
                            Expanded(child: _HoverStatPill(number: "${user.streakDays}", label: "Streak")),
                            const SizedBox(width: 8),
                            Expanded(child: _HoverStatPill(number: "${diaries.length}", label: "Diaries")),
                            const SizedBox(width: 8),
                            Expanded(child: _HoverStatPill(number: "${entries.length}", label: "Pages")),
                            const SizedBox(width: 8),
                            Expanded(child: _HoverStatPill(number: "${diaryProv.moodHistory.length}", label: "Moods")),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ─── CARD 2: DAILY MOOD CHECK-IN ───
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF26374A), width: 1.4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(38, 55, 74, 0.04),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(38, 55, 74, 0.02),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Title Graphic + View Calendar Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/title_daily_mood_checkin.png',
                              height: 25,
                              fit: BoxFit.contain,
                            ),
                            _HoverTextAction(
                              onTap: () => diaryProv.setNavIndex(4), // Navigate to Mood screen
                              child: Text(
                                "View Calendar →",
                                style: AppTypography.sans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF26374A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // All 6 Mood Choices with soft hover pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: MoodTypes.all.values.map((mood) {
                            final isSelected = todayMoodKey == mood.key;
                            return _HoverMoodPill(
                              mood: mood,
                              isSelected: isSelected,
                              onTap: () {
                                diaryProv.logMood(mood.key);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Logged today as ${mood.label} ${mood.icon} ✨"),
                                    backgroundColor: const Color(0xFF26374A),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── SECTION 3: THE ARCHIVE / THE DIARY SHELF ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "THE ARCHIVE",
                            style: AppTypography.sans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6C8299),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "The Diary Shelf",
                            style: AppTypography.sans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      _HoverPillButton(
                        onTap: () => _showCreateDiaryDialog(context, diaryProv),
                        backgroundColor: const Color(0xFFFFFDF0),
                        border: Border.all(color: const Color(0xFF26374A), width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Text(
                          "+ New Diary",
                          style: AppTypography.sans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF26374A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Responsive Grid matching screen size
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 780
                          ? 4
                          : (constraints.maxWidth > 480 ? 3 : 2);
                      final childAspect = crossAxisCount >= 4
                          ? 0.72
                          : (crossAxisCount == 3 ? 0.71 : 0.70);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        clipBehavior: Clip.none,
                        itemCount: diaries.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: childAspect,
                        ),
                        itemBuilder: (context, idx) {
                          final diary = diaries[idx];
                          return _HoverDiaryBookCard(
                            diary: diary,
                            onTap: () => diaryProv.openDiary(diary.id),
                            onEdit: (d) => _showEditDiaryDialog(context, diaryProv, d),
                            onDelete: (d) => _showDeleteDiaryDialog(context, diaryProv, d),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ─── SECTION 4: RECENT PAGES & MEMORIES (Hidden for new users until first page is saved) ───
                  if (entries.isNotEmpty) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RECENT PAGES & MEMORIES",
                          style: AppTypography.sans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C8299),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Recent Pages",
                          style: AppTypography.sans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Recent Entry Cards with smooth hover elevation and soft ambient shadows
                    ...entries.map((entry) {
                      return _HoverRecentPageCard(
                        entry: entry,
                        onTap: () => diaryProv.openEntry(entry.id),
                      );
                    }),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }

  void _showCreateDiaryDialog(BuildContext context, DiaryProvider prov) {
    DiaryFormDialog.show(context, prov);
  }

  void _showEditDiaryDialog(BuildContext context, DiaryProvider prov, DiaryModel diary) {
    DiaryFormDialog.show(context, prov, diary: diary);
  }

  void _showDeleteDiaryDialog(BuildContext context, DiaryProvider prov, DiaryModel diary) {
    showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(38, 55, 74, 0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEF6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF26374A), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(38, 55, 74, 0.12),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color.fromRGBO(38, 55, 74, 0.03),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Delete Diary",
                style: AppTypography.sans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to delete '${diary.title}' and all its pages? This action cannot be undone.",
                style: AppTypography.sans(fontSize: 13.5, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text("Cancel", style: AppTypography.sans(color: const Color(0xFF6C8299))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await prov.deleteDiary(diary.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFFDC2626).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text("Delete", style: AppTypography.sans(color: Colors.white, fontWeight: FontWeight.bold)),
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

// ─────────────────────────────────────────────────────────────
// ─── REFINED HOVER COMPONENTS WITH SOFT, LAYERED SHADOWS ─────
// ─────────────────────────────────────────────────────────────

/// Horizontal Diary Shelf Card with gentle lift and dreamy diffused shadow.
class _HoverDiaryBookCard extends StatefulWidget {
  final DiaryModel diary;
  final VoidCallback onTap;
  final void Function(DiaryModel) onEdit;
  final void Function(DiaryModel) onDelete;

  const _HoverDiaryBookCard({
    required this.diary,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_HoverDiaryBookCard> createState() => _HoverDiaryBookCardState();
}

class _HoverDiaryBookCardState extends State<_HoverDiaryBookCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final diaryProv = Provider.of<DiaryProvider>(context);
    final diaryEntries = diaryProv.entries.where((e) => e.diaryId == widget.diary.id).toList();
    final pageCount = diaryEntries.isNotEmpty ? diaryEntries.length : widget.diary.entriesCount;
    final hasImage = widget.diary.coverImageUrl != null && widget.diary.coverImageUrl!.trim().isNotEmpty;
    final hasEmoji = widget.diary.coverEmoji != null && widget.diary.coverEmoji!.trim().isNotEmpty;
    final hasCoverText = widget.diary.coverText != null && widget.diary.coverText!.trim().isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: widget.diary.color,
          gradient: widget.diary.gradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF26374A),
            width: _isHovered ? 1.6 : 1.4,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(38, 55, 74, 0.07),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(38, 55, 74, 0.02),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full-bleed Cover Background Image (if present)
              if (hasImage)
                Image.network(
                  widget.diary.coverImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (ctx, err, stack) => Container(
                    decoration: BoxDecoration(
                      color: widget.diary.color,
                      gradient: widget.diary.gradient,
                    ),
                  ),
                ),

              // 2. Readability Gradient Overlay for Image covers
              if (hasImage) ...[
                Container(
                  color: Colors.black.withValues(alpha: 0.08),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 140,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // 3. Center Emoji or Cover Text
              if (hasEmoji || hasCoverText)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 58),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasEmoji)
                          Text(
                            widget.diary.coverEmoji!,
                            style: TextStyle(
                              fontSize: 32,
                              shadows: hasImage
                                  ? const [
                                      Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
                                    ]
                                  : null,
                            ),
                          ),
                        if (hasCoverText) ...[
                          if (hasEmoji) const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF26374A).withValues(alpha: 0.35),
                              width: 0.9,
                            ),
                          ),
                          child: Text(
                            widget.diary.coverText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.serif(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // 5. Main Clickable InkWell Area
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  splashColor: const Color(0xFF26374A).withValues(alpha: 0.05),
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Spacer + Popup Menu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 20),
                            PopupMenuButton<String>(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: hasImage ? Colors.black45 : Colors.white.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(38, 55, 74, 0.08),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.more_vert_rounded,
                                  size: 16,
                                  color: hasImage ? Colors.white : const Color(0xFF26374A),
                                ),
                              ),
                              color: const Color(0xFFFFFEF6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: Color(0xFF26374A), width: 1.2),
                              ),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  widget.onEdit(widget.diary);
                                } else if (val == 'delete') {
                                  widget.onDelete(widget.diary);
                                }
                              },
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF26374A)),
                                      const SizedBox(width: 8),
                                      Text("Edit Diary", style: AppTypography.sans(fontSize: 12.5)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Delete Diary",
                                        style: AppTypography.sans(fontSize: 12.5, color: const Color(0xFFDC2626)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Bottom Info: Title, Description, Pill Badge
                        Text(
                          widget.diary.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: hasImage ? Colors.white : const Color(0xFF1E293B),
                          ).copyWith(
                            shadows: hasImage
                                ? const [
                                    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                                  ]
                                : null,
                          ),
                        ),
                        if (widget.diary.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.diary.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              fontSize: 10.5,
                              color: hasImage
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : const Color(0xFF475569),
                              height: 1.25,
                            ).copyWith(
                              shadows: hasImage
                                  ? const [
                                      Shadow(color: Colors.black54, blurRadius: 3, offset: Offset(0, 1)),
                                    ]
                                : null,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),

                        // Page Count Pill (matching mockup)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF0),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: const Color(0xFF26374A), width: 1.2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(38, 55, 74, 0.08),
                                blurRadius: 4,
                                offset: Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: Text(
                            "$pageCount ${pageCount == 1 ? 'Page' : 'Pages'}",
                            style: AppTypography.sans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF26374A),
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
        ),
      ),
    );
  }
}

/// Recent Page Entry Card with smooth hover lift and soft diffused shadow.
class _HoverRecentPageCard extends StatefulWidget {
  final EntryModel entry;
  final VoidCallback onTap;

  const _HoverRecentPageCard({
    required this.entry,
    required this.onTap,
  });

  @override
  State<_HoverRecentPageCard> createState() => _HoverRecentPageCardState();
}

class _HoverRecentPageCardState extends State<_HoverRecentPageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 14),
        transform: Matrix4.translationValues(0, _isHovered ? -3.5 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF26374A),
            width: _isHovered ? 1.5 : 1.4,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(38, 55, 74, 0.04),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(38, 55, 74, 0.015),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            splashColor: const Color(0xFF26374A).withValues(alpha: 0.04),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.entry.date,
                        style: AppTypography.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C8299),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(_isHovered ? 3 : 0, 0, 0),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFF26374A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.entry.title,
                    style: AppTypography.sans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.entry.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(
                      fontSize: 12,
                      color: const Color(0xFF6C8299),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mood Pill with soft ambient colored shadow and gentle hover elevation.
class _HoverMoodPill extends StatefulWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _HoverMoodPill({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HoverMoodPill> createState() => _HoverMoodPillState();
}

class _HoverMoodPillState extends State<_HoverMoodPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2.5 : 0, 0),
        decoration: BoxDecoration(
          gradient: widget.mood.gradient,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: const Color(0xFF241F3E),
            width: widget.isSelected ? 2.2 : 1.3,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF241F3E).withValues(alpha: widget.isSelected ? 0.22 : 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                    spreadRadius: 0.5,
                  ),
                  BoxShadow(
                    color: const Color(0xFF241F3E).withValues(alpha: 0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : widget.isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF241F3E).withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                      BoxShadow(
                        color: const Color(0xFF241F3E).withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color.fromRGBO(38, 55, 74, 0.04),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            splashColor: const Color(0xFF241F3E).withValues(alpha: 0.08),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Text(
                widget.mood.label,
                style: AppTypography.sans(
                  fontSize: 12,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Generic Pill Button with soft ambient shadow on hover.
class _HoverPillButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Border? border;
  final EdgeInsetsGeometry padding;

  const _HoverPillButton({
    required this.child,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.border,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  });

  @override
  State<_HoverPillButton> createState() => _HoverPillButtonState();
}

class _HoverPillButtonState extends State<_HoverPillButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2.0 : 0, 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(50),
          border: widget.border ?? Border.all(color: const Color(0xFF26374A), width: 1.2),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.09),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                    spreadRadius: 0.5,
                  ),
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(38, 55, 74, 0.035),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            splashColor: const Color(0xFF26374A).withValues(alpha: 0.06),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stat counter card with delicate soft hover elevation.
class _HoverStatPill extends StatefulWidget {
  final String number;
  final String label;

  const _HoverStatPill({
    required this.number,
    required this.label,
  });

  @override
  State<_HoverStatPill> createState() => _HoverStatPillState();
}

class _HoverStatPillState extends State<_HoverStatPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2.0 : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 10),
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
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                    spreadRadius: 0.5,
                  ),
                  BoxShadow(
                    color: const Color(0xFF26374A).withValues(alpha: 0.025),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(38, 55, 74, 0.03),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.number,
              style: AppTypography.sans(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.label,
              style: AppTypography.sans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtle text action button with mouse pointer and micro-shift.
class _HoverTextAction extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverTextAction({
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverTextAction> createState() => _HoverTextActionState();
}

class _HoverTextActionState extends State<_HoverTextAction> {
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
          transform: Matrix4.translationValues(_isHovered ? 2.0 : 0, 0, 0),
          child: widget.child,
        ),
      ),
    );
  }
}
