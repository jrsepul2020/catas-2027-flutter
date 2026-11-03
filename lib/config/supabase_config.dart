import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/app_restart.dart';
import 'package:virtus2027/config/supabase_environment.dart';
import 'package:virtus2027/core/constants/env_keys.dart';

abstract final class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  /// URL con la que se inicializó el cliente (solo se fija en [initialize]).
  static String? activeUrl;

  static bool get pointsToCloud {
    final cloud = dotenv.env[EnvKeys.supabaseUrl];
    return cloud != null &&
        cloud.isNotEmpty &&
        activeUrl != null &&
        activeUrl == cloud;
  }

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    final entorno = await SupabaseEnvironment.resolve();
    await _connect(entorno);
  }

  /// Guarda la preferencia y reinicia la app (no reconecta en caliente).
  static Future<void> saveEntornoAndRestart(SupabaseEntorno preferencia) async {
    await SupabaseEnvironment.savePreference(preferencia);
    restartAppCompletely();
  }

  static Future<void> _connect(SupabaseEntorno entorno) async {
    final (:url, :key) = _credentialsFor(entorno);

    await Supabase.initialize(
      url: url,
      publishableKey: key,
    );
    activeUrl = url;
    SupabaseEnvironment.active.value = entorno;
  }

  static ({String url, String key}) _credentialsFor(SupabaseEntorno entorno) {
    switch (entorno) {
      case SupabaseEntorno.cloud:
        final url = dotenv.env[EnvKeys.supabaseUrl];
        final key = dotenv.env[EnvKeys.supabaseAnonKey];
        if (url == null ||
            url.isEmpty ||
            key == null ||
            key.isEmpty ||
            url.contains('tu-proyecto')) {
          throw StateError(
            'Configura SUPABASE_URL y SUPABASE_ANON_KEY en el archivo .env',
          );
        }
        return (url: url, key: key);
      case SupabaseEntorno.local:
        final url = dotenv.env[EnvKeys.supabaseLocalUrl];
        final key = dotenv.env[EnvKeys.supabaseLocalKey];
        if (url == null || url.isEmpty) {
          throw StateError(
            'Falta SUPABASE_LOCAL_URL en el archivo .env',
          );
        }
        if (key == null || key.isEmpty) {
          throw StateError(
            'Falta SUPABASE_LOCAL_KEY en el archivo .env',
          );
        }
        return (url: url, key: key);
    }
  }
}
