import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';

/// Escucha (Realtime + poll 2s) cuando la tanda tiene una muestra `activa`.
/// Pensado para catadores en espera; el poll se puede pausar dentro de la ficha.
class CatadorAutoCataSync {
  CatadorAutoCataSync({
    required this.tandaId,
    required this.onMuestraActiva,
    this.onSinMuestraActiva,
    SupabaseClient? client,
    this.pollInterval = const Duration(seconds: 2),
    this.debounce = const Duration(milliseconds: 350),
  }) : _client = client ?? SupabaseConfig.client;

  final String tandaId;
  final ValueChanged<String> onMuestraActiva;
  /// Cuando deja de haber muestra `activa` (p. ej. incidencia).
  final VoidCallback? onSinMuestraActiva;
  final Duration pollInterval;
  final Duration debounce;
  final SupabaseClient _client;

  RealtimeChannel? _channel;
  Timer? _pollTimer;
  Timer? _debounceTimer;
  bool _pollActivo = true;

  dynamic get _tandaDbId => int.tryParse(tandaId) ?? tandaId;

  void start() {
    _subscribeRealtime();
    _startPoll();
    // Chequeo inmediato al arrancar.
    unawaited(_consultarMuestraActiva());
  }

  /// Mientras el catador espera (dashboard / tras aprobación).
  void resumePoll() {
    _pollActivo = true;
    _startPoll();
    unawaited(_consultarMuestraActiva());
  }

  /// Dentro de la ficha de cata: no hace falta el poll de respaldo.
  void pausePoll() {
    _pollActivo = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _subscribeRealtime() {
    if (_channel != null) return;

    final channel = _client.channel('catador-auto-cata-$tandaId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'tanda_muestras',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'tanda_id',
        value: _tandaDbId,
      ),
      callback: (_) => _scheduleCheck(),
    );
    _channel = channel;
    channel.subscribe();
  }

  void _startPoll() {
    _pollTimer?.cancel();
    if (!_pollActivo) return;
    _pollTimer = Timer.periodic(pollInterval, (_) {
      if (_pollActivo) unawaited(_consultarMuestraActiva());
    });
  }

  void _scheduleCheck() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => unawaited(_consultarMuestraActiva()));
  }

  Future<void> _consultarMuestraActiva() async {
    try {
      final row = await _client
          .from('tanda_muestras')
          .select('muestra_id, estado')
          .eq('tanda_id', _tandaDbId)
          .eq('estado', 'activa')
          .order('orden', ascending: true)
          .limit(1)
          .maybeSingle();

      if (row == null) {
        onSinMuestraActiva?.call();
        return;
      }
      final id = row['muestra_id']?.toString();
      if (id == null || id.isEmpty) {
        onSinMuestraActiva?.call();
        return;
      }
      onMuestraActiva(id);
    } catch (_) {
      // El poll/Realtime es best-effort; no bloquear la UI.
    }
  }

  Future<void> dispose() async {
    _debounceTimer?.cancel();
    _pollTimer?.cancel();
    _debounceTimer = null;
    _pollTimer = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await _client.removeChannel(channel);
    }
  }
}
