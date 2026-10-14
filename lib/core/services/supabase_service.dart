import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Supabase project credentials
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hxobywsfyqmyaltvmypk.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_RqJLzdauSkcXKt4hlfPPFg_ghdm3bmX',
  );

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static SupabaseClient? get client {
    if (_isInitialized) {
      return Supabase.instance.client;
    }
    return null;
  }

  /// Initialize Supabase client if valid credentials are provided
  static Future<void> initialize() async {
    if (supabaseUrl.contains('xxxxxxxx') || supabaseAnonKey.contains('...')) {
      debugPrint('ℹ️ [Daydream Flutter] Running in local demo mode (Supabase credentials placeholder).');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('🩵 [Daydream Flutter] Supabase initialized successfully!');
    } catch (e) {
      debugPrint('⚠️ [Daydream Flutter] Supabase initialization failed: $e');
    }
  }
}
