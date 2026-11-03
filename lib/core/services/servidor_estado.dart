import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:virtus2027/config/supabase_config.dart';

/// Pulso ligero al servidor Supabase (local o nube).
///
/// El chip «Local / Nube» antes solo indicaba *a dónde apunta* la config, no
/// si el Geekom/red respondía. Este servicio hace un `select` mínimo y expone
/// [alcanzable] para la UI.
class ServidorEstado extends ChangeNotifier {
  ServidorEstado._();

  static final ServidorEstado instance = ServidorEstado._();

  static const Duration intervalo = Duration(seconds: 4);
  static const Duration timeout = Duration(seconds: 3);

  bool _alcanzable = true;
  bool _comprobado = false;
  Timer? _timer;
  bool _enCurso = false;

  /// Último resultado conocido (optimistic `true` hasta el primer fallo).
  bool get alcanzable => _alcanzable;

  /// `true` tras al menos un intento de ping.
  bool get comprobado => _comprobado;

  void start({Duration interval = intervalo}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(ping()));
    unawaited(ping());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> ping() async {
    if (_enCurso) return;
    _enCurso = true;
    try {
      await SupabaseConfig.client
          .from('tandas')
          .select('id')
          .limit(1)
          .timeout(timeout);
      _aplicar(true);
    } catch (_) {
      _aplicar(false);
    } finally {
      _enCurso = false;
    }
  }

  void _aplicar(bool ok) {
    final cambio = !_comprobado || _alcanzable != ok;
    _comprobado = true;
    _alcanzable = ok;
    if (cambio) notifyListeners();
  }
}
