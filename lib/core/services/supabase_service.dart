import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/core/models/catador.dart';
import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/models/concurso.dart';
import 'package:virtus2027/core/models/dispositivo.dart';
import 'package:virtus2027/core/models/mesa.dart';
import 'package:virtus2027/core/models/json_helpers.dart';
import 'package:virtus2027/core/models/muestra.dart';
import 'package:virtus2027/core/models/tanda.dart';
import 'package:virtus2027/core/models/tanda_muestra.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/domain/tablet_dashboard.dart';

class SupabaseService {
  SupabaseService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<Concurso?> getConcursoActivo() async {
    final row = await _client
        .from('concursos')
        .select()
        .eq('activo', true)
        .maybeSingle();

    if (row == null) return null;
    return Concurso.fromJson(row);
  }

  Future<List<Categoria>> getCategorias() async {
    final rows = await _client.from('categorias').select().order(
          'orden',
          ascending: true,
        );

    return (rows as List)
        .map((row) => Categoria.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<Mesa>> getMesasByConcurso(String concursoId) async {
    final rows = await _client
        .from('mesas')
        .select()
        .eq('concurso_id', concursoId)
        .order('numero', ascending: true);

    return (rows as List)
        .map((row) => Mesa.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<Catador>> getCatadoresByMesa(String mesaId) async {
    final rows = await _client
        .from('catadores')
        .select()
        .eq('mesa_id', mesaId)
        .order('nombre', ascending: true);

    return (rows as List)
        .map((row) => Catador.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<TabletDashboard> getDashboardForDispositivo({
    String? dispositivoId,
    String? catadorId,
    int? mesaNumero,
    int? deviceId,
    int? dispositivoNumero,
    String? catadorNombreFallback,
  }) async {
    final concursoRow = await _client
        .from('concursos')
        .select()
        .eq('activo', true)
        .maybeSingle();
    if (concursoRow == null) {
      throw StateError('No hay concurso activo configurado.');
    }

    final concurso = Concurso.fromJson(concursoRow);
    final concursoLogoUrl = JsonHelpers.string(concursoRow['logo_url']);
    final concursoColorPrimario =
        JsonHelpers.string(concursoRow['color_primario']);

    final dispositivo = await _resolveDispositivo(
      concursoId: concurso.id,
      dispositivoId: dispositivoId,
      deviceId: deviceId,
      dispositivoNumero: dispositivoNumero,
    );

    final catador = await _resolveCatador(
      dispositivo: dispositivo,
      catadorIdHint: catadorId ?? dispositivo?.catadorId,
    );

    final mesa = await _resolveMesa(
      concursoId: concurso.id,
      dispositivo: dispositivo,
      catador: catador,
      mesaNumero: mesaNumero,
    );

    final catadorNombre = _resolveCatadorNombre(
      catador: catador,
      dispositivo: dispositivo,
      fallback: catadorNombreFallback,
    );

    final resolvedTanda = await _resolveTanda(mesa: mesa);
    final tanda = resolvedTanda?.tanda;
    final tandaNumero = resolvedTanda?.numero;

    final muestras = tanda != null
        ? await _getMuestrasEnTanda(
            tandaId: tanda.id,
            catadorId: catador?.id,
          )
        : const <MuestraEnTanda>[];

    // Prioridad: categoría de la TANDA (define la cata); luego muestra.
    Categoria? categoria;
    if (tanda != null) {
      if (tanda.categoriaId != null && tanda.categoriaId!.isNotEmpty) {
        categoria = await getCategoriaById(tanda.categoriaId!);
      }
      categoria ??= await _resolveCategoriaDesdeMuestras(muestras);
      categoria ??= await _resolveCategoriaFromTanda(tanda.id);
    }

    final resolvedLabel = mesa?.numero ?? mesaNumero ?? deviceId ?? 0;

    return TabletDashboard(
      dispositivoNumero: resolvedLabel,
      catadorNombre: catadorNombre,
      concurso: concurso,
      concursoLogoUrl: concursoLogoUrl,
      concursoColorPrimario: concursoColorPrimario,
      dispositivo: dispositivo,
      mesa: mesa,
      catador: catador,
      tanda: tanda,
      tandaNumero: tandaNumero,
      categoria: categoria,
      muestras: muestras,
    );
  }

  Future<Dispositivo?> _resolveDispositivo({
    required String concursoId,
    String? dispositivoId,
    int? deviceId,
    int? dispositivoNumero,
  }) async {
    if (dispositivoId != null && dispositivoId.isNotEmpty) {
      final byId = await _getDispositivoById(dispositivoId);
      if (byId != null) return byId;
    }

    if (deviceId != null) {
      final byDeviceId = await _getDispositivoByDeviceId(
        concursoId: concursoId,
        deviceId: deviceId,
      );
      if (byDeviceId != null) return byDeviceId;
    }

    if (dispositivoNumero != null) {
      return _getDispositivoByNumero(
        concursoId: concursoId,
        numero: dispositivoNumero,
      );
    }

    return null;
  }

  Future<Dispositivo?> _getDispositivoById(String dispositivoId) async {
    final row = await _client
        .from('dispositivos')
        .select()
        .eq('id', dispositivoId)
        .maybeSingle();

    if (row == null) return null;
    return Dispositivo.fromJson(row);
  }

  Future<Dispositivo?> _getDispositivoByDeviceId({
    required String concursoId,
    required int deviceId,
  }) async {
    final row = await _client
        .from('dispositivos')
        .select()
        .eq('concurso_id', concursoId)
        .eq('device_id', deviceId)
        .maybeSingle();

    if (row == null) return null;
    return Dispositivo.fromJson(row);
  }

  Future<Dispositivo?> _getDispositivoByNumero({
    required String concursoId,
    required int numero,
  }) async {
    final row = await _client
        .from('dispositivos')
        .select()
        .eq('concurso_id', concursoId)
        .eq('numero', numero)
        .maybeSingle();

    if (row == null) return null;
    return Dispositivo.fromJson(row);
  }

  Future<Mesa?> _getMesaById(String mesaId) async {
    final row =
        await _client.from('mesas').select().eq('id', mesaId).maybeSingle();
    if (row == null) return null;
    return Mesa.fromJson(row);
  }

  Future<Mesa?> _getMesaByNumero({
    required String concursoId,
    required int numero,
  }) async {
    final row = await _client
        .from('mesas')
        .select()
        .eq('concurso_id', concursoId)
        .eq('numero', numero)
        .maybeSingle();

    if (row == null) return null;
    return Mesa.fromJson(row);
  }

  Future<Mesa?> _resolveMesa({
    required String concursoId,
    required Dispositivo? dispositivo,
    Catador? catador,
    int? mesaNumero,
  }) async {
    if (catador?.mesaId != null && catador!.mesaId!.isNotEmpty) {
      final byCatador = await _getMesaById(catador.mesaId!);
      if (byCatador != null) return byCatador;
    }

    if (dispositivo?.mesaId != null && dispositivo!.mesaId!.isNotEmpty) {
      final byDispositivo = await _getMesaById(dispositivo.mesaId!);
      if (byDispositivo != null) return byDispositivo;
    }

    if (mesaNumero != null) {
      return _getMesaByNumero(
        concursoId: concursoId,
        numero: mesaNumero,
      );
    }

    return null;
  }

  Future<Catador?> _getCatadorById(String catadorId) async {
    final row = await _client
        .from('catadores')
        .select()
        .eq('id', catadorId)
        .maybeSingle();

    if (row == null) return null;
    return Catador.fromJson(row);
  }

  Future<Catador?> _resolveCatador({
    required Dispositivo? dispositivo,
    String? catadorIdHint,
    Mesa? mesa,
  }) async {
    if (catadorIdHint != null && catadorIdHint.isNotEmpty) {
      final byHint = await _getCatadorById(catadorIdHint);
      if (byHint != null) return byHint;
    }

    if (dispositivo?.catadorId != null &&
        dispositivo!.catadorId!.isNotEmpty) {
      final byDispositivo = await _getCatadorById(dispositivo.catadorId!);
      if (byDispositivo != null) return byDispositivo;
    }

    if (mesa != null) {
      final catadores = await getCatadoresByMesa(mesa.id);
      if (catadores.isNotEmpty) return catadores.first;
    }

    return null;
  }

  String _resolveCatadorNombre({
    required Catador? catador,
    required Dispositivo? dispositivo,
    required String? fallback,
  }) {
    if (catador != null && catador.nombre.isNotEmpty) return catador.nombre;
    if (fallback != null && fallback.trim().isNotEmpty) return fallback.trim();
    if (dispositivo?.descripcion?.trim().isNotEmpty == true) {
      return dispositivo!.descripcion!.trim();
    }
    return 'Sin catador asignado';
  }

  Future<({Tanda tanda, int? numero})?> _resolveTanda({required Mesa? mesa}) async {
    if (mesa == null) return null;

    // Buscar tanda abierta
    final activa = await _client
        .from('tandas')
        .select()
        .eq('mesa_id', mesa.id)
        .eq('estado', 'abierta')
        .maybeSingle();
    if (activa != null) {
      return (
        tanda: Tanda.fromJson(activa),
        numero: JsonHelpers.intValue(activa['numero']),
      );
    }

    // Fallback: última tanda por número
    final ultima = await _client
        .from('tandas')
        .select()
        .eq('mesa_id', mesa.id)
        .order('numero', ascending: false)
        .limit(1)
        .maybeSingle();
    if (ultima != null) {
      return (
        tanda: Tanda.fromJson(ultima),
        numero: JsonHelpers.intValue(ultima['numero']),
      );
    }

    return null;
  }

  Future<Categoria?> _resolveCategoriaDesdeMuestras(
    List<MuestraEnTanda> muestras,
  ) async {
    MuestraEnTanda? preferida;
    for (final m in muestras) {
      final e = (m.estado ?? '').toLowerCase().trim();
      if (e == 'activa' || e == 'en_curso') {
        preferida = m;
        break;
      }
    }
    preferida ??= muestras.isEmpty ? null : muestras.first;
    final id = preferida?.categoriaId;
    if (id == null || id.isEmpty) return null;
    return getCategoriaById(id);
  }

  Future<Categoria?> _resolveCategoriaFromTanda(String tandaId) async {
    final link = await _client
        .from('tanda_muestras')
        .select('muestra_id')
        .eq('tanda_id', tandaId)
        .order('orden', ascending: true)
        .limit(1)
        .maybeSingle();
    if (link == null) return null;

    final muestra = await _client
        .from('muestras')
        .select('categoria_id')
        .eq('id', link['muestra_id'])
        .maybeSingle();
    final categoriaId = JsonHelpers.uuid(muestra?['categoria_id']);
    if (categoriaId == null) return null;

    return getCategoriaById(categoriaId);
  }

  Future<Categoria?> getCategoriaById(String categoriaId) async {
    final row = await _client
        .from('categorias')
        .select()
        .eq('id', categoriaId)
        .maybeSingle();

    if (row == null) return null;
    return Categoria.fromJson(row);
  }

  Future<List<MuestraEnTanda>> _getMuestrasEnTanda({
    required String tandaId,
    String? catadorId,
  }) async {
    final filas = await _client
        .from('tanda_muestras')
        .select()
        .eq('tanda_id', tandaId)
        .order('orden', ascending: true);

    final rows = (filas as List)
        .map((row) => TandaMuestra.fromJson(row as Map<String, dynamic>))
        .toList();

    if (rows.isEmpty) return [];

    final muestraIds = rows.map((row) => row.muestraId).toList();
    final muestrasRaw =
        await _client.from('muestras').select().inFilter('id', muestraIds);

    final muestrasById = <String, Map<String, dynamic>>{};
    for (final item in muestrasRaw as List) {
      if (item is! Map<String, dynamic>) continue;
      final id = JsonHelpers.uuid(item['id']) ?? item['id']?.toString();
      if (id == null || id.isEmpty) continue;
      muestrasById[id] = item;
    }

    final categoriaIds = <String>{};
    for (final raw in muestrasById.values) {
      final cid = JsonHelpers.uuid(raw['categoria_id']) ??
          raw['categoria_id']?.toString();
      if (cid != null && cid.isNotEmpty) categoriaIds.add(cid);
    }
    final nombresCategoria = <String, String>{};
    if (categoriaIds.isNotEmpty) {
      final catsRaw = await _client
          .from('categorias')
          .select('id, nombre')
          .inFilter('id', categoriaIds.toList());
      for (final item in catsRaw as List) {
        if (item is! Map<String, dynamic>) continue;
        final id =
            JsonHelpers.uuid(item['id']) ?? item['id']?.toString() ?? '';
        final nombre = JsonHelpers.stringOrEmpty(item['nombre']);
        if (id.isNotEmpty && nombre.isNotEmpty) {
          nombresCategoria[id] = nombre;
        }
      }
    }

    final puntuaciones = await _getPuntuacionesPorMuestra(
      tandaId: tandaId,
      catadorId: catadorId,
    );

    return rows.map((row) {
      final muestraRaw = muestrasById[row.muestraId];
      final muestra =
          muestraRaw != null ? Muestra.fromJson(muestraRaw) : null;
      final punt = puntuaciones[row.muestraId];
      final estadoMuestra =
          JsonHelpers.string(row.estado)?.toLowerCase().trim() ?? '';
      final muestraAprobada =
          estadoMuestra == 'completada' || estadoMuestra == 'finalizada';
      final catId = muestra?.categoriaId;
      return MuestraEnTanda.fromTandaMuestra(
        orden: row.orden,
        estado: row.estado,
        muestraId: row.muestraId,
        tandaMuestraId: row.id,
        nombre: muestra?.nombre,
        codigo: muestra?.codigoCiego ?? muestra?.codigo,
        codigoCiego: muestra?.codigoCiego ??
            JsonHelpers.intValue(muestraRaw?['codigo_ciego']),
        codigoTexto: muestra?.codigoTexto ??
            JsonHelpers.string(muestraRaw?['codigo_texto']),
        categoriaId: catId,
        categoriaNombre: catId == null ? null : nombresCategoria[catId],
        categoriaCata: muestra?.categoriaCata,
        incidenciaMotivo: row.incidenciaMotivo,
      ).copyWith(
        puntuacionCatador: muestraAprobada ? punt?.catador : null,
        puntuacionMedia: muestraAprobada ? punt?.media : null,
        horaCata: muestraAprobada ? punt?.hora : null,
      );
    }).toList();
  }

  Future<Map<String, ({double? catador, double? media, DateTime? hora})>>
      _getPuntuacionesPorMuestra({
    required String tandaId,
    String? catadorId,
  }) async {
    final rows = await _client
        .from('puntuaciones')
        .select()
        .eq('tanda_id', _toDbId(tandaId));

    final porMuestra = <String, List<Map<String, dynamic>>>{};
    for (final row in rows as List) {
      if (row is! Map<String, dynamic>) continue;
      final muestraId = JsonHelpers.uuid(row['muestra_id']) ??
          row['muestra_id']?.toString();
      if (muestraId == null || muestraId.isEmpty) continue;
      porMuestra.putIfAbsent(muestraId, () => []).add(row);
    }

    final result = <String, ({double? catador, double? media, DateTime? hora})>{};
    for (final entry in porMuestra.entries) {
      final totals = <double>[];
      double? catadorTotal;
      DateTime? horaCatador;

      for (final row in entry.value) {
        final puntEstado =
            JsonHelpers.string(row['estado'])?.toLowerCase().trim() ?? '';
        if (puntEstado != 'aprobada') continue;

        final total = JsonHelpers.doubleValue(row['total']);
        if (total != null) totals.add(total);

        final rowCatadorId = JsonHelpers.uuid(row['catador_id']) ??
            row['catador_id']?.toString();
        if (catadorId != null &&
            rowCatadorId != null &&
            rowCatadorId == catadorId) {
          catadorTotal = total;
          horaCatador = JsonHelpers.dateTime(row['updated_at']) ??
              JsonHelpers.dateTime(row['created_at']);
        }
      }

      result[entry.key] = (
        catador: catadorTotal,
        media: totals.isEmpty
            ? null
            : totals.reduce((a, b) => a + b) / totals.length,
        hora: horaCatador,
      );
    }

    return result;
  }

  /// Cierra [tandaActualId] y abre la siguiente pendiente de la misma mesa.
  /// Devuelve la tanda abierta o `null` si no hay más (fin de jornada).
  Future<Tanda?> iniciarSiguienteTanda({
    required String mesaId,
    required String tandaActualId,
  }) async {
    final mesaDbId = _toDbId(mesaId);
    final actualDbId = _toDbId(tandaActualId);

    final actual = await _client
        .from('tandas')
        .select()
        .eq('id', actualDbId)
        .maybeSingle();
    if (actual == null) {
      throw StateError('No se encontró la tanda actual.');
    }
    final numeroActual = JsonHelpers.intValue(actual['numero']) ?? 0;

    await _client.from('tandas').update({
      'estado': 'finalizada',
      'activa': false,
    }).eq('id', actualDbId);

    final siguiente = await _client
        .from('tandas')
        .select()
        .eq('mesa_id', mesaDbId)
        .gt('numero', numeroActual)
        .order('numero', ascending: true)
        .limit(1)
        .maybeSingle();

    if (siguiente == null) return null;

    final siguienteId = _toDbId(siguiente['id']?.toString() ?? '');
    await _client.from('tandas').update({
      'estado': 'abierta',
      'activa': true,
    }).eq('id', siguienteId);

    final abierta = await _client
        .from('tandas')
        .select()
        .eq('id', siguienteId)
        .maybeSingle();
    if (abierta == null) return null;
    return Tanda.fromJson(abierta);
  }

  /// ¿Hay otra tanda preparada después de [tandaActualId] en la mesa?
  Future<bool> haySiguienteTanda({
    required String mesaId,
    required String tandaActualId,
  }) async {
    final actual = await _client
        .from('tandas')
        .select('numero')
        .eq('id', _toDbId(tandaActualId))
        .maybeSingle();
    if (actual == null) return false;
    final numeroActual = JsonHelpers.intValue(actual['numero']) ?? 0;
    final siguiente = await _client
        .from('tandas')
        .select('id')
        .eq('mesa_id', _toDbId(mesaId))
        .gt('numero', numeroActual)
        .limit(1)
        .maybeSingle();
    return siguiente != null;
  }

  dynamic _toDbId(String id) => int.tryParse(id) ?? id;
}
