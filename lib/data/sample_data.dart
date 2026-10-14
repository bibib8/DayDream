import 'package:flutter/material.dart';
import 'models/diary_model.dart';
import 'models/entry_model.dart';
import 'models/mood_model.dart';

class UserModel {
  String penName;
  String handle;
  String avatar;
  String theme;
  int streakDays;
  int totalPages;
  int moodsCount;
  int diariesCount;
  String bio;

  UserModel({
    required this.penName,
    required this.handle,
    required this.avatar,
    required this.theme,
    required this.streakDays,
    required this.totalPages,
    required this.moodsCount,
    this.diariesCount = 1,
    required this.bio,
  });
}

final UserModel initialUser = UserModel(
  penName: "Sweet Dreamer",
  handle: "@dreamer",
  avatar: "🩵",
  theme: "Classic",
  streakDays: 1,
  totalPages: 0,
  moodsCount: 0,
  bio: "Quiet reflections & dreamy moments 🩵",
);

final List<DiaryModel> sampleDiaries = [
  DiaryModel(
    id: "d1",
    title: "My First Diary",
    subtitle: "A cozy space for thoughts, dreams, and quiet moments.",
    coverStyle: "powder-sky",
    color: const Color(0xFFBAE6FD),
    gradientColors: const [Color(0xFFF0F9FF), Color(0xFFBAE6FD)],
    accent: const Color(0xFF477FAF),
    entriesCount: 0,
    lastEdited: "Today",
    pattern: "clouds",
    isPrivate: false,
    description: "A cozy space for thoughts, dreams, and quiet moments.",
    coverEmoji: "🩵",
    coverText: "My First Diary",
  ),
  DiaryModel(
    id: "d2",
    title: "Parisian Film Diaries '03",
    subtitle: "Travel Scrapbook & Vintage Reels",
    coverStyle: "blush-rose",
    color: const Color(0xFFFBCFE8),
    gradientColors: const [Color(0xFFFFF0F7), Color(0xFFFBCFE8)],
    accent: const Color(0xFFF8FCFF),
    entriesCount: 7,
    lastEdited: "Yesterday",
    pattern: "stars",
    isPrivate: false,
    description: "Blue ink poetry along the Seine, flea market camera reels, and silver charm reflections.",
    coverEmoji: "📷",
    coverText: "Paris '03",
  ),
  DiaryModel(
    id: "d3",
    title: "Midnight Starlight Archive",
    subtitle: "Bedtime CD Soundtracks & Poetry",
    coverStyle: "periwinkle-dream",
    color: const Color(0xFFC7D2FE),
    gradientColors: const [Color(0xFFF1F4FF), Color(0xFFC7D2FE)],
    accent: const Color(0xFFA9D0F5),
    entriesCount: 19,
    lastEdited: "Oct 10, 2026",
    pattern: "moon",
    isPrivate: false,
    description: "Late-night bedroom journals, CD player soundtracks, and starlit confessions.",
    coverEmoji: "🌙",
    coverText: "Midnight",
  ),
];

final List<EntryModel> sampleEntries = [
  EntryModel(
    id: "e1",
    diaryId: "d1",
    title: "Morning Light, Blue Hydrangeas & French House",
    date: "October 12, 2026",
    time: "4:15 PM",
    moodKey: "happy",
    moodLabel: "Happy",
    moodIcon: "😊",
    weather: "",
    soundtrack: "Modjo – Lady (Hear Me Tonight) 💿",
    paperStyle: "paper-grid",
    content: "The autumn breeze came through the window this morning carrying that crisp, early-2000s CD-release clarity. I clipped three blue hydrangeas into an old glass jar on my desk.\n\nWriting on blue graph paper while drinking iced vanilla milk. Everything feels intentional today: the oversized denim jacket on my chair, the silver star clip in my hair, the quiet hum of the afternoon.",
  ),
  EntryModel(
    id: "e2",
    diaryId: "d2",
    title: "Vintage Digicam Stills by the River",
    date: "October 10, 2026",
    time: "2:30 PM",
    moodKey: "calm",
    moodLabel: "Calm",
    moodIcon: "😌",
    weather: "Overcast Mist ☁️",
    soundtrack: "Dido – White Flag 🎧",
    paperStyle: "paper-dotted",
    content: "Brought my little 4-megapixel Sony Cyber-shot to the river today. There's a particular charm to low-res digital grain that feels more like real memory than high definition ever could.\n\nSat on the green bench with a warm café au lait, taping metro tickets into my margins.",
  ),
];

final List<MoodLogItem> sampleMoodHistory = [
  MoodLogItem(day: 1, date: "2026-10-01", moodKey: "calm", note: "Quiet morning with iced blueberry tea."),
  MoodLogItem(day: 2, date: "2026-10-02", moodKey: "tired", note: "Sleepy afternoon dreaming of soft clouds."),
  MoodLogItem(day: 3, date: "2026-10-03", moodKey: "productive", note: "Cleared out my inbox and finished scrapbook covers."),
  MoodLogItem(day: 4, date: "2026-10-04", moodKey: "happy", note: "Daydreaming over vintage magazine layouts."),
  MoodLogItem(day: 5, date: "2026-10-05", moodKey: "calm", note: "Peaceful moments listening to ambient melodies."),
  MoodLogItem(day: 6, date: "2026-10-06", moodKey: "down", note: "Misty afternoon listening to trip hop, felt quiet."),
  MoodLogItem(day: 7, date: "2026-10-07", moodKey: "calm", note: "Found my old portable CD player and photo binder."),
  MoodLogItem(day: 8, date: "2026-10-08", moodKey: "happy", note: "Fresh hydrangeas on my desk, feeling joyful!"),
  MoodLogItem(day: 9, date: "2026-10-09", moodKey: "productive", note: "Designing new scrapbook covers with silver stars."),
  MoodLogItem(day: 10, date: "2026-10-10", moodKey: "happy", note: "Found a lovely vintage silver compact mirror."),
  MoodLogItem(day: 11, date: "2026-10-11", moodKey: "happy", note: "Parisian film stills and warm coffee."),
  MoodLogItem(day: 12, date: "2026-10-12", moodKey: "tired", note: "Long day of walking, fell asleep early wrapped in denim."),
];

final List<String> dailyPrompts = [
  "What is a small memory that feels like starlight to you today?",
  "Describe the exact color of the sky outside your window right now.",
  "What song from your childhood feels like a warm hug?",
  "List three quiet things you noticed today that made you pause.",
  "If today was a chapter in a vintage novel, what would the title be?",
];
