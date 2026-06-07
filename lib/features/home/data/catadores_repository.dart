import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/features/home/domain/catador_slot.dart';

class CatadoresRepository {
  CatadoresRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const int totalSlots = 25;
  static const String _table = 'tablets';

  Future<List<CatadorSlot>> fetchSlots() async {
    final response = await _client
        .from(_table)
        .select('numero, descripcion')
        .order('numero', ascending: true);

    final rows = (response as List)
        .map((row) => CatadorSlot.fromJson(row as Map<String, dynamic>))
        .toList();

    return _fillMissingSlots(rows);
  }

  List<CatadorSlot> _fillMissingSlots(List<CatadorSlot> rows) {
    final byPosition = {for (final row in rows) row.posicion: row};

    return List.generate(
      totalSlots,
      (index) {
        final posicion = index + 1;
        return byPosition[posicion] ??
            CatadorSlot(posicion: posicion, nombreCatador: '');
      },
    );
  }
}
