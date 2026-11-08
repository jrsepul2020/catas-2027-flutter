import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/core/models/json_helpers.dart';
import 'package:virtus2027/features/cata/domain/cata_puntuacion.dart';
import 'package:virtus2027/features/cata/domain/puntuacion_mesa_catador.dart';
import 'package:virtus2027/features/diagnostico/diagnostico.dart';

class CataRepository {
  CataRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  Future<CataPuntuacion?> getPuntuacion({
    required String catadorId,
    required String muestraId,
    required String tandaId,
  }) async {
    final row = await _client
        .from('puntuaciones')
        .select()
        .eq('catador_id', _toDbId(catadorId))
        .eq('muestra_id', _toDbId(muestraId))
        .eq('tanda_id', _toDbId(tandaId))
        .maybeSingle();

    if (row == null) return null;
    return CataPuntuacion.fromJson(row);
  }

  Future<void> savePuntuacion({
    required String catadorId,
    required String muestraId,
    required String tandaId,
    required Map<String, num> scores,
    required double total,
    required String estado,
  }) async {
    final tipo = estado.toLowerCase() == 'enviada' ? 'enviar' : 'guardar';
    await Diagnostico.escritura(
      tipo: tipo,
      tabla: 'puntuaciones',
      match: {
        'catador_id': catadorId,
        'muestra_id': muestraId,
        'tanda_id': tandaId,
      },
      run: () async {
        final payload = {
          'catador_id': _toDbId(catadorId),
          'muestra_id': _toDbId(muestraId),
          'tanda_id': _toDbId(tandaId),
          'scores': scores,
          'total': total,
          'estado': estado,
        };

        var existing = await getPuntuacion(
          catadorId: catadorId,
          muestraId: muestraId,
          tandaId: tandaId,
        );

        // Recata: si sigue 'aprobada' y la muestra está abierta, desbloquear antes.
        if (existing != null && existing.soloLectura) {
          await desbloquearPuntuacionesSiRecata(
            tandaId: tandaId,
            muestraId: muestraId,
          );
          existing = await getPuntuacion(
            catadorId: catadorId,
            muestraId: muestraId,
            tandaId: tandaId,
          );
        }

        if (existing != null) {
          await _client
              .from('puntuaciones')
              .update(payload)
              .eq('id', _toDbId(existing.id));
        } else {
          await _client.from('puntuaciones').insert(payload);
        }
      },
    );
  }

  Future<void> abrirCataMuestra({
    required String tandaId,
    required String muestraId,
  }) async {
    await Diagnostico.escritura(
      tipo: 'abrir_cata',
      tabla: 'tanda_muestras',
      match: {'muestra_id': muestraId, 'tanda_id': tandaId},
      run: () async {
        final tandaDbId = _toDbId(tandaId);
        final muestraDbId = _toDbId(muestraId);

        // Antes de `activa`: tras recata admin las notas están en `enviada`
        // (o `aprobada`). Pasar a `borrador` conservando scores evita que el
        // catador, al entrar por Realtime, vea la ficha como ya enviada.
        // `enviada`→`borrador` no lo bloquea el candado; `aprobada` solo si
        // la muestra ya no está completada (p. ej. tras `reabrir_muestra`).
        try {
          await _client
              .from('puntuaciones')
              .update({'estado': 'borrador'})
              .eq('tanda_id', tandaDbId)
              .eq('muestra_id', muestraDbId)
              .inFilter('estado', ['aprobada', 'enviada']);
        } catch (_) {}

        await _client
            .from('tanda_muestras')
            .update({'estado': 'pendiente'})
            .eq('tanda_id', tandaDbId)
            .eq('estado', 'activa');

        await _client
            .from('tanda_muestras')
            .update({'estado': 'activa'})
            .eq('tanda_id', tandaDbId)
            .eq('muestra_id', muestraDbId);
      },
    );
  }

