import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales de la tablet para el flujo de aprobación.
class AprobacionPrefs {
  AprobacionPrefs._();

  static String _keyOmitirAviso(String concursoId) =>
      'aprobacion_omitir_aviso_incompleto_$concursoId';

  /// Si el presidente marcó «No volver a avisar en este concurso».
  static Future<bool> omitirAvisoIncompleto(String concursoId) async {
    if (concursoId.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOmitirAviso(concursoId)) ?? false;
  }

  static Future<void> setOmitirAvisoIncompleto(
    String concursoId, {
    required bool value,
  }) async {
    if (concursoId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOmitirAviso(concursoId), value);
  }
}
