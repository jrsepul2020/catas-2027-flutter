import 'package:flutter/foundation.dart';
import 'package:virtus2027/config/supabase_config.dart';

/// Avisa a las pantallas abiertas cuando Realtime vuelve tras una caída.
///
/// Sin polls: solo el hook onOpen del cliente Supabase. Cada listener
/// debe recargar sus datos **una vez** por reconexión.
abstract final class RealtimeReconnectBus {
  static final ObserverList<VoidCallback> _listeners =
      ObserverList<VoidCallback>();
  static bool _hooked = false;
  static bool _huboCierre = false;

  static void ensureHooks() {
    if (_hooked) return;
    _hooked = true;
    try {
      final rt = SupabaseConfig.client.realtime;
      rt.onClose((_) {
        _huboCierre = true;
      });
      rt.onOpen(() {
        if (!_huboCierre) return;
        _huboCierre = false;
        for (final listener in List<VoidCallback>.of(_listeners)) {
          try {
            listener();
          } catch (_) {
            // Best-effort por pantalla.
          }
        }
      });
    } catch (_) {
      // Best-effort.
    }
  }

  static void addListener(VoidCallback listener) {
    ensureHooks();
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
}
