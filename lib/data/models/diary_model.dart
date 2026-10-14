import 'dart:convert';
import 'package:flutter/material.dart';

class DiaryModel {
  final String id;
  final String title;
  final String subtitle;
  final String coverStyle;
  final Color color;
  final List<Color>? gradientColors;
  final Color accent;
  final int entriesCount;
  final String lastEdited;
  final String pattern;
  final bool isPrivate;
  final String description;
  final String? coverImageUrl;
  final String? coverEmoji;
  final String? coverText;

  DiaryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverStyle,
    required this.color,
    this.gradientColors,
    required this.accent,
    required this.entriesCount,
    required this.lastEdited,
    required this.pattern,
    required this.isPrivate,
    required this.description,
    this.coverImageUrl,
    this.coverEmoji,
    this.coverText,
  });

  LinearGradient get gradient {
    if (gradientColors != null && gradientColors!.length >= 2) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors!,
      );
    }
    final top = Color.lerp(Colors.white, color, 0.45) ?? color;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [top, color],
    );
  }

  String get coverColorHex {
    if (gradientColors != null && gradientColors!.length >= 2) {
      final hex1 = '#${gradientColors![0].toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      final hex2 = '#${gradientColors![1].toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      return '$hex1,$hex2';
    }
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  factory DiaryModel.fromJson(Map<String, dynamic> json) {
    final coverColorRaw = json['cover_color']?.toString() ?? '#E5F1FC';
    List<Color>? gradientColors = parseGradientColors(coverColorRaw);

    final coverThemeRaw = json['cover_theme']?.toString() ?? 'classic';
    String coverStyle = coverThemeRaw;
    String? coverImageUrl = json['cover_image_url']?.toString();
    String? coverEmoji = json['cover_emoji']?.toString();
    String? coverText = json['cover_text']?.toString();

    // Check if cover_theme was serialized as JSON
    if (coverThemeRaw.trim().startsWith('{') && coverThemeRaw.trim().endsWith('}')) {
      try {
        final decoded = jsonDecode(coverThemeRaw);
        if (decoded is Map<String, dynamic>) {
          coverStyle = decoded['theme']?.toString() ?? 'classic';
          if (decoded.containsKey('coverImageUrl')) {
            final img = decoded['coverImageUrl']?.toString();
            coverImageUrl = (img != null && img.trim().isNotEmpty) ? img.trim() : null;
          } else {
            coverImageUrl ??= decoded['coverImageUrl']?.toString();
          }
          if (decoded.containsKey('coverEmoji')) {
            final em = decoded['coverEmoji']?.toString();
            coverEmoji = (em != null && em.trim().isNotEmpty) ? em.trim() : null;
          } else {
            coverEmoji ??= decoded['coverEmoji']?.toString();
          }
          if (decoded.containsKey('coverText')) {
            final txt = decoded['coverText']?.toString();
            coverText = (txt != null && txt.trim().isNotEmpty) ? txt.trim() : null;
          } else {
            coverText ??= decoded['coverText']?.toString();
          }
          if (gradientColors == null && decoded['gradient'] != null) {
            final g = decoded['gradient'];
            if (g is List && g.length >= 2) {
              gradientColors = [
                _parseHexColor(g[0].toString()),
                _parseHexColor(g[1].toString()),
              ];
            }
          }
        }
      } catch (_) {}
    }

    final parsedColor = gradientColors != null && gradientColors.isNotEmpty
        ? gradientColors.last
        : _parseHexColor(coverColorRaw);

    return DiaryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Diary',
      subtitle: coverText?.isNotEmpty == true ? coverText! : (json['description']?.toString() ?? 'classic'),
      coverStyle: coverStyle,
      color: parsedColor,
      gradientColors: gradientColors,
      accent: const Color(0xFF26374A),
      entriesCount: (json['entries_count'] as num?)?.toInt() ?? 0,
      lastEdited: json['updated_at']?.toString() ?? '',
      pattern: 'classic',
      isPrivate: false,
      description: json['description']?.toString() ?? '',
      coverImageUrl: coverImageUrl,
      coverEmoji: coverEmoji,
      coverText: coverText,
    );
  }

  Map<String, dynamic> toJson() {
    final themePayload = {
      'theme': coverStyle,
      'coverImageUrl': coverImageUrl ?? '',
      'coverEmoji': coverEmoji ?? '',
      'coverText': coverText ?? '',
      if (gradientColors != null && gradientColors!.length >= 2)
        'gradient': gradientColors!.map((c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}').toList(),
    };

    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_color': coverColorHex,
      'cover_theme': jsonEncode(themePayload),
      'entries_count': entriesCount,
    };
  }

  static String buildEncodedCoverTheme({
    String theme = 'classic',
    String? coverImageUrl,
    String? coverEmoji,
    String? coverText,
  }) {
    final themePayload = {
      'theme': theme,
      'coverImageUrl': coverImageUrl ?? '',
      'coverEmoji': coverEmoji ?? '',
      'coverText': coverText ?? '',
    };
    return jsonEncode(themePayload);
  }

  DiaryModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? coverStyle,
    Color? color,
    List<Color>? gradientColors,
    bool clearGradient = false,
    Color? accent,
    int? entriesCount,
    String? lastEdited,
    String? pattern,
    bool? isPrivate,
    String? description,
    String? coverImageUrl,
    bool clearCoverImage = false,
    String? coverEmoji,
    bool clearCoverEmoji = false,
    String? coverText,
    bool clearCoverText = false,
  }) {
    return DiaryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      coverStyle: coverStyle ?? this.coverStyle,
      color: color ?? this.color,
      gradientColors: clearGradient ? null : (gradientColors ?? this.gradientColors),
      accent: accent ?? this.accent,
      entriesCount: entriesCount ?? this.entriesCount,
      lastEdited: lastEdited ?? this.lastEdited,
      pattern: pattern ?? this.pattern,
      isPrivate: isPrivate ?? this.isPrivate,
      description: description ?? this.description,
      coverImageUrl: clearCoverImage ? null : (coverImageUrl ?? this.coverImageUrl),
      coverEmoji: clearCoverEmoji ? null : (coverEmoji ?? this.coverEmoji),
      coverText: clearCoverText ? null : (coverText ?? this.coverText),
    );
  }

  static Color parseHexColor(String hexString) {
    if (hexString.contains(',')) {
      final parts = hexString.split(',');
      if (parts.isNotEmpty) {
        return _parseHexColor(parts.last.trim());
      }
    }
    return _parseHexColor(hexString);
  }

  static List<Color>? parseGradientColors(String hexString) {
    if (hexString.contains(',')) {
      final parts = hexString.split(',');
      if (parts.length >= 2) {
        return [
          _parseHexColor(parts[0].trim()),
          _parseHexColor(parts[1].trim()),
        ];
      }
    }
    return null;
  }

  static Color _parseHexColor(String hexString) {
    try {
      final clean = hexString.trim().replaceFirst('#', '');
      final buffer = StringBuffer();
      if (clean.length == 6) buffer.write('ff');
      buffer.write(clean);
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFFE5F1FC);
    }
  }
}
