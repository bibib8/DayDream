import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/mood_model.dart';
import '../../providers/diary_provider.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int _selectedDay = DateTime.now().day.clamp(1, 31);
  String _activeMoodKey = 'happy';

  @override
  Widget build(BuildContext context) {
    final diaryProv = Provider.of<DiaryProvider>(context);
    final moodHistory = diaryProv.moodHistory;

    // Calculate Top State dynamically
    final hasMoodLogs = moodHistory.isNotEmpty;
    final moodCounts = <String, int>{};
    for (final log in moodHistory) {
      moodCounts[log.moodKey] = (moodCounts[log.moodKey] ?? 0) + 1;
    }
    String topMoodKey = 'happy';
    int maxCount = 0;
    moodCounts.forEach((key, count) {
      if (count > maxCount) {
        maxCount = count;
        topMoodKey = key;
      }
    });
    final topMood = MoodTypes.get(topMoodKey);
    final topPct = hasMoodLogs ? ((maxCount / moodHistory.length) * 100).round() : 0;

    String topStateHeadline;
    String topStateDesc;
    if (!hasMoodLogs) {
      topStateHeadline = "No Mood Logged Yet";
      topStateDesc = "Tap any mood or save a diary entry to track your emotional flow!";
    } else {
      switch (topMoodKey) {
        case 'happy':
          topStateHeadline = "Happy & Joyful";
          topStateDesc = "Your most frequent state ($topPct% of entries). Glowing with positivity!";
          break;
        case 'calm':
          topStateHeadline = "Calm & Grounded";
          topStateDesc = "Peaceful and steady in the quiet present ($topPct% of entries).";
          break;
        case 'productive':
          topStateHeadline = "Productive & Focused";
          topStateDesc = "High momentum and getting things done ($topPct% of entries).";
          break;
        case 'tired':
          topStateHeadline = "Resting & Recharging";
          topStateDesc = "Acknowledging low energy and prioritizing restoration ($topPct% of entries).";
          break;
        case 'stressed':
          topStateHeadline = "Under Pressure";
          topStateDesc = "Navigating challenges ($topPct% of entries). Remember to breathe deeply.";
          break;
        case 'down':
          topStateHeadline = "Gentle & Tender";
          topStateDesc = "Holding space for quiet feelings ($topPct% of entries). Be kind to yourself.";
          break;
        default:
          topStateHeadline = "${topMood.label} State";
          topStateDesc = "Recorded in $topPct% of entries this month.";
      }
    }

    // Calculate Daily Balance dynamically:
    int balancedDaysCount = 0;
    for (final log in moodHistory) {
      if (log.moodKey == 'happy' || log.moodKey == 'calm' || log.moodKey == 'productive') {
        balancedDaysCount++;
      }
    }
    final balanceScore = hasMoodLogs ? ((balancedDaysCount / moodHistory.length) * 100).round() : 0;
    final isHighBalance = balanceScore > 55;
    final heartEmoji = hasMoodLogs ? (isHighBalance ? '🤍' : '🖤') : '🤍';
    final balanceHeadline = hasMoodLogs ? "$balanceScore% Balanced" : "No logs yet";
    final balanceDesc = hasMoodLogs
        ? (isHighBalance
            ? "Balanced high-energy work with adequate recharge moments."
            : "Taking things slow, allowing gentle space to recharge.")
        : "Record your mood to see your positive balance score.";

    return Scaffold(
      backgroundColor: const Color(0xFFEDF5FC),
      body: Stack(
        children: [
          // 1. Top Lace Ribbon
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

          // 2. Main Scrollable Body
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── CARD 1: EMOTIONAL ARCHIVE / MONTHLY MOOD CALENDAR HEADER ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF241F3E), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(36, 31, 62, 0.04),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(36, 31, 62, 0.02),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "EMOTIONAL ARCHIVE",
                          style: AppTypography.sans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A5568),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Image.asset(
                          'assets/images/title_monthly_mood_calendar.png',
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${moodHistory.length} of 31 days recorded in archive",
                          style: AppTypography.sans(
                            fontSize: 12,
                            color: const Color(0xFF6C8299),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ─── CARD 2: OCTOBER 2026 CALENDAR GRID & LEGEND ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF241F3E), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(36, 31, 62, 0.04),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(36, 31, 62, 0.02),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "October 2026",
                              style: AppTypography.sans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              "Tap any date to check in",
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: const Color(0xFF6C8299),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Weekdays Row (Sun - Sat)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) {
                            return SizedBox(
                              width: 38,
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF26374A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),

                        // 31 Days Grid with soft hover elevation
                        GridView.builder(
                          shrinkWrap: true,
                          clipBehavior: Clip.none,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 0.95,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: 31 + 4,
                          itemBuilder: (context, idx) {
                            if (idx < 4) {
                              return const SizedBox.shrink();
                            }
                            final dayNum = idx - 3;
                            final log = moodHistory.firstWhere(
                              (m) => m.day == dayNum,
                              orElse: () => MoodLogItem(day: 0, date: '', moodKey: '', note: ''),
                            );
                            final isLogged = log.day > 0;
                            final mood = isLogged ? MoodTypes.get(log.moodKey) : null;
                            final todayDay = DateTime.now().day;
                            final isFuture = dayNum > todayDay;
                            final isSelected = !isFuture && dayNum == _selectedDay;

                            return _HoverCalendarDayCell(
                              dayNum: dayNum,
                              isFuture: isFuture,
                              isSelected: isSelected,
                              mood: mood,
                              onTap: isFuture
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedDay = dayNum;
                                        if (isLogged) {
                                          _activeMoodKey = log.moodKey;
                                        }
                                      });
                                    },
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // ─── MOOD LEGEND CHART ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLegendItem(MoodTypes.get('happy')),
                            _buildLegendItem(MoodTypes.get('calm')),
                            _buildLegendItem(MoodTypes.get('productive')),
                            _buildLegendItem(MoodTypes.get('tired')),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            _buildLegendItem(MoodTypes.get('stressed')),
                            const SizedBox(width: 18),
                            _buildLegendItem(MoodTypes.get('down')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ─── CARD 3: ARCHIVED DAILY MOOD (CHECK-IN PANEL) ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF241F3E), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(36, 31, 62, 0.04),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(36, 31, 62, 0.02),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "October $_selectedDay, 2026",
                          style: AppTypography.sans(
                            fontSize: 12,
                            color: const Color(0xFF6C8299),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Image.asset(
                          'assets/images/title_archived_daily_mood.png',
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          "Select Mood for Today:",
                          style: AppTypography.sans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF26374A),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mood selector pills with soft hover elevation
                        Row(
                          children: [
                            _HoverMoodSelectPill(
                              moodKey: 'happy',
                              isSelected: _activeMoodKey == 'happy',
                              onTap: () => setState(() => _activeMoodKey = 'happy'),
                            ),
                            const SizedBox(width: 8),
                            _HoverMoodSelectPill(
                              moodKey: 'calm',
                              isSelected: _activeMoodKey == 'calm',
                              onTap: () => setState(() => _activeMoodKey = 'calm'),
                            ),
                            const SizedBox(width: 8),
                            _HoverMoodSelectPill(
                              moodKey: 'productive',
                              isSelected: _activeMoodKey == 'productive',
                              onTap: () => setState(() => _activeMoodKey = 'productive'),
                            ),
                            const SizedBox(width: 8),
                            _HoverMoodSelectPill(
                              moodKey: 'tired',
                              isSelected: _activeMoodKey == 'tired',
                              onTap: () => setState(() => _activeMoodKey = 'tired'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _HoverMoodSelectPill(
                              moodKey: 'stressed',
                              isSelected: _activeMoodKey == 'stressed',
                              onTap: () => setState(() => _activeMoodKey = 'stressed'),
                            ),
                            const SizedBox(width: 8),
                            _HoverMoodSelectPill(
                              moodKey: 'down',
                              isSelected: _activeMoodKey == 'down',
                              onTap: () => setState(() => _activeMoodKey = 'down'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Save Mood Check-In Button with soft hover lift
                        _HoverSaveMoodButton(
                          onTap: () {
                            final todayDay = DateTime.now().day;
                            if (_selectedDay > todayDay) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Cannot check-in mood for future dates."),
                                  backgroundColor: Color(0xFFDC2626),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            diaryProv.logMood(_activeMoodKey, '', _selectedDay);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Logged ${MoodTypes.get(_activeMoodKey).label} for October $_selectedDay! ✨",
                                ),
                                backgroundColor: const Color(0xFF241F3E),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── SECTION 4: EMOTIONAL ANALYTICS (Non-hoverable / static as requested) ───
                  Text(
                    "EMOTIONAL ANALYTICS",
                    style: AppTypography.sans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C8299),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "October Mood Analysis",
                    style: AppTypography.sans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      // Card 1: TOP STATE (Static insight card, non-interactive)
                      Expanded(
                        child: _buildInsightCard(
                          title: "TOP STATE",
                          emoji: hasMoodLogs ? topMood.icon : '✨',
                          headline: topStateHeadline,
                          desc: topStateDesc,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Card 2: DAILY BALANCE (Static insight card, non-interactive)
                      Expanded(
                        child: _buildInsightCard(
                          title: "DAILY BALANCE",
                          emoji: heartEmoji,
                          headline: balanceHeadline,
                          desc: balanceDesc,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Legend pill below the calendar grid
  Widget _buildLegendItem(MoodType mood) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: mood.gradient,
            border: Border.all(color: const Color(0xFF241F3E), width: 1.2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          "${mood.icon} ${mood.label}",
          style: AppTypography.sans(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // Emotional analytics insight card - kept non-hoverable and static as requested, with refined soft ambient shadow
  Widget _buildInsightCard({
    required String title,
    required String emoji,
    required String headline,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 130),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF241F3E), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(36, 31, 62, 0.04),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color.fromRGBO(36, 31, 62, 0.015),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.sans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF241F3E),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  headline,
                  style: AppTypography.sans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: AppTypography.sans(
              fontSize: 11,
              color: const Color(0xFF6C8299),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ─── REFINED HOVER COMPONENTS FOR MOOD TRACKER SCREEN ────────
// ─────────────────────────────────────────────────────────────

/// Calendar Day Cell with soft hover elevation, diffused glow, and zero harsh gray overlay.
class _HoverCalendarDayCell extends StatefulWidget {
  final int dayNum;
  final bool isFuture;
  final bool isSelected;
  final MoodType? mood;
  final VoidCallback? onTap;

  const _HoverCalendarDayCell({
    required this.dayNum,
    required this.isFuture,
    required this.isSelected,
    this.mood,
    this.onTap,
  });

  @override
  State<_HoverCalendarDayCell> createState() => _HoverCalendarDayCellState();
}

class _HoverCalendarDayCellState extends State<_HoverCalendarDayCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final canInteract = !widget.isFuture && widget.onTap != null;

    return MouseRegion(
      cursor: widget.isFuture ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) {
        if (canInteract) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (canInteract) setState(() => _isHovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, (_isHovered && canInteract) ? -2.5 : 0, 0),
        decoration: BoxDecoration(
          gradient: widget.isFuture ? null : widget.mood?.gradient,
          color: widget.isFuture
              ? const Color(0xFFF1F5F9).withValues(alpha: 0.6)
              : (widget.mood == null ? Colors.white : null),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isFuture
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF241F3E),
            width: widget.isSelected ? 2.4 : (widget.isFuture ? 1.0 : (_isHovered ? 1.5 : 1.3)),
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF241F3E).withValues(alpha: _isHovered ? 0.22 : 0.16),
                    blurRadius: _isHovered ? 10 : 6,
                    offset: Offset(0, _isHovered ? 3 : 2),
                  ),
                  BoxShadow(
                    color: const Color(0xFF241F3E).withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : (_isHovered && canInteract)
                  ? [
                      BoxShadow(
                        color: const Color(0xFF241F3E).withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: 0.5,
                      ),
                      BoxShadow(
                        color: const Color(0xFF241F3E).withValues(alpha: 0.03),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.isFuture ? null : widget.onTap,
            hoverColor: Colors.transparent,
            splashColor: const Color(0xFF241F3E).withValues(alpha: 0.06),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned(
                  top: 3,
                  right: 5,
                  child: Text(
                    "${widget.dayNum}",
                    style: AppTypography.sans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: widget.isFuture ? const Color(0xFF94A3B8) : Colors.black,
                    ),
                  ),
                ),
                if (!widget.isFuture && widget.mood != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        widget.mood!.icon,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mood Selection Pill with soft ambient hover glow and gentle elevation.
class _HoverMoodSelectPill extends StatefulWidget {
  final String moodKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _HoverMoodSelectPill({
    required this.moodKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HoverMoodSelectPill> createState() => _HoverMoodSelectPillState();
}

class _HoverMoodSelectPillState extends State<_HoverMoodSelectPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final mood = MoodTypes.get(widget.moodKey);

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -2.5 : 0, 0),
          decoration: BoxDecoration(
            gradient: mood.gradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF241F3E),
              width: widget.isSelected ? 2.2 : (_isHovered ? 1.5 : 1.3),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF241F3E).withValues(alpha: widget.isSelected ? 0.22 : 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0.5,
                    ),
                    BoxShadow(
                      color: const Color(0xFF241F3E).withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : widget.isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF241F3E).withValues(alpha: 0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color.fromRGBO(36, 31, 62, 0.04),
                          blurRadius: 4,
                          offset: Offset(0, 1.5),
                        ),
                      ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: widget.onTap,
              hoverColor: Colors.transparent,
              splashColor: const Color(0xFF241F3E).withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    mood.label,
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
        ),
      ),
    );
  }
}

/// Save Mood Check-in Pill Button with soft ambient shadow.
class _HoverSaveMoodButton extends StatefulWidget {
  final VoidCallback onTap;

  const _HoverSaveMoodButton({required this.onTap});

  @override
  State<_HoverSaveMoodButton> createState() => _HoverSaveMoodButtonState();
}

class _HoverSaveMoodButtonState extends State<_HoverSaveMoodButton> {
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
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: const Color(0xFF241F3E),
            width: _isHovered ? 1.5 : 1.4,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF241F3E).withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0.5,
                  ),
                  BoxShadow(
                    color: const Color(0xFF241F3E).withValues(alpha: 0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(36, 31, 62, 0.04),
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
            splashColor: const Color(0xFF241F3E).withValues(alpha: 0.06),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  "Save Mood Check-In",
                  style: AppTypography.sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF241F3E),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
