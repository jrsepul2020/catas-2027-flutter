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
    if (e == 'enviada' || e == 'aprobada') return true;
    // Tras un desbloqueo erróneo quedan `borrador` con total: cuentan para aprobar.
    if ((e == 'borrador' || e.isEmpty) && (total ?? 0) > 0) return true;
    return false;
  }

  bool get enviadaOficial {
    final e = estadoPuntuacion.toLowerCase();
    return e == 'enviada' || e == 'aprobada';
  }

  String get estadoLabel {
    if (enviadaOficial) return 'RECIBIDO';
    if (recibida) return 'EN REVISIÓN';
    return 'PENDIENTE';
  }

  PuntuacionMesaCatador copyWith({
    int? orden,
    String? catadorId,
    String? nombre,
    double? total,
    String? estadoPuntuacion,
    bool? esPresidente,
  }) {
    return PuntuacionMesaCatador(
      orden: orden ?? this.orden,
      catadorId: catadorId ?? this.catadorId,
      nombre: nombre ?? this.nombre,
      total: total ?? this.total,
      estadoPuntuacion: estadoPuntuacion ?? this.estadoPuntuacion,
      esPresidente: esPresidente ?? this.esPresidente,
    );
  }

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

  /// Evita que un `enviada`→`borrador` momentáneo apague RECIBIDO / APROBAR.
  ResumenAprobacionMesa fusionarEstable(ResumenAprobacionMesa? anterior) {
    if (anterior == null) return this;
    final prev = {
      for (final c in anterior.catadores) c.catadorId: c,
    };
    final fused = <PuntuacionMesaCatador>[];
    for (final c in catadores) {
      final p = prev[c.catadorId];
      if (p != null &&
          p.recibida &&
          !c.recibida &&
          (c.total ?? p.total ?? 0) > 0) {
        fused.add(
          c.copyWith(
            total: c.total ?? p.total,
            estadoPuntuacion: 'enviada',
          ),
        );
      } else {
        fused.add(c);
      }
    }
    return ResumenAprobacionMesa(
      catadores: fused,
      codigoMuestra: codigoMuestra,
    );
  }
}
