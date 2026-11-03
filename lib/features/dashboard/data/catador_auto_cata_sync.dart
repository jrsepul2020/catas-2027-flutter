import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/features/diagnostico/diagnostico.dart';

/// Escucha (Realtime + poll) cuando la tanda tiene una muestra `activa`.
/// Pensado para catadores en espera; el poll se puede pausar dentro de la ficha.
class CatadorAutoCataSync {
  CatadorAutoCataSync({
    required this.tandaId,
    required this.onMuestraActiva,
    this.onSinMuestraActiva,
    SupabaseClient? client,
    this.pollInterval = const Duration(seconds: 1),
    this.debounce = const Duration(milliseconds: 250),
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
  String? _ultimaMuestraNotificada;

  dynamic get _tandaDbId => int.tryParse(tandaId) ?? tandaId;

  void start() {
    _subscribeRealtime();
    _startPoll();
    unawaited(_consultarMuestraActiva());
  }

  /// Mientras el catador espera (dashboard / tras aprobación).
  void resumePoll() {
    _pollActivo = true;
    // Permite reabrir la misma u otra muestra tras volver de la ficha.
    _ultimaMuestraNotificada = null;
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
      callback: (payload) {
        Diagnostico.ecoPostgres(payload);
        _scheduleCheck();
      },
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
      final row = await Diagnostico.pollSelect(
        'auto_cata',
        () => _client
            .from('tanda_muestras')
            .select('muestra_id, estado, orden')
            .eq('tanda_id', _tandaDbId)
            .eq('estado', 'activa')
            .order('orden', ascending: true)
            .limit(1)
            .maybeSingle(),
      );

      if (row == null) {
        _ultimaMuestraNotificada = null;
        onSinMuestraActiva?.call();
        return;
      }
      final id = row['muestra_id']?.toString();
      if (id == null || id.isEmpty) {
        _ultimaMuestraNotificada = null;
        onSinMuestraActiva?.call();
        return;
      }
      if (_ultimaMuestraNotificada == id) return;
      _ultimaMuestraNotificada = id;
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
