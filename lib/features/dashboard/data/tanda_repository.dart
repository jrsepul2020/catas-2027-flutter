import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/domain/tablet_dashboard.dart';
import 'package:virtus2027/features/dashboard/domain/tanda_info.dart';

class TandaRepository {
  TandaRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<TabletDashboard> fetchForTablet({
    required int tabletNumero,
    required String catadorNombre,
  }) async {
    final tanda = await _resolveTanda(tabletNumero);
    if (tanda == null) {
      return TabletDashboard(
        tabletNumero: tabletNumero,
        catadorNombre: catadorNombre,
      );
    }

    final muestras = await _fetchMuestras(tanda.id);

    return TabletDashboard(
      tabletNumero: tabletNumero,
      catadorNombre: catadorNombre,
      tanda: tanda,
      muestras: muestras,
    );
  }

  Future<TandaInfo?> _resolveTanda(int tabletNumero) async {
    final mesaRow = await _client
        .from('mesas')
        .select('tanda_actual_id')
        .eq('numero', tabletNumero.toString())
        .maybeSingle();

    final tandaActualId = mesaRow?['tanda_actual_id'];
    if (tandaActualId is int) {
      final byMesa = await _fetchTandaById(tandaActualId);
      if (byMesa != null) return byMesa;
    }

    final activa = await _client
        .from('tandas')
        .select(
          'id, nombre, codigo, descripcion, estado, categoriadecata, activa',
        )
        .eq('mesa_id', tabletNumero)
        .eq('activa', true)
        .maybeSingle();

    if (activa != null) {
      return TandaInfo.fromJson(activa);
    }

    final ultima = await _client
        .from('tandas')
        .select(
          'id, nombre, codigo, descripcion, estado, categoriadecata, activa',
        )
        .eq('mesa_id', tabletNumero)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (ultima != null) {
      return TandaInfo.fromJson(ultima);
    }

    return null;
  }

  Future<TandaInfo?> _fetchTandaById(int id) async {
    final row = await _client
        .from('tandas')
        .select(
          'id, nombre, codigo, descripcion, estado, categoriadecata, activa',
        )
        .eq('id', id)
        .maybeSingle();

    if (row == null) return null;
    return TandaInfo.fromJson(row);
  }

  Future<List<MuestraEnTanda>> _fetchMuestras(int tandaId) async {
    final filas = await _client
        .from('tanda_muestras')
        .select('orden, estado, muestra_id')
        .eq('tanda_id', tandaId)
        .order('orden', ascending: true);

    final rows = filas as List;
    if (rows.isEmpty) return [];

    final muestraIds = rows
        .map((r) => (r as Map<String, dynamic>)['muestra_id'] as int)
        .toList();

    final muestrasRaw = await _client
        .from('muestras')
        .select('id, nombre, codigo, categoriadecata')
        .inFilter('id', muestraIds);

    final muestrasById = {
      for (final m in muestrasRaw as List)
        (m as Map<String, dynamic>)['id'] as int: m,
    };

    return rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      final muestraId = row['muestra_id'] as int;
      final muestra = muestrasById[muestraId];

      return MuestraEnTanda(
        orden: row['orden'] as int,
        estado: (row['estado'] as String?) ?? '',
        nombre: (muestra?['nombre'] as String?) ?? 'Muestra $muestraId',
        codigo: muestra?['codigo']?.toString() ?? '',
        categoriaCata: (muestra?['categoriadecata'] as String?) ?? '',
      );
    }).toList();
  }
}
