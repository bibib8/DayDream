import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_repository.dart';
import '../core/services/supabase_service.dart';
import '../data/models/diary_model.dart';
import '../data/models/entry_model.dart';
import '../data/models/mood_model.dart';
import '../data/sample_data.dart';

class DiaryProvider extends ChangeNotifier {
  int _currentNavIndex = 0; // Default to Welcome Screen (index 0)
  int _lastNavIndexBeforeEditor = 2; // Default return to Bookshelf (2) or Diary Entries (5)
  bool _isAuthenticated = false;
  bool _isSignUpMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isLoadingUserData = false;
  bool _isDisposed = false;

  UserModel _user = initialUser;
  List<DiaryModel> _diaries = [];
  String _selectedDiaryId = '';

  List<EntryModel> _entries = [];
  EntryModel? _draftEntry;
  String _activeEntryId = '';

  List<MoodLogItem> _moodHistory = [];
  int _currentPromptIndex = 0;
  String? _currentPromptForEditor;

  DiaryProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    if (SupabaseService.client != null) {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        _handleAuthStateChange(data.event, data.session);
      });
    }

    if (SupabaseRepository.isAuthenticated && !_isAuthenticated) {
      _isAuthenticated = true;
      _currentNavIndex = 2;
      loadUserData();
    }
  }

  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
    if (event == AuthChangeEvent.signedOut) {
      _resetAuthState();
    } else if (event == AuthChangeEvent.initialSession || event == AuthChangeEvent.signedIn) {
      if (!_isAuthenticated && session != null) {
        _isAuthenticated = true;
        _isSignUpMode = false;
        _errorMessage = null;
        _infoMessage = null;
        _currentNavIndex = 2; // Jump to Bookshelf
        _diaries = [];
        _selectedDiaryId = '';
        _entries = [];
        _activeEntryId = '';
        _moodHistory = [];
        notifyListeners();
        loadUserData();
      }
    }
  }

  void _resetAuthState() {
    _isAuthenticated = false;
    _isSignUpMode = false;
    _errorMessage = null;
    _infoMessage = null;
    _currentPromptForEditor = null;
    _currentNavIndex = 0; // Back to Welcome screen
    _diaries = [];
    _selectedDiaryId = '';
    _entries = [];
    _draftEntry = null;
    _activeEntryId = '';
    _moodHistory = [];
    _user = initialUser;
    notifyListeners();
  }

  @visibleForTesting
  void handleAuthStateChange(AuthChangeEvent event, Session? session) => _handleAuthStateChange(event, session);

  @visibleForTesting
  void resetAuthState() => _resetAuthState();

  @visibleForTesting
  void addDiaryForTesting(DiaryModel diary) {
    _diaries.add(diary);
    notifyListeners();
  }

  @visibleForTesting
  void addEntryForTesting(EntryModel entry) {
    _entries.add(entry);
    notifyListeners();
  }

  DiaryModel _defaultStarterDiary() {
    return DiaryModel(
      id: 'd_default',
      title: 'My First Diary',
      subtitle: 'classic',
      coverStyle: 'classic',
      color: const Color(0xFFE5F1FC),
      accent: const Color(0xFF26374A),
      entriesCount: 0,
      lastEdited: 'Today',
      pattern: 'classic',
      isPrivate: true,
      description: 'A cozy space for thoughts, dreams, and quiet moments.',
    );
  }

  // Getters
  int get currentNavIndex => _currentNavIndex;
  int get lastNavIndexBeforeEditor => _lastNavIndexBeforeEditor;
  bool get isAuthenticated => _isAuthenticated;
  bool get isSignUpMode => _isSignUpMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  UserModel get user => _user;
  List<DiaryModel> get diaries => _diaries.isNotEmpty ? _diaries : [_defaultStarterDiary()];
  String get selectedDiaryId => _selectedDiaryId;
  List<EntryModel> get entries => _entries;
  String get activeEntryId => _activeEntryId;
  List<MoodLogItem> get moodHistory => _moodHistory;
  int get currentPromptIndex => _currentPromptIndex;
  String get currentPrompt => dailyPrompts[_currentPromptIndex];
  String? get currentPromptForEditor => _currentPromptForEditor;

  void clearPromptForEditor() {
    _currentPromptForEditor = null;
  }

  DiaryModel get activeDiary =>
      _diaries.firstWhere((d) => d.id == _selectedDiaryId, orElse: () {
        if (_diaries.isNotEmpty) return _diaries[0];
        return _defaultStarterDiary();
      });

  EntryModel get activeEntry {
    if (_draftEntry != null && _draftEntry!.id == _activeEntryId) {
      return _draftEntry!;
    }
    final match = _entries.where((e) => e.id == _activeEntryId).toList();
    if (match.isNotEmpty) return match.first;
    if (_entries.isNotEmpty) return _entries.first;
    if (_draftEntry != null) return _draftEntry!;
    final now = DateTime.now();
    return EntryModel(
      id: 'temp_entry',
      diaryId: _selectedDiaryId.isNotEmpty ? _selectedDiaryId : (diaries.isNotEmpty ? diaries[0].id : 'default'),
      title: 'A New Whispered Reverie',
      date: DateFormat('MMMM d, yyyy').format(now),
      time: DateFormat('h:mm a').format(now),
      moodKey: '',
      moodLabel: '',
      moodIcon: '',
      weather: '',
      soundtrack: '',
      paperStyle: 'paper-grid',
      fontFamily: 'serif',
      paperColor: '#FFFFFF',
      content: '',
      stickers: [],
      imageUrls: [],
    );
  }

  void clearError() {
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  void clearInfoMessage() {
    _infoMessage = null;
    notifyListeners();
  }

  void setNavIndex(int index) {
    if (index == 3) {
      goToEditor();
      return;
    }
    _currentNavIndex = index;
    notifyListeners();
  }

  void goToEditor({String? initialPrompt}) {
    if (initialPrompt != null && initialPrompt.isNotEmpty) {
      createNewEntry(
        diaryId: _selectedDiaryId,
        initialContent: "$initialPrompt\n\n",
        initialPrompt: initialPrompt,
      );
      return;
    }

    // Ensure active diary is set to last active diary
    final currentDiaries = diaries;
    if (currentDiaries.isNotEmpty) {
      if (_selectedDiaryId.isEmpty || !currentDiaries.any((d) => d.id == _selectedDiaryId)) {
        if (_entries.isNotEmpty && currentDiaries.any((d) => d.id == _entries[0].diaryId)) {
          _selectedDiaryId = _entries[0].diaryId;
        } else {
          _selectedDiaryId = currentDiaries[0].id;
        }
      }
    }

    // Check if this diary has entries
    final diaryEntries = _entries.where((e) => e.diaryId == _selectedDiaryId).toList();
    if (diaryEntries.isNotEmpty) {
      _draftEntry = null;
      _activeEntryId = diaryEntries[0].id;
      _currentPromptForEditor = null;
      _currentNavIndex = 3;
      notifyListeners();
    } else {
      // New user or empty diary: prepare a clean blank page for this diary immediately
      createNewEntry(diaryId: _selectedDiaryId);
    }
  }

  void startFromDailyPrompt() {
    final prompt = currentPrompt;
    goToEditor(initialPrompt: prompt);
  }

  void openAuth({required bool isSignUp}) {
    _isSignUpMode = isSignUp;
    _errorMessage = null;
    _infoMessage = null;
    _currentNavIndex = 1; // Index 1 is AuthScreen
    notifyListeners();
  }

  void cyclePrompt() {
    _currentPromptIndex = (_currentPromptIndex + 1) % dailyPrompts.length;
    notifyListeners();
  }

  // ─── AUTHENTICATION ACTIONS ───

  Future<bool> signUp({
    required String email,
    required String password,
    String penName = 'Sweet Dreamer',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      if (password.length < 8) {
        throw Exception("Password must be at least 8 characters long.");
      }

      final response = await SupabaseRepository.signUp(
        email: email,
        password: password,
        penName: penName,
      );

      if (response.session != null) {
        _isSignUpMode = false;
        if (!_isAuthenticated) {
          _isAuthenticated = true;
          _currentNavIndex = 2; // Jump to Bookshelf
          _diaries = [];
          _selectedDiaryId = '';
          _entries = [];
          _activeEntryId = '';
          _moodHistory = [];
          _user = UserModel(
            penName: penName,
            handle: '@${email.split('@').first}',
            avatar: '🩵',
            theme: 'Classic',
            streakDays: 1,
            totalPages: 0,
            moodsCount: 0,
            bio: 'Quiet reflections & dreamy moments 🩵',
          );

          await loadUserData();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.user != null) {
        _isAuthenticated = false;
        _isSignUpMode = false;
        _currentNavIndex = 1; // Stay on Auth screen
        _infoMessage = "Check your email to confirm your account, then sign in.";
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      if (password.length < 8) {
        throw Exception("Password must be at least 8 characters long.");
      }

      final response = await SupabaseRepository.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isSignUpMode = false;
        if (!_isAuthenticated) {
          _isAuthenticated = true;
          _currentNavIndex = 2; // Jump to Bookshelf
          _diaries = [];
          _selectedDiaryId = '';
          _entries = [];
          _activeEntryId = '';
          _moodHistory = [];
          await loadUserData();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await SupabaseRepository.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }

    _resetAuthState();
  }

  Future<void> updatePenName(String newPenName) async {
    final trimmed = newPenName.trim();
    if (trimmed.isEmpty) return;

    _user.penName = trimmed;
    _user.handle = "@${trimmed.toLowerCase().replaceAll(' ', '_')}";
    notifyListeners();

    try {
      await SupabaseRepository.updatePenName(trimmed);
    } catch (e) {
      debugPrint("Error updating pen name: $e");
    }
  }

  Future<void> updateAvatarUrl(String newAvatarUrl) async {
    final trimmed = newAvatarUrl.trim();
    if (trimmed.isEmpty) return;

    _user.avatar = trimmed;
    notifyListeners();

    try {
      await SupabaseRepository.updateAvatarUrl(trimmed);
    } catch (e) {
      debugPrint("Error updating avatar: $e");
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      await SupabaseRepository.deleteUserAccount();

      _resetAuthState();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting account: $e");
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  // ─── DATA LOADING (User-Scoped from Supabase) ───

  Future<void> loadUserData() async {
    if (!SupabaseRepository.isAuthenticated) return;
    if (_isLoadingUserData) return;
    _isLoadingUserData = true;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Profile
      final profile = await SupabaseRepository.fetchProfile();
      if (profile != null) {
        _user = profile;
      }

      // 2. Diaries
      final dbDiaries = await SupabaseRepository.fetchDiaries();
      if (dbDiaries.isNotEmpty) {
        _diaries = dbDiaries;
      } else {
        // If user has no diaries yet, create a default one
        final newDiary = await SupabaseRepository.createDiary(
          title: "My First Diary",
          description: "A cozy space for thoughts, dreams, and quiet moments.",
          coverColor: "#E5F1FC",
          coverTheme: "classic",
        );
        _diaries = [newDiary];
      }

      // 3. Entries
      final dbEntries = await SupabaseRepository.fetchEntries();
      _entries = dbEntries;
      if (_entries.isNotEmpty) {
        _activeEntryId = _entries[0].id;
      } else {
        _activeEntryId = '';
      }

      // Set Last Active Diary (the one with the latest entry, or first diary)
      if (_entries.isNotEmpty && _diaries.any((d) => d.id == _entries[0].diaryId)) {
        _selectedDiaryId = _entries[0].diaryId;
      } else if (_diaries.isNotEmpty) {
        _selectedDiaryId = _diaries[0].id;
      } else {
        _selectedDiaryId = '';
      }

      // 4. Mood Logs
      final dbMoods = await SupabaseRepository.fetchMoodLogs();
      _moodHistory = dbMoods;

      _user.totalPages = _entries.length;
      _user.moodsCount = _moodHistory.length;
      _user.diariesCount = _diaries.length;
    } catch (e) {
      debugPrint("Error loading user data from Supabase: $e");
    } finally {
      _isLoadingUserData = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── DIARIES CRUD ───

  void openDiary(String diaryId) {
    _selectedDiaryId = diaryId;
    _lastNavIndexBeforeEditor = 5;
    _currentNavIndex = 5; // Navigate to Diary Entries Overview Screen!
    notifyListeners();
  }

  Future<void> createNewDiary({
    required String title,
    required String description,
    required String coverColor,
    String coverTheme = 'classic',
    String? coverImageUrl,
    String? coverEmoji,
    String? coverText,
  }) async {
    final encodedTheme = DiaryModel.buildEncodedCoverTheme(
      theme: coverTheme,
      coverImageUrl: coverImageUrl,
      coverEmoji: coverEmoji,
      coverText: coverText,
    );
    try {
      final newDiary = await SupabaseRepository.createDiary(
        title: title,
        description: description,
        coverColor: coverColor,
        coverTheme: encodedTheme,
      );
      _diaries.insert(0, newDiary);
      _selectedDiaryId = newDiary.id;
      notifyListeners();
    } catch (e) {
      debugPrint("Error creating diary via Supabase, falling back locally: $e");
      final newLocal = DiaryModel(
        id: 'diary_${DateTime.now().millisecondsSinceEpoch}',
        title: title.trim().isEmpty ? 'Untitled Diary' : title.trim(),
        subtitle: coverText?.isNotEmpty == true ? coverText! : description,
        coverStyle: coverTheme,
        color: DiaryModel.parseHexColor(coverColor),
        gradientColors: DiaryModel.parseGradientColors(coverColor),
        accent: const Color(0xFF26374A),
        entriesCount: 0,
        lastEdited: 'Just now',
        pattern: 'classic',
        isPrivate: false,
        description: description,
        coverImageUrl: coverImageUrl,
        coverEmoji: coverEmoji,
        coverText: coverText,
      );
      _diaries.insert(0, newLocal);
      _selectedDiaryId = newLocal.id;
      notifyListeners();
    }
  }

  Future<void> updateDiary({
    required String diaryId,
    required String title,
    required String description,
    required String coverColor,
    String coverTheme = 'classic',
    String? coverImageUrl,
    String? coverEmoji,
    String? coverText,
  }) async {
    final encodedTheme = DiaryModel.buildEncodedCoverTheme(
      theme: coverTheme,
      coverImageUrl: coverImageUrl,
      coverEmoji: coverEmoji,
      coverText: coverText,
    );
    try {
      final updated = await SupabaseRepository.updateDiary(
        diaryId: diaryId,
        title: title,
        description: description,
        coverColor: coverColor,
        coverTheme: encodedTheme,
      );
      final idx = _diaries.indexWhere((d) => d.id == diaryId);
      if (idx != -1) {
        _diaries[idx] = updated;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating diary via Supabase, falling back locally: $e");
      final idx = _diaries.indexWhere((d) => d.id == diaryId);
      if (idx != -1) {
        _diaries[idx] = _diaries[idx].copyWith(
          title: title,
          description: description,
          color: DiaryModel.parseHexColor(coverColor),
          gradientColors: DiaryModel.parseGradientColors(coverColor),
          clearGradient: DiaryModel.parseGradientColors(coverColor) == null,
          coverImageUrl: coverImageUrl,
          clearCoverImage: coverImageUrl == null || coverImageUrl.isEmpty,
          coverEmoji: coverEmoji,
          clearCoverEmoji: coverEmoji == null || coverEmoji.isEmpty,
          coverText: coverText,
          clearCoverText: coverText == null || coverText.isEmpty,
        );
        notifyListeners();
      }
    }
  }

  Future<void> deleteDiary(String diaryId) async {
    try {
      await SupabaseRepository.deleteDiary(diaryId);
      _diaries.removeWhere((d) => d.id == diaryId);
      _entries.removeWhere((e) => e.diaryId == diaryId);
      if (_selectedDiaryId == diaryId && _diaries.isNotEmpty) {
        _selectedDiaryId = _diaries[0].id;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting diary: $e");
      rethrow;
    }
  }

  // ─── ENTRIES CRUD ───

  void openEntry(String entryId, {int? returnIndex}) {
    final matchIndex = _entries.indexWhere((e) => e.id == entryId);
    if (matchIndex == -1) return;
    final entry = _entries[matchIndex];
    _draftEntry = null;
    _selectedDiaryId = entry.diaryId;
    _activeEntryId = entry.id;
    _currentPromptForEditor = null;
    _lastNavIndexBeforeEditor = returnIndex ?? (_currentNavIndex == 5 ? 5 : 2);
    _currentNavIndex = 3; // Navigate to Editor
    notifyListeners();
  }

  void createNewEntry({
    String? diaryId,
    String? initialContent,
    String? initialPrompt,
    String? initialTitle,
    int? returnIndex,
  }) {
    final currentDiaries = diaries;
    final targetDiaryId = diaryId ?? (_selectedDiaryId.isNotEmpty ? _selectedDiaryId : (currentDiaries.isNotEmpty ? currentDiaries[0].id : 'default'));
    final now = DateTime.now();
    final newId = 'e_${now.millisecondsSinceEpoch}';
    final dateStr = DateFormat('MMMM d, yyyy').format(now);
    final timeStr = DateFormat('h:mm a').format(now);

    final contentText = initialContent ?? '';
    final titleText = initialTitle ?? (initialPrompt != null ? 'Reflections on Today' : 'A New Whispered Reverie');

    final newEntry = EntryModel(
      id: newId,
      diaryId: targetDiaryId,
      title: titleText,
      date: dateStr,
      time: timeStr,
      moodKey: '',
      moodLabel: '',
      moodIcon: '',
      weather: '',
      soundtrack: 'Modjo – Lady (Hear Me Tonight) 💿',
      paperStyle: 'paper-grid',
      fontFamily: 'serif',
      paperColor: '#FFFFFF',
      content: contentText,
      stickers: [
        StickerItem(id: 'st_1', type: 'sticker', emoji: '🩵', x: 280, y: 30),
      ],
      imageUrls: [],
    );

    // Keep as draft entry in memory rather than inserting into _entries immediately
    _draftEntry = newEntry;
    _activeEntryId = newId;
    _selectedDiaryId = targetDiaryId;
    _currentPromptForEditor = initialPrompt;
    _lastNavIndexBeforeEditor = returnIndex ?? (_currentNavIndex == 5 ? 5 : 2);
    _currentNavIndex = 3; // Go to Editor
    notifyListeners();
  }

  void goBackFromEditor() {
    _currentNavIndex = _lastNavIndexBeforeEditor;
    notifyListeners();
  }

  List<EntryModel> get activeDiaryEntries =>
      _entries.where((e) => e.diaryId == _selectedDiaryId).toList();

  int get activeEntryIndexInDiary {
    final list = activeDiaryEntries;
    return list.indexWhere((e) => e.id == _activeEntryId);
  }

  bool get hasOlderEntryInDiary {
    final idx = activeEntryIndexInDiary;
    final list = activeDiaryEntries;
    return idx != -1 && idx < list.length - 1;
  }

  bool get hasNewerEntryInDiary {
    final idx = activeEntryIndexInDiary;
    return idx > 0;
  }

  void goToOlderEntryInDiary() {
    final list = activeDiaryEntries;
    final idx = activeEntryIndexInDiary;
    if (idx != -1 && idx < list.length - 1) {
      openEntry(list[idx + 1].id, returnIndex: _lastNavIndexBeforeEditor);
    }
  }

  void goToNewerEntryInDiary() {
    final list = activeDiaryEntries;
    final idx = activeEntryIndexInDiary;
    if (idx > 0) {
      openEntry(list[idx - 1].id, returnIndex: _lastNavIndexBeforeEditor);
    }
  }

  Future<void> saveEntry(EntryModel updated) async {
    String actualDiaryId = updated.diaryId;
    if (actualDiaryId == 'd_default' || actualDiaryId == 'default') {
      if (_diaries.isNotEmpty && _diaries[0].id != 'd_default') {
        actualDiaryId = _diaries[0].id;
      } else {
        try {
          final created = await SupabaseRepository.createDiary(
            title: "My First Diary",
            description: "A cozy space for thoughts, dreams, and quiet moments.",
            coverColor: "#E5F1FC",
            coverTheme: "classic",
          );
          _diaries = [created];
          actualDiaryId = created.id;
        } catch (_) {}
      }
    }
    final now = DateTime.now();
    final actualDate = updated.date.isNotEmpty ? updated.date : DateFormat('MMMM d, yyyy').format(now);
    final actualTime = updated.time.isNotEmpty ? updated.time : DateFormat('h:mm a').format(now);

    final toSave = EntryModel(
      id: updated.id,
      diaryId: actualDiaryId,
      title: updated.title,
      date: actualDate,
      time: actualTime,
      moodKey: updated.moodKey,
      moodLabel: updated.moodLabel,
      moodIcon: updated.moodIcon,
      weather: updated.weather,
      soundtrack: updated.soundtrack,
      paperStyle: updated.paperStyle,
      fontFamily: updated.fontFamily,
      paperColor: updated.paperColor,
      content: updated.content,
      stickers: updated.stickers,
      imageUrls: updated.imageUrls,
      createdAt: updated.createdAt ?? now,
      updatedAt: now,
    );

    try {
      final saved = await SupabaseRepository.saveEntry(toSave);
      _draftEntry = null;
      _activeEntryId = saved.id;
      _selectedDiaryId = saved.diaryId;
      final idx = _entries.indexWhere((e) => e.id == saved.id || e.id == updated.id);
      if (idx != -1) {
        _entries[idx] = saved;
      } else {
        _entries.insert(0, saved);
      }
      _user.totalPages = _entries.length;

      try {
        final dbDiaries = await SupabaseRepository.fetchDiaries();
        if (dbDiaries.isNotEmpty) {
          _diaries = dbDiaries;
        }
      } catch (_) {}

      notifyListeners();
    } catch (e) {
      debugPrint("Error saving entry to Supabase: $e");
      // Fallback local update
      _draftEntry = null;
      _activeEntryId = toSave.id;
      final idx = _entries.indexWhere((e) => e.id == toSave.id || e.id == updated.id);
      if (idx != -1) {
        _entries[idx] = toSave;
      } else {
        _entries.insert(0, toSave);
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await SupabaseRepository.deleteEntry(entryId);
      _entries.removeWhere((e) => e.id == entryId);
      _user.totalPages = _entries.length;
      if (_activeEntryId == entryId && _entries.isNotEmpty) {
        _activeEntryId = _entries[0].id;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting entry: $e");
      rethrow;
    }
  }

  // ─── MOOD TRACKER ───

  Future<void> logMood(String moodKey, [String note = '', dynamic target]) async {
    DateTime date;
    if (target is DateTime) {
      date = target;
    } else if (target is int) {
      final now = DateTime.now();
      date = DateTime(now.year, now.month, target);
    } else {
      date = DateTime.now();
    }

    final dayToLog = date.day;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final savedMood = await SupabaseRepository.saveMoodLog(
        day: dayToLog,
        date: dateStr,
        moodKey: moodKey,
        note: note.isNotEmpty ? note : 'Felt ${MoodTypes.get(moodKey).label}',
      );

      _moodHistory.removeWhere((m) =>
          m.date == dateStr ||
          (m.date.isEmpty &&
              m.day == dayToLog &&
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month));
      _moodHistory.add(savedMood);
      _moodHistory.sort((a, b) => (a.date.isNotEmpty && b.date.isNotEmpty)
          ? a.date.compareTo(b.date)
          : a.day.compareTo(b.day));
      _user.moodsCount = _moodHistory.length;
      notifyListeners();
    } catch (e) {
      debugPrint("Error logging mood to Supabase: $e");
      // Fallback in-memory
      final item = MoodLogItem(
        day: dayToLog,
        date: dateStr,
        moodKey: moodKey,
        note: note.isNotEmpty ? note : 'Felt ${MoodTypes.get(moodKey).label}',
      );
      _moodHistory.removeWhere((m) =>
          m.date == dateStr ||
          (m.date.isEmpty &&
              m.day == dayToLog &&
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month));
      _moodHistory.add(item);
      _moodHistory.sort((a, b) => (a.date.isNotEmpty && b.date.isNotEmpty)
          ? a.date.compareTo(b.date)
          : a.day.compareTo(b.day));
      _user.moodsCount = _moodHistory.length;
      notifyListeners();
    }
  }

  // ─── MEDIA UPLOAD ───

  Future<String> uploadImage(Uint8List bytes, String fileName) async {
    return await SupabaseRepository.uploadImage(bytes: bytes, fileName: fileName);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }
}
