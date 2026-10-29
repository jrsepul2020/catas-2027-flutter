import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';

/// Escucha cambios en Supabase Realtime y notifica al dashboard (con debounce).
class DashboardRealtimeSync {
  DashboardRealtimeSync({
    required this.tandaId,
    required this.onChanged,
    SupabaseClient? client,
    this.debounce = const Duration(milliseconds: 400),
  }) : _client = client ?? SupabaseConfig.client;

  final String tandaId;
  final VoidCallback onChanged;
  final Duration debounce;
  final SupabaseClient _client;

  RealtimeChannel? _channel;
  Timer? _debounceTimer;

  dynamic get _tandaDbId => int.tryParse(tandaId) ?? tandaId;

  void subscribe() {
    if (_channel != null) return;

    final channel = _client.channel('dashboard-tanda-$tandaId');

    void onEvent(PostgresChangePayload _) => _scheduleReload();

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tanda_muestras',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tanda_id',
            value: _tandaDbId,
          ),
          callback: onEvent,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'puntuaciones',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tanda_id',
            value: _tandaDbId,
          ),
          callback: onEvent,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tandas',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: _tandaDbId,
          ),
          callback: onEvent,
        );

    _channel = channel;
    channel.subscribe();
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
