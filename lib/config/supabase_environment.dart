import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtus2027/config/app_mode.dart';

/// Entorno de Supabase (cloud vs local).
enum SupabaseEntorno {
  local,
  cloud,
}

/// Preferencia de entorno y entorno efectivo.
///
/// Con [esModoPruebas] apagado siempre se fuerza [SupabaseEntorno.local].
/// Por defecto (sin preferencia guardada): Local.
abstract final class SupabaseEnvironment {
  static const _prefsKey = 'supabase_entorno';

  /// Entorno con el que está conectada la app ahora mismo.
  static final ValueNotifier<SupabaseEntorno> active =
      ValueNotifier(SupabaseEntorno.local);

  static bool get isCloud => active.value == SupabaseEntorno.cloud;

  /// Preferencia guardada (ignorada si no hay modo pruebas).
  static Future<SupabaseEntorno> savedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == SupabaseEntorno.cloud.name) return SupabaseEntorno.cloud;
    return SupabaseEntorno.local;
  }

  /// Entorno efectivo al conectar.
  static Future<SupabaseEntorno> resolve() async {
    if (!esModoPruebas) return SupabaseEntorno.local;
    return savedPreference();
  }

  static Future<void> savePreference(SupabaseEntorno entorno) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, entorno.name);
  }
}
