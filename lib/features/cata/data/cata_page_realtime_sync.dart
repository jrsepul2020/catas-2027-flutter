import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';

/// Detecta cuando el presidente aprueba la cata (muestra completada o puntuación aprobada).
class CataPageRealtimeSync {
  CataPageRealtimeSync({
    required this.tandaId,
    required this.muestraId,
    required this.catadorId,
    required this.onAprobada,
    SupabaseClient? client,
  }) : _client = client ?? SupabaseConfig.client;

  final String tandaId;
  final String muestraId;
  final String catadorId;
  final VoidCallback onAprobada;
  final SupabaseClient _client;

  RealtimeChannel? _channel;
  bool _notificado = false;

  dynamic get _tandaDbId => int.tryParse(tandaId) ?? tandaId;
  dynamic get _muestraDbId => int.tryParse(muestraId) ?? muestraId;
  dynamic get _catadorDbId => int.tryParse(catadorId) ?? catadorId;

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
            if (!_esMuestra(payload.newRecord)) return;
            final estado =
                (payload.newRecord['estado']?.toString() ?? '').toLowerCase();
            if (estado == 'completada' || estado == 'finalizada') {
              _notificar();
            }
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
            final record = payload.newRecord;
            if (!_esMuestra(record)) return;
            if (!_esCatador(record)) return;
            final estado = (record['estado']?.toString() ?? '').toLowerCase();
            if (estado == 'aprobada') _notificar();
          },
        );

    _channel = channel;
    channel.subscribe();
  }

  bool _esMuestra(Map<String, dynamic> record) {
    final raw = record['muestra_id'];
    if (raw == null) return false;
    final id = raw.toString();
    return id == muestraId || id == _muestraDbId.toString();
  }

  bool _esCatador(Map<String, dynamic> record) {
    final raw = record['catador_id'];
    if (raw == null) return false;
    final id = raw.toString();
    return id == catadorId || id == _catadorDbId.toString();
  }

  void _notificar() {
    if (_notificado) return;
    _notificado = true;
    onAprobada();
  }

  Future<void> dispose() async {
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await _client.removeChannel(channel);
    }
  }
}
