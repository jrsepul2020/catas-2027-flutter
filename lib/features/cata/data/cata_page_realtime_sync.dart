import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/features/diagnostico/diagnostico.dart';

/// Expulsa al catador de la ficha cuando ya no debe seguir en esa muestra:
/// - el presidente aprueba (muestra completada / cualquier puntuación aprobada), o
/// - el presidente cambia de muestra (la actual deja de estar activa u otra
///   pasa a activa).
///
/// Realtime es la vía rápida; el poll de respaldo corre **siempre** mientras la
/// ficha está abierta (cada [pollInterval]), para no depender solo de Realtime
/// en el Geekom local.
class CataPageRealtimeSync {
  CataPageRealtimeSync({
    required this.tandaId,
    required this.muestraId,
    required this.catadorId,
    required this.onForzarSalida,
    SupabaseClient? client,
    this.pollInterval = const Duration(seconds: 3),
  }) : _client = client ?? SupabaseConfig.client;

  final String tandaId;
  final String muestraId;
  final String catadorId;
  final VoidCallback onForzarSalida;
  final Duration pollInterval;
  final SupabaseClient _client;

  RealtimeChannel? _channel;
  Timer? _pollTimer;
  bool _notificado = false;

  dynamic get _tandaDbId => int.tryParse(tandaId) ?? tandaId;
  dynamic get _muestraDbId => int.tryParse(muestraId) ?? muestraId;

  void subscribe() {
    if (_channel != null) return;

    final channel = _client.channel('cata-page-$tandaId-$muestraId-$catadorId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'tanda_muestras',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tanda_id',
            value: _tandaDbId,
          ),
          callback: (payload) {
            Diagnostico.ecoPostgres(payload);
            _onTandaMuestraUpdate(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'puntuaciones',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tanda_id',
            value: _tandaDbId,
          ),
          callback: (payload) {
            Diagnostico.ecoPostgres(payload);
            final record = payload.newRecord;
            // Cualquier puntuación de ESTA muestra → aprobada = mesa aprobada.
            if (!_esMuestra(record)) return;
            final estado = (record['estado']?.toString() ?? '').toLowerCase();
            if (estado == 'aprobada') _notificar();
          },
        );

    _channel = channel;
    channel.subscribe();
    _startPoll();
    unawaited(_verificarSiDebeSalir());
  }

  /// Compatibilidad con la ficha: el poll ya no se apaga al revisar/reiniciar.
  void setPollRespaldoActivo(bool activo) {
    if (activo) _startPoll();
  }

  void _startPoll() {
    if (_notificado || _pollTimer != null) return;
    _pollTimer = Timer.periodic(pollInterval, (_) {
      unawaited(_verificarSiDebeSalir());
    });
  }

  Future<void> _verificarSiDebeSalir() async {
    if (_notificado) return;
    try {
      final row = await Diagnostico.pollSelect(
        'salida_estado',
        () => _client
            .from('tanda_muestras')
            .select('estado')
            .eq('tanda_id', _tandaDbId)
            .eq('muestra_id', _muestraDbId)
            .maybeSingle(),
      );

      if (row == null) return;
      final estado = (row['estado']?.toString() ?? '').toLowerCase().trim();
      if (estado != 'activa' && estado != 'en_curso') {
        _notificar();
        return;
      }

      // Por si la actual sigue marcada activa y otra también (carrera rara).
      final activa = await Diagnostico.pollSelect(
        'salida_activa',
        () => _client
            .from('tanda_muestras')
            .select('muestra_id')
            .eq('tanda_id', _tandaDbId)
            .eq('estado', 'activa')
            .order('orden', ascending: true)
            .limit(1)
            .maybeSingle(),
      );
      if (activa == null) return;
      final idActiva = activa['muestra_id'];
      if (!_mismoId(idActiva, muestraId) && !_mismoId(idActiva, _muestraDbId)) {
        _notificar();
      }
    } catch (_) {
      // Best-effort.
    }
  }

  void _onTandaMuestraUpdate(Map<String, dynamic> record) {
    final estado = (record['estado']?.toString() ?? '').toLowerCase();
    final esActiva = estado == 'activa' || estado == 'en_curso';

    if (_esMuestra(record)) {
      if (!esActiva) _notificar();
      return;
    }

    if (esActiva) _notificar();
  }

  bool _esMuestra(Map<String, dynamic> record) {
    return _mismoId(record['muestra_id'], muestraId) ||
        _mismoId(record['muestra_id'], _muestraDbId);
  }

  bool _mismoId(dynamic a, dynamic b) {
    if (a == null || b == null) return false;
    final sa = a.toString().trim();
    final sb = b.toString().trim();
    if (sa.isEmpty || sb.isEmpty) return false;
    if (sa == sb) return true;
    final ia = int.tryParse(sa);
    final ib = int.tryParse(sb);
    return ia != null && ib != null && ia == ib;
  }

  void _notificar() {
    if (_notificado) return;
    _notificado = true;
    _pollTimer?.cancel();
    _pollTimer = null;
    onForzarSalida();
  }

  Future<void> dispose() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await _client.removeChannel(channel);
    }
  }
}
