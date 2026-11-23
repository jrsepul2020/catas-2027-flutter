import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/features/cata/domain/cata_salida_remota.dart';
import 'package:virtus2027/features/diagnostico/diagnostico.dart';

/// Expulsa de la ficha (presidente o catador) cuando ya no deben seguir:
/// - la muestra se aprueba / deja de estar activa, o
/// - Gestión (App2) u otro puesto activa otra muestra.
///
/// Realtime es la vía rápida; el poll de respaldo corre mientras la ficha
/// está abierta (cada [pollInterval]).
class CataPageRealtimeSync {
  CataPageRealtimeSync({
    required this.tandaId,
    required this.muestraId,
    required this.catadorId,
    required this.onForzarSalida,
    this.codigoMuestra,
    SupabaseClient? client,
    this.pollInterval = const Duration(seconds: 3),
  }) : _client = client ?? SupabaseConfig.client;

  final String tandaId;
  final String muestraId;
  final String catadorId;
  final String? codigoMuestra;
  final ValueChanged<CataSalidaRemota> onForzarSalida;
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
            unawaited(_onTandaMuestraUpdate(payload.newRecord));
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
            if (!_esMuestra(record)) return;
            final estado = (record['estado']?.toString() ?? '').toLowerCase();
            if (estado == 'aprobada') {
              _notificar(
                CataSalidaRemota(
                  motivo: CataSalidaMotivo.muestraAprobada,
                  codigoMuestraActual: codigoMuestra,
                ),
              );
            }
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
        final info = await _clasificarSalida(estadoActual: estado);
        if (info != null) _notificar(info);
        return;
      }

      final activa = await _leerMuestraActiva();
      if (activa == null) return;
      final idActiva = activa['muestra_id']?.toString();
      if (idActiva == null || idActiva.isEmpty) return;
      if (!_mismoId(idActiva, muestraId) && !_mismoId(idActiva, _muestraDbId)) {
        _notificar(
          CataSalidaRemota(
            motivo: CataSalidaMotivo.otraMuestraActiva,
            nuevaMuestraId: idActiva,
            codigoMuestraActual: codigoMuestra,
          ),
        );
      }
    } catch (_) {
      // Best-effort.
    }
  }

  Future<void> _onTandaMuestraUpdate(Map<String, dynamic> record) async {
    if (_notificado) return;
    final estado = (record['estado']?.toString() ?? '').toLowerCase();
    final esActiva = estado == 'activa' || estado == 'en_curso';

    if (_esMuestra(record)) {
      if (!esActiva) {
        final info = await _clasificarSalida(estadoActual: estado);
        if (info != null) _notificar(info);
      }
      return;
    }

    if (esActiva) {
      final id = record['muestra_id']?.toString();
      _notificar(
        CataSalidaRemota(
          motivo: CataSalidaMotivo.otraMuestraActiva,
          nuevaMuestraId: id,
          codigoMuestraActual: codigoMuestra,
        ),
      );
    }
  }

  Future<CataSalidaRemota?> _clasificarSalida({
    required String estadoActual,
  }) async {
    final activa = await _leerMuestraActiva();
    final idActiva = activa?['muestra_id']?.toString();
    if (idActiva != null &&
        idActiva.isNotEmpty &&
        !_mismoId(idActiva, muestraId) &&
        !_mismoId(idActiva, _muestraDbId)) {
      return CataSalidaRemota(
        motivo: CataSalidaMotivo.otraMuestraActiva,
        nuevaMuestraId: idActiva,
        codigoMuestraActual: codigoMuestra,
      );
    }

    if (estadoActual == 'completada' || estadoActual == 'finalizada') {
      return CataSalidaRemota(
        motivo: CataSalidaMotivo.muestraAprobada,
        codigoMuestraActual: codigoMuestra,
      );
    }

    return CataSalidaRemota(
      motivo: CataSalidaMotivo.muestraDetenida,
      codigoMuestraActual: codigoMuestra,
    );
  }

  Future<Map<String, dynamic>?> _leerMuestraActiva() {
    return Diagnostico.pollSelect(
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

  void _notificar(CataSalidaRemota info) {
    if (_notificado) return;
    _notificado = true;
    _pollTimer?.cancel();
    _pollTimer = null;
    onForzarSalida(info);
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
