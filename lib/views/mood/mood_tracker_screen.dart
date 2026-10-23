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

const List<String> _kMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  static const int _kMaxPastMonths = 120; // 10 years of past history
  late final PageController _pageController;
  late DateTime _displayedMonth;
  late int _selectedDay;
  String _activeMoodKey = 'happy';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;
    _pageController = PageController(initialPage: _kMaxPastMonths);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) {
    final now = DateTime.now();
    final monthsAgo = _kMaxPastMonths - page;
    return DateTime(now.year, now.month - monthsAgo, 1);
  }

  int _pageForMonth(DateTime month) {
    final now = DateTime.now();
    final monthsAgo = (now.year - month.year) * 12 + (now.month - month.month);
    return _kMaxPastMonths - monthsAgo;
  }

  void _onPageChanged(int page) {
    final newMonth = _monthForPage(page);
    final daysInNewMonth = DateTime(newMonth.year, newMonth.month + 1, 0).day;
    final now = DateTime.now();
    final isNowMonth = newMonth.year == now.year && newMonth.month == now.month;

    setState(() {
      _displayedMonth = newMonth;
      if (isNowMonth) {
        _selectedDay = now.day.clamp(1, daysInNewMonth);
      } else {
        _selectedDay = _selectedDay.clamp(1, daysInNewMonth);
      }
      final diaryProv = Provider.of<DiaryProvider>(context, listen: false);
      final log = diaryProv.moodHistory.firstWhere(
        (m) =>
            m.matchesMonth(_displayedMonth.year, _displayedMonth.month) &&
            m.dayOfMonth == _selectedDay,
        orElse: () => MoodLogItem(day: 0, date: '', moodKey: '', note: ''),
      );
      if (log.dayOfMonth > 0) {
        _activeMoodKey = log.moodKey;
      }
    });
  }

  void _goToPreviousMonth() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    final isCurrentMonth =
        _displayedMonth.year == now.year && _displayedMonth.month == now.month;
    if (!isCurrentMonth && _pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToCurrentMonth() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _kMaxPastMonths,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final diaryProv = Provider.of<DiaryProvider>(context);
    final moodHistory = diaryProv.moodHistory;

    final now = DateTime.now();
    final isCurrentMonth =
        _displayedMonth.year == now.year && _displayedMonth.month == now.month;
    final canGoNext = !isCurrentMonth;
    final canGoPrev = _pageForMonth(_displayedMonth) > 0;
    final monthName = _kMonthNames[_displayedMonth.month - 1];
    final monthYearTitle = "$monthName ${_displayedMonth.year}";
    final daysInDisplayedMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

    // Filter mood history for the currently viewed month
    final displayedMonthMoods = moodHistory
        .where((m) =>
            m.matchesMonth(_displayedMonth.year, _displayedMonth.month))
        .toList();
    final hasMoodLogs = displayedMonthMoods.isNotEmpty;

    final moodCounts = <String, int>{};
    for (final log in displayedMonthMoods) {
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
    final topPct = hasMoodLogs
        ? ((maxCount / displayedMonthMoods.length) * 100).round()
        : 0;

    String topStateHeadline;
    String topStateDesc;
    if (!hasMoodLogs) {
      topStateHeadline = "No Mood Logged Yet";
      topStateDesc =
          "Tap any mood or save a diary entry to track your emotional flow!";
    } else {
      switch (topMoodKey) {
        case 'happy':
          topStateHeadline = "Happy & Joyful";
          topStateDesc =
              "Your most frequent state ($topPct% of entries in $monthName). Glowing with positivity!";
          break;
        case 'calm':
          topStateHeadline = "Calm & Grounded";
          topStateDesc =
              "Peaceful and steady in the quiet present ($topPct% of entries in $monthName).";
          break;
        case 'productive':
          topStateHeadline = "Productive & Focused";
          topStateDesc =
              "High momentum and getting things done ($topPct% of entries in $monthName).";
          break;
        case 'tired':
          topStateHeadline = "Resting & Recharging";
          topStateDesc =
              "Acknowledging low energy and prioritizing restoration ($topPct% of entries in $monthName).";
          break;
        case 'stressed':
          topStateHeadline = "Under Pressure";
          topStateDesc =
              "Navigating challenges ($topPct% of entries in $monthName). Remember to breathe deeply.";
          break;
        case 'down':
          topStateHeadline = "Gentle & Tender";
          topStateDesc =
              "Holding space for quiet feelings ($topPct% of entries in $monthName). Be kind to yourself.";
          break;
        default:
          topStateHeadline = "${topMood.label} State";
          topStateDesc = "Recorded in $topPct% of entries in $monthName.";
      }
    }

    // Calculate Daily Balance dynamically for the displayed month:
    int balancedDaysCount = 0;
    for (final log in displayedMonthMoods) {
      if (log.moodKey == 'happy' ||
          log.moodKey == 'calm' ||
          log.moodKey == 'productive') {
        balancedDaysCount++;
      }
    }
    final balanceScore = hasMoodLogs
        ? ((balancedDaysCount / displayedMonthMoods.length) * 100).round()
        : 0;
    final isHighBalance = balanceScore > 55;
    final heartEmoji = hasMoodLogs ? (isHighBalance ? '🤍' : '🖤') : '🤍';
    final balanceHeadline =
        hasMoodLogs ? "$balanceScore% Balanced" : "No logs yet";
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

          // 2. Main Scrollable Body
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
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
                          "${displayedMonthMoods.length} of $daysInDisplayedMonth days recorded in archive",
                          style: AppTypography.sans(
                            fontSize: 12,
                            color: const Color(0xFF6C8299),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ─── CARD 2: MONTHLY MOOD CALENDAR GRID & LEGEND ───
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
                        // Month Header Row with Navigation Controls
                        Row(
                          children: [
                            Text(
                              monthYearTitle,
                              style: AppTypography.sans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _MonthNavButton(
                              icon: Icons.chevron_left_rounded,
                              tooltip: "Previous Month",
                              onPressed: canGoPrev ? _goToPreviousMonth : null,
                            ),
                            const SizedBox(width: 6),
                            _MonthNavButton(
                              icon: Icons.chevron_right_rounded,
                              tooltip: canGoNext ? "Next Month" : "Future month locked",
                              onPressed: canGoNext ? _goToNextMonth : null,
                            ),
                            if (!isCurrentMonth) ...[
                              const SizedBox(width: 8),
                              _ThisMonthPill(onTap: _goToCurrentMonth),
                            ],
                            const Spacer(),
                            Text(
                              "Tap date to check in",
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

                        // PageView for smooth horizontal month swiping on mobile & arrows on desktop
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth;
                            final cellWidth = (availableWidth - (6 * 6)) / 7;
                            final cellHeight = cellWidth / 0.95;

                            // Calculate exact rows needed for the currently displayed month
                            final firstOffset = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;
                            final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
                            final totalCells = firstOffset + daysInMonth;
                            final rowsCount = (totalCells / 7).ceil();
                            final gridHeight = (rowsCount * cellHeight) + ((rowsCount - 1) * 6) + 2;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOutCubic,
                              height: gridHeight,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _kMaxPastMonths + 1,
                                onPageChanged: _onPageChanged,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, page) {
                                  final pageMonth = _monthForPage(page);
                                  return _buildCalendarGridForMonth(pageMonth, moodHistory);
                                },
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // ─── MOOD LEGEND CHART ───
                        Wrap(
                          spacing: 20,
                          runSpacing: 10,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: MoodTypes.all.values.map(_buildLegendItem).toList(),
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
                          "$monthName $_selectedDay, ${_displayedMonth.year}",
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
                          "Select Mood for ${isCurrentMonth && _selectedDay == now.day ? 'Today' : 'Day $_selectedDay'}:",
                          style: AppTypography.sans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF26374A),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mood selector pills with soft hover elevation
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 580;
                            final moodsList = MoodTypes.all.values.toList();
                            if (isWide) {
                              return Row(
                                children: moodsList.map((mood) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: _HoverMoodSelectPill(
                                        moodKey: mood.key,
                                        isSelected: _activeMoodKey == mood.key,
                                        onTap: () => setState(() => _activeMoodKey = mood.key),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                            return Column(
                              children: [
                                Row(
                                  children: moodsList.sublist(0, 3).map((mood) {
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: _HoverMoodSelectPill(
                                          moodKey: mood.key,
                                          isSelected: _activeMoodKey == mood.key,
                                          onTap: () => setState(() => _activeMoodKey = mood.key),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: moodsList.sublist(3, 6).map((mood) {
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: _HoverMoodSelectPill(
                                          moodKey: mood.key,
                                          isSelected: _activeMoodKey == mood.key,
                                          onTap: () => setState(() => _activeMoodKey = mood.key),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Save Mood Check-In Button with soft hover lift
                        _HoverSaveMoodButton(
                          onTap: () {
                            final selectedDate = DateTime(
                              _displayedMonth.year,
                              _displayedMonth.month,
                              _selectedDay,
                            );
                            final today = DateTime(now.year, now.month, now.day);
                            if (selectedDate.isAfter(today)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Cannot check-in mood for future dates."),
                                  backgroundColor: Color(0xFFDC2626),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            diaryProv.logMood(_activeMoodKey, '', selectedDate);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Logged ${MoodTypes.get(_activeMoodKey).label} for $monthName $_selectedDay, ${_displayedMonth.year}! ✨",
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
                    "$monthName Mood Analysis",
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
        ),
      ),
    ],
  ),
);
  }

  /// Builds the 7-column calendar grid for a specific month page in PageView
  Widget _buildCalendarGridForMonth(DateTime month, List<MoodLogItem> allMoods) {
    final firstWeekdayOffset = DateTime(month.year, month.month, 1).weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = firstWeekdayOffset + daysInMonth;
    final now = DateTime.now();
    final isNowMonth = month.year == now.year && month.month == now.month;

    return GridView.builder(
      shrinkWrap: true,
      clipBehavior: Clip.none,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.95,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: totalCells,
      itemBuilder: (context, idx) {
        if (idx < firstWeekdayOffset) {
          return const SizedBox.shrink();
        }
        final dayNum = idx - firstWeekdayOffset + 1;
        final isFuture = isNowMonth && (dayNum > now.day);
        final isSelected = (_displayedMonth.year == month.year &&
            _displayedMonth.month == month.month &&
            dayNum == _selectedDay);

        final log = allMoods.firstWhere(
          (m) =>
              m.matchesMonth(month.year, month.month) &&
              m.dayOfMonth == dayNum,
          orElse: () => MoodLogItem(day: 0, date: '', moodKey: '', note: ''),
        );
        final isLogged = log.dayOfMonth > 0;
        final mood = isLogged ? MoodTypes.get(log.moodKey) : null;

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

    return MouseRegion(
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

/// Vintage circular navigation button for calendar month switching (Previous / Next)
class _MonthNavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _MonthNavButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
  });

  @override
  State<_MonthNavButton> createState() => _MonthNavButtonState();
}

class _MonthNavButtonState extends State<_MonthNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        onEnter: (_) {
          if (isEnabled) setState(() => _isHovered = true);
        },
        onExit: (_) {
          if (isEnabled) setState(() => _isHovered = false);
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled
                  ? (_isHovered ? const Color(0xFFF1F5FC) : Colors.white)
                  : const Color(0xFFF1F5F9),
              border: Border.all(
                color: isEnabled
                    ? const Color(0xFF241F3E)
                    : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
              boxShadow: (isEnabled && _isHovered)
                  ? const [
                      BoxShadow(
                        color: Color.fromRGBO(36, 31, 62, 0.12),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: isEnabled
                  ? const Color(0xFF241F3E)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}

/// Delicate "This Month" badge pill to jump back to current month from past archives
class _ThisMonthPill extends StatefulWidget {
  final VoidCallback onTap;

  const _ThisMonthPill({required this.onTap});

  @override
  State<_ThisMonthPill> createState() => _ThisMonthPillState();
}

class _ThisMonthPillState extends State<_ThisMonthPill> {
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFE2F0FD) : const Color(0xFFFFFDF3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF241F3E), width: 1.2),
            boxShadow: _isHovered
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(36, 31, 62, 0.10),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            "This Month",
            style: AppTypography.sans(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF241F3E),
            ),
          ),
        ),
      ),
    );
  }
}
