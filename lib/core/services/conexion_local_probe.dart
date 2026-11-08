import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/config/supabase_environment.dart';

/// Comprueba al arranque que el Supabase LOCAL (Geekom) responde por REST.
///
/// Un solo intento; no añade poll. Si falla, lanza [StateError] con causa legible.
abstract final class ConexionLocalProbe {
  static const Duration timeout = Duration(seconds: 5);

  /// No-op si el entorno activo no es local.
  static Future<void> assertReachableIfLocal() async {
    if (SupabaseEnvironment.active.value != SupabaseEntorno.local) return;

    final url = SupabaseConfig.activeUrl ?? '(sin URL)';
    try {
      await SupabaseConfig.client
          .from('mesas')
          .select('id')
          .limit(1)
          .timeout(timeout);
    } on PostgrestException catch (e) {
      throw StateError(_mensajePostgrest(url, e));
    } catch (e) {
      throw StateError(_mensajeRed(url, e));
    }
  }

  static String _mensajePostgrest(String url, PostgrestException e) {
    final code = (e.code ?? '').toUpperCase();
    final msg = e.message;
    final lower = msg.toLowerCase();

    if (code == 'PGRST301' ||
        lower.contains('jwt') ||
        lower.contains('unauthorized') ||
        msg.contains('401')) {
      return 'Servidor LOCAL alcanzable en $url, pero rechaza la clave '
          '(HTTP/JWT: $msg).\n'
          'En el Geekom ejecuta `supabase status` y alinea '
          'SUPABASE_LOCAL_KEY del .env con la anon/publishable key.';
    }

    return 'Servidor LOCAL en $url respondió con error de API: $msg'
        '${code.isEmpty ? '' : ' [$code]'}.';
  }

  static String _mensajeRed(String url, Object e) {
    final raw = e.toString();
    final lower = raw.toLowerCase();
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'Sin respuesta del servidor LOCAL en $url '
          '(timeout ${timeout.inSeconds}s).\n'
          'Comprueba que el Geekom esté encendido, en la misma Wi‑Fi '
          'y que Supabase esté en marcha (`supabase start`).';
    }
    if (lower.contains('failed host lookup') ||
        lower.contains('name not resolved') ||
        lower.contains('nodename')) {
      return 'No se resuelve el host del servidor LOCAL ($url).\n'
          'Revisa SUPABASE_LOCAL_URL en .env (IP del Geekom).';
    }
    if (lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('network is unreachable') ||
        lower.contains('socketexception') ||
        lower.contains('clientexception') ||
        lower.contains('xmlhttprequest')) {
      return 'No hay conexión con el servidor LOCAL ($url).\n'
          'Detalle: $raw\n'
          'Geekom / `supabase start` / Wi‑Fi / firewall del puerto 54321.';
    }
    return 'No se pudo conectar al servidor LOCAL ($url).\nDetalle: $raw';
  }
}
