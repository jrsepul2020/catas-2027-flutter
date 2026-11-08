import 'package:flutter/widgets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Mantén la pantalla encendida en dashboard / espera / ficha (primer plano).
abstract final class AppWakelock {
  static bool _wanted = false;
  static bool _lifecycleHooked = false;

  static Future<void> enableForSession() async {
    _wanted = true;
    _ensureLifecycle();
    try {
      await WakelockPlus.enable();
    } catch (_) {
      // Best-effort (web/desktop pueden no soportarlo).
    }
  }

  static Future<void> disable() async {
    _wanted = false;
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }

  static void _ensureLifecycle() {
    if (_lifecycleHooked) return;
    _lifecycleHooked = true;
    WidgetsBinding.instance.addObserver(_AppWakelockObserver());
  }
}

class _AppWakelockObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && AppWakelock._wanted) {
      WakelockPlus.enable().catchError((_) {});
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      WakelockPlus.disable().catchError((_) {});
    }
  }
}
