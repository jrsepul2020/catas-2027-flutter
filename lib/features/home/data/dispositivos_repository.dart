import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/features/home/domain/dispositivo_home_item.dart';

class DispositivosRepository {
  DispositivosRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const _selectWithJoin = '''
id,
device_id,
catador_id,
ultima_vez,
catadores (
  nombre,
  rol,
  pais_codigo,
  puesto,
  activo,
  mesas (
    numero,
    nombre
  )
)
''';

  Future<List<DispositivoHomeItem>> fetchDispositivos() async {
    final response = await _client
        .from('dispositivos')
        .select(_selectWithJoin)
        .order('device_id', ascending: true);

    return (response as List)
        .map(
          (row) => DispositivoHomeItem.fromJoinedJson(
            row as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
