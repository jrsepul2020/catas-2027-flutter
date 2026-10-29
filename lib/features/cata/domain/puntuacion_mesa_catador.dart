class PuntuacionMesaCatador {
  const PuntuacionMesaCatador({
    required this.orden,
    required this.catadorId,
    required this.nombre,
    this.total,
    this.estadoPuntuacion = 'pendiente',
    this.esPresidente = false,
  });

  final int orden;
  final String catadorId;
  final String nombre;
  final double? total;
  final String estadoPuntuacion;
  final bool esPresidente;

  bool get recibida {
    final e = estadoPuntuacion.toLowerCase();
    return e == 'enviada' || e == 'aprobada';
  }

  String get estadoLabel => recibida ? 'RECIBIDO' : 'PENDIENTE';

  String? desvioLabel(double? media) {
    if (total == null || media == null || media == 0) return null;
    final pct = ((total! - media) / media * 100).abs();
    final texto = pct.toStringAsFixed(1);
    if (total! > media) return '↑ Más alta $texto%';
    if (total! < media) return '↓ A la baja $texto%';
    return '—';
  }

  bool get desvioAlto {
    return false;
  }
}

class ResumenAprobacionMesa {
  const ResumenAprobacionMesa({
    required this.catadores,
    required this.codigoMuestra,
  });

  final List<PuntuacionMesaCatador> catadores;
  final String codigoMuestra;

  int get totalCatadores => catadores.length;

  int get puntuacionesRecibidas =>
      catadores.where((c) => c.recibida).length;

  bool get todosHanPuntuado =>
      catadores.isNotEmpty && puntuacionesRecibidas == catadores.length;

  double? get promedio {
    final totals = catadores
        .map((c) => c.total)
        .whereType<double>()
        .where((t) => t > 0)
        .toList();
    if (totals.isEmpty) return null;
    return totals.reduce((a, b) => a + b) / totals.length;
  }

  String get promedioLabel {
    final p = promedio;
    if (p == null) return '—';
    return p.truncateToDouble() == p ? p.toStringAsFixed(0) : p.toStringAsFixed(1);
  }
}
