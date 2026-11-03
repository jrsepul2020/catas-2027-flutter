import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/models/json_helpers.dart';
import 'package:virtus2027/features/cata/data/cata_repository.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';

/// Trucos de prueba (solo DEMO). Eliminar este archivo al pasar a concurso.
class TrucosRepository {
  TrucosRepository({
    SupabaseClient? client,
    CataRepository? cataRepository,
  })  : _client = client ?? SupabaseConfig.client,
        _cata = cataRepository ?? CataRepository();

  final SupabaseClient _client;
  final CataRepository _cata;
  final _random = Random();

  static bool esMuestraDemo(MuestraEnTanda? muestra) =>
      muestra != null && muestra.esDemo;

  FichaDefinicion _fichaDeCategoria(Categoria? categoria) =>
      FichaDefinicion.deCategoria(
        categoria?.ficha,
        nombre: categoria?.nombre,
        codigo: categoria?.codigo,
      );

  Map<String, num> _scoresAleatorios(FichaDefinicion ficha) {
    final scores = <String, num>{};
    for (final criterio in ficha.todosLosCriterios) {
      final vals = criterio.valoresDisponibles;
      if (vals.isEmpty) continue;
      scores[criterio.id] = vals[_random.nextInt(vals.length)];
    }
    return scores;
  }

  double _totalDe(Map<String, num> scores) =>
      scores.values.fold<double>(0, (sum, v) => sum + v.toDouble());

  /// Rellena puntuaciones `enviada` de los catadores de la mesa (no presidente).
  Future<String> rellenarNotasOtrosCatadores({
    required String mesaId,
    required String tandaId,
    required String muestraId,
    required String presidenteCatadorId,
    required Categoria? categoria,
  }) async {
    final catadoresRaw = await _client
        .from('catadores')
        .select('id, rol')
        .eq('mesa_id', _toDbId(mesaId));

    final ficha = _fichaDeCategoria(categoria);
    var creadas = 0;
    var omitidas = 0;

    for (final row in catadoresRaw as List) {
      if (row is! Map<String, dynamic>) continue;
      final id = JsonHelpers.uuid(row['id']) ?? row['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      if (id == presidenteCatadorId) continue;
      final rol = (row['rol']?.toString() ?? '').toLowerCase();
      if (rol == 'presidente') continue;

      final existing = await _cata.getPuntuacion(
        catadorId: id,
        muestraId: muestraId,
        tandaId: tandaId,
      );
      final estado = existing?.estado.toLowerCase() ?? '';
      if (estado == 'enviada' || estado == 'aprobada') {
        omitidas++;
        continue;
      }

      final scores = _scoresAleatorios(ficha);
      if (scores.isEmpty) {
        throw StateError('La ficha no tiene criterios con valores válidos.');
      }

      await _cata.savePuntuacion(
        catadorId: id,
        muestraId: muestraId,
        tandaId: tandaId,
        scores: scores,
        total: _totalDe(scores),
        estado: 'enviada',
      );
      creadas++;
    }

    return 'Notas rellenadas: $creadas. Ya tenían enviada/aprobada: $omitidas.';
  }

  Future<String> reiniciarMuestraDemo({
    required String tandaMuestraId,
  }) async {
    await _client.rpc(
      'demo_reiniciar_muestra',
      params: {'p_tanda_muestra_id': _toDbId(tandaMuestraId)},
    );
    return 'Muestra reiniciada (DEMO).';
  }

  /// Reinicia todas las muestras DEMO de la tanda que no estén pendientes.
  Future<String> reiniciarTandaDemo({
    required String tandaId,
    List<MuestraEnTanda>? muestrasCache,
  }) async {
    final candidatas = <({String tandaMuestraId, String label})>[];

    if (muestrasCache != null) {
      for (final m in muestrasCache) {
        if (!m.esDemo) continue;
        final e = (m.estado ?? '').toLowerCase().trim();
        if (e == 'pendiente' || e.isEmpty) continue;
        final id = m.tandaMuestraId;
        if (id == null || id.isEmpty) continue;
        candidatas.add((tandaMuestraId: id, label: m.codigoDisplay));
      }
    } else {
      final rows = await _client
          .from('tanda_muestras')
          .select('id, estado, muestras ( codigo_texto )')
          .eq('tanda_id', _toDbId(tandaId));

      for (final row in rows as List) {
        if (row is! Map<String, dynamic>) continue;
        final estado = (row['estado']?.toString() ?? '').toLowerCase().trim();
        if (estado == 'pendiente' || estado.isEmpty) continue;
        final muestrasMap = row['muestras'];
        String? codigoTexto;
        if (muestrasMap is Map) {
          codigoTexto = muestrasMap['codigo_texto']?.toString();
        }
        if (codigoTexto == null ||
            !codigoTexto.trim().toUpperCase().startsWith('DEMO-')) {
          continue;
        }
        final id = row['id']?.toString();
        if (id == null || id.isEmpty) continue;
        candidatas.add((tandaMuestraId: id, label: codigoTexto));
      }
    }

    if (candidatas.isEmpty) {
      return 'No hay muestras DEMO no pendientes que reiniciar.';
    }

    var ok = 0;
    final errores = <String>[];
    for (final c in candidatas) {
      try {
        await reiniciarMuestraDemo(tandaMuestraId: c.tandaMuestraId);
        ok++;
      } catch (e) {
        errores.add('${c.label}: $e');
      }
    }

    if (errores.isEmpty) {
      return 'Tanda demo reiniciada: $ok muestras.';
    }
    return 'Reiniciadas $ok. Errores: ${errores.join(' | ')}';
  }

  /// True si la tanda tiene alguna muestra DEMO (para habilitar el botón).
  Future<bool> tandaTieneDemo(String tandaId) async {
    final rows = await _client
        .from('tanda_muestras')
        .select('id, muestras ( codigo_texto )')
        .eq('tanda_id', _toDbId(tandaId));
    for (final row in rows as List) {
      if (row is! Map<String, dynamic>) continue;
      final m = row['muestras'];
      if (m is Map) {
        final codigo = m['codigo_texto']?.toString() ?? '';
        if (codigo.trim().toUpperCase().startsWith('DEMO-')) return true;
      }
    }
    return false;
  }

  dynamic _toDbId(String id) => int.tryParse(id) ?? id;
}
