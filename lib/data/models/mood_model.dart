import 'package:flutter/material.dart';

class MoodType {
  final String key;
  final String label;
  final String icon;
  final Color color;
  final Color accent;
  final Color gradientTop;
  final Color gradientBottom;
  final String description;

  const MoodType({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.accent,
    required this.gradientTop,
    required this.gradientBottom,
    required this.description,
  });

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientBottom],
  );
}

class MoodTypes {
  static const Map<String, MoodType> all = {
    'happy': MoodType(
      key: 'happy',
      label: 'Happy',
      icon: '😊',
      color: Color(0xFFF9D4F4),
      accent: Color(0xFF241F3E),
      gradientTop: Color(0xFFFEF8FD),
      gradientBottom: Color(0xFFF9D4F4),
      description: 'Feeling cheerful, lighthearted, and satisfied with your day.',
    ),
    'calm': MoodType(
      key: 'calm',
      label: 'Calm',
      icon: '😌',
      color: Color(0xFFF9F6D5),
      accent: Color(0xFF241F3E),
      gradientTop: Color(0xFFFFFDF3),
      gradientBottom: Color(0xFFF9F6D5),
      description: 'Peaceful, grounded, and steady in the quiet present.',
    ),
    'productive': MoodType(
      key: 'productive',
      label: 'Productive',
      icon: '⚡',
      color: Color(0xFFE2F2FD),
      accent: Color(0xFF241F3E),
      gradientTop: Color(0xFFEFF7FC),
      gradientBottom: Color(0xFFE2F2FD),
      description: 'Motivated, focused, getting things done with great momentum.',
    ),
    'tired': MoodType(
      key: 'tired',
      label: 'Tired',
      icon: '🥱',
      color: Color(0xFFC7CEF2),
      accent: Color(0xFF241F3E),
      gradientTop: Color(0xFFEBF1FC),
      gradientBottom: Color(0xFFC7CEF2),
      description: 'Low battery, physically or mentally drained, needing rest.',
    ),
    'stressed': MoodType(
      key: 'stressed',
      label: 'Stressed',
      icon: '😰',
      color: Color(0xFFE9E5FE),
      accent: Color(0xFF241F3E),
      gradientTop: Color(0xFFF1F5FC),
      gradientBottom: Color(0xFFE9E5FE),
      description: 'Under pressure, uneasy, tense, or juggling too many thoughts.',
    ),
    'down': MoodType(
      key: 'down',
      label: 'Down',
      icon: '🌧️',
      color: Color(0xFFD2D4D5),
      accent: Color(0xFF241F3E),
      gradientTop: Color(0xFFEDF2F6),
      gradientBottom: Color(0xFFD2D4D5),
      description: 'Feeling low, tender, quiet, or needing comforting space.',
    ),
  };

  static MoodType get(String key) => all[key] ?? all['happy']!;
}

class MoodLogItem {
  final int day;
  final String date;
  final String moodKey;
  final String note;

  MoodLogItem({
    required this.day,
    required this.date,
    required this.moodKey,
    required this.note,
  });

  factory MoodLogItem.fromJson(Map<String, dynamic> json) {
    return MoodLogItem(
      day: (json['day'] as num?)?.toInt() ?? 1,
      date: json['log_date']?.toString() ?? json['date']?.toString() ?? '',
      moodKey: json['mood_key']?.toString() ?? json['moodKey']?.toString() ?? 'happy',
      note: json['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'log_date': date,
      'mood_key': moodKey,
      'note': note,
    };
  }

  /// Helper to check if this mood log belongs to the specified year and month
  bool matchesMonth(int year, int month) {
    if (date.isNotEmpty) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        return parsed.year == year && parsed.month == month;
      }
    }
    final now = DateTime.now();
    return now.year == year && now.month == month;
  }

  /// Day number (1..31) extracted from date string or fallback day
  int get dayOfMonth {
    if (date.isNotEmpty) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return parsed.day;
    }
    return day;
  }
}
