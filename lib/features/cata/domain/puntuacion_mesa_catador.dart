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

  /// Norma OIV / general: discordante si se aleja ≥ 7 puntos de la media.
  static const double umbralDiscordanciaOiv = 7;

  /// Diferencia absoluta respecto a la media del panel (null si no aplica).
  double? desvioAbsoluto(double? media) {
    if (total == null || media == null) return null;
    return (total! - media).abs();
  }

  /// Solo true si incumple la norma OIV (±7 pts respecto a la media).
  bool esDiscordante(double? media) {
    final d = desvioAbsoluto(media);
    if (d == null) return false;
    return d >= umbralDiscordanciaOiv;
  }

  /// Etiqueta de desvío: solo si es discordante; si no, null (no mostrar).
  String? desvioLabel(double? media) {
    if (!esDiscordante(media)) return null;
    final d = desvioAbsoluto(media)!;
    final pts = d.truncateToDouble() == d
        ? d.toStringAsFixed(0)
        : d.toStringAsFixed(1);
    if (total! > media!) return '↑ +$pts pts';
    if (total! < media) return '↓ −$pts pts';
    return null;
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
