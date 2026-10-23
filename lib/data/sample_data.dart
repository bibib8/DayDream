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

final List<String> dailyPrompts = [
  "What is a small memory that feels like starlight to you today?",
  "Describe the exact color of the sky outside your window right now.",
  "What song from your childhood feels like a warm hug?",
  "List three quiet things you noticed today that made you pause.",
  "If today was a chapter in a vintage novel, what would the title be?",
];

