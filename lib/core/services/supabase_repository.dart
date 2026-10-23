import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/diary_model.dart';
import '../../data/models/entry_model.dart';
import '../../data/models/mood_model.dart';
import '../../data/sample_data.dart';
import 'supabase_service.dart';

class SupabaseRepository {
  static SupabaseClient? get _client => SupabaseService.client;

  static User? get currentUser => _client?.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // ─── AUTHENTICATION ───

  /// Sign up with email and password (must be >= 8 chars)
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String penName = 'Sweet Dreamer',
  }) async {
    final client = _client;
    if (client == null) throw Exception("Supabase is not initialized");

    if (password.length < 8) {
      throw Exception("Password must be at least 8 characters long");
    }

    final response = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'pen_name': penName.trim()},
    );

    return response;
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) throw Exception("Supabase is not initialized");

    if (password.length < 8) {
      throw Exception("Password must be at least 8 characters long");
    }

    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    return response;
  }

  /// Sign out
  static Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      await client.auth.signOut();
    }
  }

  /// Update user's pen name in profile and auth metadata
  static Future<void> updatePenName(String newPenName) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return;

    final trimmed = newPenName.trim();
    if (trimmed.isEmpty) return;

    try {
      await client.from('profiles').upsert({
        'id': user.id,
        'pen_name': trimmed,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      await client.auth.updateUser(
        UserAttributes(data: {'pen_name': trimmed}),
      );
    } catch (e) {
      debugPrint("Error updating pen name in Supabase: $e");
    }
  }

  /// Update user's avatar image URL or emoji
  static Future<void> updateAvatarUrl(String avatarUrl) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return;

    final trimmed = avatarUrl.trim();
    if (trimmed.isEmpty) return;

    try {
      await client.from('profiles').upsert({
        'id': user.id,
        'avatar_url': trimmed,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      await client.auth.updateUser(
        UserAttributes(data: {'avatar_url': trimmed}),
      );
    } catch (e) {
      debugPrint("Error updating avatar in Supabase: $e");
    }
  }

  /// Delete user account and all associated cloud data (storage photos, tables, auth user)
  static Future<void> deleteUserAccount() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) {
      throw Exception("User not authenticated");
    }

    // 1. Delete all user files in diary-media bucket under '<user.id>/'
    final allPaths = <String>[];
    int offset = 0;
    const int limit = 100;

    while (true) {
      final files = await client.storage.from('diary-media').list(
        path: user.id,
        searchOptions: SearchOptions(
          limit: limit,
          offset: offset,
        ),
      );

      if (files.isEmpty) break;

      for (final file in files) {
        if (file.name.isNotEmpty) {
          allPaths.add('${user.id}/${file.name}');
        }
      }

      if (files.length < limit) break;
      offset += files.length;
    }

    if (allPaths.isNotEmpty) {
      const int batchSize = 100;
      for (var i = 0; i < allPaths.length; i += batchSize) {
        final end = (i + batchSize < allPaths.length) ? i + batchSize : allPaths.length;
        final batch = allPaths.sublist(i, end);
        await client.storage.from('diary-media').remove(batch);
      }
    }

    // 2. Delete user account and cascade all associated data
    await client.rpc('delete_user');

    // 3. Sign out
    await client.auth.signOut();
  }

  // ─── PROFILE ───

  static Future<UserModel?> fetchProfile() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return null;

    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // Fallback to auth metadata
        final penName = user.userMetadata?['pen_name'] ?? splitEmail(user.email ?? 'Sweet Dreamer');
        return UserModel(
          penName: penName,
          handle: "@${penName.toString().toLowerCase().replaceAll(' ', '_')}",
          avatar: "🩵",
          theme: "Icy Denim & Silver",
          streakDays: 1,
          totalPages: 0,
          moodsCount: 0,
          diariesCount: 1,
          bio: "Collecting soft skies, polaroid memories & daily reveries 💿🩵",
        );
      }

      final penName = data['pen_name']?.toString() ?? 'Sweet Dreamer';
      return UserModel(
        penName: penName,
        handle: "@${penName.toLowerCase().replaceAll(' ', '_')}",
        avatar: data['avatar_url']?.toString().isNotEmpty == true ? data['avatar_url'].toString() : "🩵",
        theme: "Icy Denim & Silver",
        streakDays: (data['streak_days'] as num?)?.toInt() ?? 1,
        totalPages: (data['pages_count'] as num?)?.toInt() ?? 0,
        moodsCount: (data['moods_count'] as num?)?.toInt() ?? 0,
        diariesCount: (data['diaries_count'] as num?)?.toInt() ?? 1,
        bio: "Collecting soft skies, polaroid memories & daily reveries 💿🩵",
      );
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      return null;
    }
  }

  // ─── DIARIES ───

  static Future<List<DiaryModel>> fetchDiaries() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return [];

    try {
      final List<dynamic> data = await client
          .from('diaries')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return data.map((d) => DiaryModel.fromJson(d as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("Error fetching diaries: $e");
      return [];
    }
  }

  static Future<DiaryModel> createDiary({
    required String title,
    required String description,
    required String coverColor,
    required String coverTheme,
  }) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) throw Exception("User not authenticated");

    final data = await client
        .from('diaries')
        .insert({
          'user_id': user.id,
          'title': title.trim().isEmpty ? 'Untitled Diary' : title.trim(),
          'description': description.trim(),
          'cover_color': coverColor,
          'cover_theme': coverTheme,
          'entries_count': 0,
          'is_default': false,
        })
        .select()
        .single();

    return DiaryModel.fromJson(data);
  }

  static Future<DiaryModel> updateDiary({
    required String diaryId,
    required String title,
    required String description,
    required String coverColor,
    required String coverTheme,
  }) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) throw Exception("User not authenticated");

    final data = await client
        .from('diaries')
        .update({
          'title': title.trim(),
          'description': description.trim(),
          'cover_color': coverColor,
          'cover_theme': coverTheme,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', diaryId)
        .eq('user_id', user.id)
        .select()
        .single();

    return DiaryModel.fromJson(data);
  }

  static Future<void> deleteDiary(String diaryId) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) throw Exception("User not authenticated");

    await client
        .from('diaries')
        .delete()
        .eq('id', diaryId)
        .eq('user_id', user.id);
  }

  // ─── ENTRIES ───

  static Future<List<EntryModel>> fetchEntries({String? diaryId}) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return [];

    try {
      var query = client
          .from('entries')
          .select()
          .eq('user_id', user.id);

      if (diaryId != null) {
        query = query.eq('diary_id', diaryId);
      }

      final List<dynamic> data = await query.order('created_at', ascending: false);
      return data.map((e) => EntryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("Error fetching entries: $e");
      return [];
    }
  }

  static bool isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str);
  }

  static Future<EntryModel> saveEntry(EntryModel entry) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) throw Exception("User not authenticated");

    // 1. Ensure diary_id is a valid UUID in Supabase
    String targetDiaryId = entry.diaryId;
    if (!isValidUuid(targetDiaryId)) {
      final userDiaries = await fetchDiaries();
      if (userDiaries.isNotEmpty) {
        targetDiaryId = userDiaries.first.id;
      } else {
        final starter = await createDiary(
          title: "My First Diary",
          description: "A cozy space for thoughts, dreams, and quiet moments.",
          coverColor: "#E5F1FC",
          coverTheme: "classic",
        );
        targetDiaryId = starter.id;
      }
    }

    final payload = <String, dynamic>{
      'diary_id': targetDiaryId,
      'user_id': user.id,
      'title': entry.title,
      'content': entry.content,
      'entry_date': entry.date,
      'entry_time': entry.time,
      'weather': entry.weather,
      'soundtrack': entry.soundtrack,
      'paper_style': entry.paperStyle,
      'font_family': entry.fontFamily,
      'mood_key': entry.moodKey,
      'mood_label': entry.moodLabel,
      'mood_icon': entry.moodIcon,
      'stickers': entry.stickers.map((s) => s.toJson()).toList(),
      'image_urls': entry.imageUrls,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final Map<String, dynamic> data;
    if (isValidUuid(entry.id)) {
      payload['id'] = entry.id;
      data = await client
          .from('entries')
          .upsert(payload)
          .select()
          .single();
    } else {
      // For new entries with local non-UUID ids (e.g. e_17919...), insert without id so Supabase generates a real UUID
      data = await client
          .from('entries')
          .insert(payload)
          .select()
          .single();
    }

    return EntryModel.fromJson(data);
  }

  static Future<void> deleteEntry(String entryId) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) throw Exception("User not authenticated");

    if (!isValidUuid(entryId)) return;

    await client
        .from('entries')
        .delete()
        .eq('id', entryId)
        .eq('user_id', user.id);
  }

  // ─── MOOD LOGS ───

  static Future<List<MoodLogItem>> fetchMoodLogs() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return [];

    try {
      final List<dynamic> data = await client
          .from('mood_logs')
          .select()
          .eq('user_id', user.id)
          .order('day', ascending: true);

      return data.map((m) => MoodLogItem.fromJson(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("Error fetching mood logs: $e");
      return [];
    }
  }

  static Future<MoodLogItem> saveMoodLog({
    required int day,
    required String date,
    required String moodKey,
    String note = '',
  }) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) throw Exception("User not authenticated");

    final payload = {
      'user_id': user.id,
      'day': day,
      'log_date': date,
      'mood_key': moodKey,
      'note': note,
    };

    final data = await client
        .from('mood_logs')
        .upsert(payload, onConflict: 'user_id,log_date')
        .select()
        .single();

    return MoodLogItem.fromJson(data);
  }

  // ─── STORAGE: IMAGE UPLOAD (<= 2MB, JPG/PNG/WebP) ───

  static Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) throw Exception("User not authenticated");

    // 2 MB limit = 2097152 bytes
    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      throw Exception("Image file size exceeds the 2 MB limit.");
    }

    // Determine extension & MIME
    final lowerName = fileName.toLowerCase();
    String contentType = 'image/jpeg';
    if (lowerName.endsWith('.png')) {
      contentType = 'image/png';
    } else if (lowerName.endsWith('.webp')) {
      contentType = 'image/webp';
    }

    final sanitizedExt = lowerName.split('.').last;
    final filePath = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}.$sanitizedExt';

    await client.storage.from('diary-media').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );

    final publicUrl = client.storage.from('diary-media').getPublicUrl(filePath);
    return publicUrl;
  }

  static String splitEmail(String email) {
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return email;
  }
}
