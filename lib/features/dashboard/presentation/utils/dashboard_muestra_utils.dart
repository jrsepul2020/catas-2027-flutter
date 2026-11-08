import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';

enum MuestraFiltro { pendientes, catadas, descalificadas }

String _normalizeEstado(String? estado) => (estado ?? '').toLowerCase().trim();

class DashboardMuestraStats {
  const DashboardMuestraStats({
    required this.total,
    required this.pendientes,
    required this.catadas,
    required this.descalificadas,
    required this.pospuestas,
    required this.quedan,
  });

  final int total;
  final int pendientes;
  final int catadas;
  final int descalificadas;
  final int pospuestas;
  final int quedan;

  double get progreso => total == 0 ? 0 : catadas / total;

  factory DashboardMuestraStats.fromMuestras(List<MuestraEnTanda> muestras) {
    var pendientes = 0;
    var catadas = 0;
    var descalificadas = 0;
    var pospuestas = 0;

    for (final muestra in muestras) {
      final e = _normalizeEstado(muestra.estado);
      if (e == 'descalificada') {
        descalificadas++;
        continue;
      }
      if (e == 'pospuesta') {
        pospuestas++;
        continue;
      }
      if (DashboardMuestraUtils.estaCatada(muestra)) {
        catadas++;
      } else {
        pendientes++;
      }
    }

    return DashboardMuestraStats(
      total: muestras.length,
      pendientes: pendientes,
      catadas: catadas,
      descalificadas: descalificadas,
      pospuestas: pospuestas,
      quedan: pendientes,
    );
  }
}

abstract final class DashboardMuestraUtils {
  static MuestraEnTanda? muestraEnIncidencia(List<MuestraEnTanda> muestras) {
    final ordenadas = [...muestras]..sort((a, b) => a.orden.compareTo(b.orden));
    for (final muestra in ordenadas) {
      if (_normalizeEstado(muestra.estado) == 'incidencia') return muestra;
    }
    return null;
  }

  /// Prioriza incidencia (pausa de mesa); si no, la muestra en foco normal.
  static MuestraEnTanda? muestraEnFoco(List<MuestraEnTanda> muestras) {
    return muestraEnIncidencia(muestras) ?? muestraActiva(muestras);
  }

  static MuestraEnTanda? muestraActiva(List<MuestraEnTanda> muestras) {
    final ordenadas = [...muestras]..sort((a, b) => a.orden.compareTo(b.orden));

    for (final muestra in ordenadas) {
      if (_normalizeEstado(muestra.estado) == 'activa' && !estaCatada(muestra)) {
        return muestra;
      }
    }
    for (final muestra in ordenadas) {
      final e = _normalizeEstado(muestra.estado);
      if ((e == 'pendiente' || e.isEmpty || e == 'en_curso') &&
          !estaCatada(muestra)) {
        return muestra;
      }
    }
    return null;
  }

  static List<MuestraEnTanda> filtrar(
    List<MuestraEnTanda> muestras,
    MuestraFiltro filtro,
  ) {
    return muestras.where((m) => _matchesFiltro(m, filtro)).toList();
  }

  static MuestraFiltro filtroInicial(List<MuestraEnTanda> muestras) {
    return MuestraFiltro.catadas;
  }

  static List<MuestraEnTanda> pendientes(List<MuestraEnTanda> muestras) {
    return filtrar(muestras, MuestraFiltro.pendientes);
  }

  /// Siguiente muestra pendiente por orden tras completar la de [ordenActual].
  static MuestraEnTanda? siguientePendienteDespuesDe(
    List<MuestraEnTanda> muestras,
    int ordenActual,
  ) {
    final ordenadas = [...muestras]..sort((a, b) => a.orden.compareTo(b.orden));
    for (final muestra in ordenadas) {
      if (muestra.orden <= ordenActual) continue;
      if (_matchesFiltro(muestra, MuestraFiltro.pendientes)) return muestra;
    }
    return null;
  }

  static String pillLabel(MuestraEnTanda muestra) {
    return switch (_normalizeEstado(muestra.estado)) {
      'completada' || 'finalizada' => 'CERRADA',
      'activa' => 'ACTIVA',
      'descalificada' => 'DESCALIF.',
      'pospuesta' => 'POSPUESTA',
      'incidencia' => 'INCIDENCIA',
      _ => 'PENDIENTE',
    };
  }

  static bool estaCatada(MuestraEnTanda muestra) {
    final e = _normalizeEstado(muestra.estado);
    return e == 'completada' || e == 'finalizada';
  }

  static bool estaActiva(MuestraEnTanda muestra) {
    final e = _normalizeEstado(muestra.estado);
    return e == 'activa' || e == 'en_curso';
  }

  static bool estaIncidencia(MuestraEnTanda muestra) {
    return _normalizeEstado(muestra.estado) == 'incidencia';
  }

  static bool estaPendienteApertura(MuestraEnTanda muestra) {
    final e = _normalizeEstado(muestra.estado);
    return e == 'pendiente' || e.isEmpty;
  }

  /// Tanda lista para cerrar: no quedan pendientes, pospuestas, incidencias ni en curso.
  static bool tandaCompletada(List<MuestraEnTanda> muestras) {
    if (muestras.isEmpty) return false;
    for (final m in muestras) {
      final e = _normalizeEstado(m.estado);
      if (e == 'pendiente' ||
          e.isEmpty ||
          e == 'pospuesta' ||
          e == 'activa' ||
          e == 'en_curso' ||
          e == 'incidencia') {
        return false;
      }
    }
    return true;
  }

  static bool _matchesFiltro(MuestraEnTanda muestra, MuestraFiltro filtro) {
    final e = _normalizeEstado(muestra.estado);
    return switch (filtro) {
      MuestraFiltro.pendientes =>
        !estaCatada(muestra) &&
            (e == 'pendiente' ||
                e == 'activa' ||
                e.isEmpty ||
                e == 'en_curso' ||
                e == 'incidencia'),
      MuestraFiltro.catadas => estaCatada(muestra),
      MuestraFiltro.descalificadas =>
        e == 'descalificada' || e == 'pospuesta',
    };
  }
}
