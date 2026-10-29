import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';

/// Escucha cambios en puntuaciones de una muestra (debounce, filtro por tanda).
class CataAprobacionRealtimeSync {
  CataAprobacionRealtimeSync({
    required this.tandaId,
    required this.muestraId,
    required this.onChanged,
    SupabaseClient? client,
    this.debounce = const Duration(milliseconds: 500),
  }) : _client = client ?? SupabaseConfig.client;

  final String tandaId;
  final String muestraId;
  final VoidCallback onChanged;
  final Duration debounce;
  final SupabaseClient _client;

  RealtimeChannel? _channel;
  Timer? _debounceTimer;

  dynamic get _tandaDbId => int.tryParse(tandaId) ?? tandaId;

  void subscribe() {
    if (_channel != null) return;

    final channel = _client.channel(
      'aprobacion-$tandaId-$muestraId',
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'puntuaciones',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'tanda_id',
        value: _tandaDbId,
      ),
      callback: (payload) {
        final record = payload.newRecord.isNotEmpty
            ? payload.newRecord
            : payload.oldRecord;
        if (!_esMuestraActual(record)) return;
        _scheduleReload();
      },
    );

    _channel = channel;
    channel.subscribe();
  }

  bool _esMuestraActual(Map<String, dynamic> record) {
    final raw = record['muestra_id'];
    if (raw == null) return false;
    final id = raw.toString();
    final muestraDb = int.tryParse(muestraId) ?? muestraId;
    return id == muestraId || id == muestraDb.toString();
  }

  void _scheduleReload() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, onChanged);
  }

  Future<void> dispose() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await _client.removeChannel(channel);
    }
  }
}