  /// Tras ABRIR CATA en una muestra reabierta: `aprobada`/`enviada` → `borrador`
  /// (mismas notas). No usar a mitad de cata sobre envíos frescos.
  Future<bool> prepararPuntuacionesParaRecata({
    required String tandaId,
    required String muestraId,
  }) async {
    final estado = await getEstadoMuestra(
      tandaId: tandaId,
      muestraId: muestraId,
    );
    if (estado != 'activa' &&
        estado != 'en_curso' &&
        estado != 'pendiente') {
      return false;
    }
    try {
      await Diagnostico.escritura(
        tipo: 'recata_preparar_edicion',
        tabla: 'puntuaciones',
        match: {'muestra_id': muestraId, 'tanda_id': tandaId},
        run: () async {
          final tandaDbId = _toDbId(tandaId);
          final muestraDbId = _toDbId(muestraId);
          await _client
              .from('puntuaciones')
              .update({'estado': 'borrador'})
              .eq('tanda_id', tandaDbId)
              .eq('muestra_id', muestraDbId)
              .inFilter('estado', ['aprobada', 'enviada']);
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Si quedaron filas `aprobada` con la muestra ya abierta, pasa a `borrador`.
  /// Devuelve `false` si el candado de BD lo impide (muestra aún cerrada).
  Future<bool> desbloquearPuntuacionesSiRecata({
    required String tandaId,
    required String muestraId,
  }) async {
    final estado = await getEstadoMuestra(
      tandaId: tandaId,
      muestraId: muestraId,
    );
    if (estado != 'activa' &&
        estado != 'en_curso' &&
        estado != 'pendiente') {
      return false;
    }
    try {
      await Diagnostico.escritura(
        tipo: 'recata_desbloquear',
        tabla: 'puntuaciones',
        match: {'muestra_id': muestraId, 'tanda_id': tandaId},
        run: () async {
          await _client
              .from('puntuaciones')
              .update({'estado': 'borrador'})
              .eq('tanda_id', _toDbId(tandaId))
              .eq('muestra_id', _toDbId(muestraId))
              .eq('estado', 'aprobada');
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// True si la muestra admite cata/recata (no está cerrada).
  Future<bool> muestraAdmiteEdicion({
    required String tandaId,
    required String muestraId,
  }) async {
    final estado = await getEstadoMuestra(
      tandaId: tandaId,
      muestraId: muestraId,
    );
    return estado == 'activa' ||
        estado == 'en_curso' ||
        estado == 'pendiente';
  }

  Future<ResumenAprobacionMesa> getResumenMesa({
    required String mesaId,
    required String tandaId,
    required String muestraId,
    required String codigoMuestra,
  }) async {
    final catadoresRaw = await _client
        .from('catadores')
        .select()
        .eq('mesa_id', _toDbId(mesaId))
        .order('puesto', ascending: true);

    final puntuacionesRaw = await _client
        .from('puntuaciones')
        .select()
        .eq('tanda_id', _toDbId(tandaId))
        .eq('muestra_id', _toDbId(muestraId));

    final puntosPorCatador = <String, Map<String, dynamic>>{};
    for (final row in puntuacionesRaw as List) {
      if (row is! Map<String, dynamic>) continue;
      final id = JsonHelpers.uuid(row['catador_id']) ??
          row['catador_id']?.toString();
      if (id != null) puntosPorCatador[id] = row;
    }

    final rows = <Map<String, dynamic>>[];
    for (final row in catadoresRaw as List) {
      if (row is Map<String, dynamic>) rows.add(row);
    }
    // Mismo criterio que la mesa: puesto de asignación, no nombre.
    rows.sort((a, b) {
      final pa = JsonHelpers.intValue(a['puesto']);
      final pb = JsonHelpers.intValue(b['puesto']);
      if (pa != null && pb != null && pa != pb) return pa.compareTo(pb);
      if (pa != null && pb == null) return -1;
      if (pa == null && pb != null) return 1;
      return JsonHelpers.stringOrEmpty(a['nombre'])
          .compareTo(JsonHelpers.stringOrEmpty(b['nombre']));
    });

    final catadores = <PuntuacionMesaCatador>[];
    var fallbackOrden = 0;
    for (final row in rows) {
      fallbackOrden++;
      final id = JsonHelpers.uuid(row['id']) ?? row['id']?.toString() ?? '';
      final punt = puntosPorCatador[id];
      final rol = JsonHelpers.string(row['rol'])?.toLowerCase() ?? '';
      final puesto = JsonHelpers.intValue(row['puesto']) ?? fallbackOrden;
      catadores.add(
        PuntuacionMesaCatador(
          orden: puesto,
          catadorId: id,
          nombre: JsonHelpers.stringOrEmpty(row['nombre']),
          total: punt != null ? JsonHelpers.doubleValue(punt['total']) : null,
          estadoPuntuacion:
              JsonHelpers.string(punt?['estado']) ?? 'pendiente',
          esPresidente: rol == 'presidente',
        ),
      );
    }

    return ResumenAprobacionMesa(
      catadores: catadores,
      codigoMuestra: codigoMuestra,
    );
  }

  /// Marca la muestra como incidencia de mesa (pausa hasta admin).
  Future<void> marcarIncidencia({
    required String tandaId,
    required String muestraId,
    required String motivo,
  }) async {
    await Diagnostico.escritura(
      tipo: 'incidencia',
      tabla: 'tanda_muestras',
      match: {'muestra_id': muestraId, 'tanda_id': tandaId},
      run: () async {
        await _client.from('tanda_muestras').update({
          'estado': 'incidencia',
          'incidencia_motivo': motivo,
        }).eq('tanda_id', _toDbId(tandaId)).eq('muestra_id', _toDbId(muestraId));
      },
    );
  }

  /// Estado actual de la fila en `tanda_muestras` (una lectura puntual).
  Future<String?> getEstadoMuestra({
    required String tandaId,
    required String muestraId,
  }) async {
    final row = await _client
        .from('tanda_muestras')
        .select('estado')
        .eq('tanda_id', _toDbId(tandaId))
        .eq('muestra_id', _toDbId(muestraId))
        .maybeSingle();
    if (row == null) return null;
    return (row['estado']?.toString() ?? '').toLowerCase().trim();
  }

  Future<void> aprobarMuestra({
    required String tandaId,
    required String muestraId,
  }) async {
    await Diagnostico.escritura(
      tipo: 'aprobar',
      tabla: 'tanda_muestras',
      match: {'muestra_id': muestraId, 'tanda_id': tandaId},
      run: () async {
        final tandaDbId = _toDbId(tandaId);
        final muestraDbId = _toDbId(muestraId);

        await _client
            .from('puntuaciones')
            .update({'estado': 'aprobada'})
            .eq('tanda_id', tandaDbId)
            .eq('muestra_id', muestraDbId)
            .inFilter('estado', ['enviada', 'borrador']);

        await _client
            .from('tanda_muestras')
            .update({'estado': 'completada'})
            .eq('tanda_id', tandaDbId)
            .eq('muestra_id', muestraDbId);

        final actual = await _client
            .from('tanda_muestras')
            .select('orden')
            .eq('tanda_id', tandaDbId)
            .eq('muestra_id', muestraDbId)
            .maybeSingle();

        if (actual == null) return;

        final ordenActual = _readInt(actual['orden']);
        if (ordenActual == null) return;

        final siguientes = await _client
            .from('tanda_muestras')
            .select('id, estado')
            .eq('tanda_id', tandaDbId)
            .gt('orden', ordenActual)
            .order('orden', ascending: true);

        for (final row in siguientes as List) {
          if (row is! Map<String, dynamic>) continue;
          final estado =
              (row['estado']?.toString() ?? '').toLowerCase().trim();
          if (estado == 'pendiente' ||
              estado.isEmpty ||
              estado == 'en_curso' ||
              estado == 'activa') {
            await _client
                .from('tanda_muestras')
                .update({'estado': 'pendiente'})
                .eq('id', _toDbId(row['id']?.toString() ?? ''));
            break;
          }
        }
      },
    );
  }

  int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  dynamic _toDbId(String id) {
    return int.tryParse(id) ?? id;
  }
}
