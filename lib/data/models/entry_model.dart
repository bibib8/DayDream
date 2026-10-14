import 'package:intl/intl.dart';

class StickerItem {
  final String id;
  final String type; // 'sticker', 'washi', 'polaroid'
  final String emoji;
  final String? variant;
  final String? caption;
  final String? imageUrl;
  double x;
  double y;
  double rotate;

  StickerItem({
    required this.id,
    required this.type,
    this.emoji = '',
    this.variant,
    this.caption,
    this.imageUrl,
    required this.x,
    required this.y,
    this.rotate = 0.0,
  });

  factory StickerItem.fromJson(Map<String, dynamic> json) {
    return StickerItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'sticker',
      emoji: json['emoji']?.toString() ?? '',
      variant: json['variant']?.toString(),
      caption: json['caption']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
      x: (json['x'] as num?)?.toDouble() ?? 50.0,
      y: (json['y'] as num?)?.toDouble() ?? 50.0,
      rotate: (json['rotate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'emoji': emoji,
      'variant': variant,
      'caption': caption,
      'image_url': imageUrl,
      'x': x,
      'y': y,
      'rotate': rotate,
    };
  }
}

class EntryModel {
  final String id;
  final String diaryId;
  String title;
  final String date;
  final String time;
  String moodKey;
  String moodLabel;
  String moodIcon;
  String weather;
  String soundtrack;
  String paperStyle; // 'paper-plain', 'paper-grid', 'paper-lined', 'paper-dotted'
  String fontFamily; // 'serif', 'editorial', 'handwriting', 'sans'
  String paperColor; // e.g. '#FFFFFF', '#FFFDF2', '#EFF6FC', '#FDF2F8'
  String content;
  List<StickerItem> stickers;
  List<String> imageUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EntryModel({
    required this.id,
    required this.diaryId,
    required this.title,
    required this.date,
    required this.time,
    required this.moodKey,
    required this.moodLabel,
    required this.moodIcon,
    this.weather = '',
    this.soundtrack = 'Modjo – Lady 💿',
    this.paperStyle = 'paper-plain',
    this.fontFamily = 'serif',
    this.paperColor = '#FFFFFF',
    required this.content,
    List<StickerItem>? stickers,
    List<String>? imageUrls,
    this.createdAt,
    this.updatedAt,
  })  : stickers = stickers ?? [],
        imageUrls = imageUrls ?? [];

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    List<StickerItem> parsedStickers = [];
    if (json['stickers'] is List) {
      parsedStickers = (json['stickers'] as List)
          .map((s) => StickerItem.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    List<String> parsedImages = [];
    if (json['image_urls'] is List) {
      parsedImages = (json['image_urls'] as List).map((i) => i.toString()).toList();
    }

    DateTime? createdAt;
    if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at'].toString()).toLocal();
      } catch (_) {}
    }

    DateTime? updatedAt;
    if (json['updated_at'] != null) {
      try {
        updatedAt = DateTime.parse(json['updated_at'].toString()).toLocal();
      } catch (_) {}
    }

    String entryDate = json['entry_date']?.toString() ?? json['date']?.toString() ?? '';
    String entryTime = json['entry_time']?.toString() ?? json['time']?.toString() ?? '';

    // If authoritative server timestamp created_at exists, format real local date and time
    if (createdAt != null) {
      entryDate = DateFormat('MMMM d, yyyy').format(createdAt);
      entryTime = DateFormat('h:mm a').format(createdAt);
    }

    final now = DateTime.now();

    return EntryModel(
      id: json['id']?.toString() ?? '',
      diaryId: json['diary_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Reverie',
      date: entryDate.isNotEmpty ? entryDate : DateFormat('MMMM d, yyyy').format(now),
      time: entryTime.isNotEmpty ? entryTime : DateFormat('h:mm a').format(now),
      moodKey: json['mood_key']?.toString() ?? 'happy',
      moodLabel: json['mood_label']?.toString() ?? 'Happy',
      moodIcon: json['mood_icon']?.toString() ?? '😊',
      weather: json['weather']?.toString() ?? '',
      soundtrack: json['soundtrack']?.toString() ?? 'Modjo – Lady 💿',
      paperStyle: json['paper_style']?.toString() ?? 'paper-plain',
      fontFamily: json['font_family']?.toString() ?? 'serif',
      paperColor: json['paper_color']?.toString() ?? '#FFFFFF',
      content: json['content']?.toString() ?? '',
      stickers: parsedStickers,
      imageUrls: parsedImages,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diary_id': diaryId,
      'title': title,
      'entry_date': date,
      'entry_time': time,
      'weather': weather,
      'soundtrack': soundtrack,
      'paper_style': paperStyle,
      'font_family': fontFamily,
      'mood_key': moodKey,
      'mood_label': moodLabel,
      'mood_icon': moodIcon,
      'content': content,
      'stickers': stickers.map((s) => s.toJson()).toList(),
      'image_urls': imageUrls,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }
}
