import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/core/constants/env_keys.dart';

abstract final class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final url = dotenv.env[EnvKeys.supabaseUrl];
    final anonKey = dotenv.env[EnvKeys.supabaseAnonKey];

    if (url == null ||
        url.isEmpty ||
        anonKey == null ||
        anonKey.isEmpty ||
        url.contains('tu-proyecto')) {
      throw StateError(
        'Configura SUPABASE_URL y SUPABASE_ANON_KEY en el archivo .env',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
