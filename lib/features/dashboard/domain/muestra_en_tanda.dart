class MuestraEnTanda {
  const MuestraEnTanda({
    required this.muestraId,
    required this.orden,
    this.tandaMuestraId,
    this.estado,
    this.nombre,
    this.codigo,
    this.codigoCiego,
    this.codigoTexto,
    this.categoriaId,
    this.categoriaNombre,
    this.categoriaCata,
    this.incidenciaMotivo,
    this.puntuacionCatador,
    this.puntuacionMedia,
    this.horaCata,
  });

  final String muestraId;
  final int orden;
  /// Id de la fila en `tanda_muestras` (para RPC demo, etc.).
  final String? tandaMuestraId;
  final String? estado;
  final String? nombre;
  final String? codigo;
  final String? codigoCiego;
  final String? codigoTexto;
  /// `muestras.categoria_id`.
  final String? categoriaId;
  /// Nombre resuelto desde `categorias` (no el texto libre categoria_cata).
  final String? categoriaNombre;
  final String? categoriaCata;
  final String? incidenciaMotivo;
  final double? puntuacionCatador;
  final double? puntuacionMedia;
  final DateTime? horaCata;

  bool get esDemo =>
      (codigoTexto ?? '').trim().toUpperCase().startsWith('DEMO-');

  MuestraEnTanda copyWith({
    double? puntuacionCatador,
    double? puntuacionMedia,
    DateTime? horaCata,
  }) {
    return MuestraEnTanda(
      muestraId: muestraId,
      orden: orden,
      tandaMuestraId: tandaMuestraId,
      estado: estado,
      nombre: nombre,
      codigo: codigo,
      codigoCiego: codigoCiego,
      codigoTexto: codigoTexto,
      categoriaId: categoriaId,
      categoriaNombre: categoriaNombre,
      categoriaCata: categoriaCata,
      incidenciaMotivo: incidenciaMotivo,
      puntuacionCatador: puntuacionCatador ?? this.puntuacionCatador,
      puntuacionMedia: puntuacionMedia ?? this.puntuacionMedia,
      horaCata: horaCata ?? this.horaCata,
    );
  }

  factory MuestraEnTanda.fromTandaMuestra({
    required int orden,
    String? estado,
    required String muestraId,
    String? tandaMuestraId,
    String? nombre,
    int? codigo,
    String? codigoCiego,
    String? codigoTexto,
    String? categoriaId,
    String? categoriaNombre,
    String? categoriaCata,
    String? incidenciaMotivo,
  }) {
    return MuestraEnTanda(
      muestraId: muestraId,
      orden: orden,
      tandaMuestraId: _nonEmpty(tandaMuestraId),
      estado: _nonEmpty(estado),
      nombre: _nonEmpty(nombre) ?? 'Muestra $muestraId',
      codigo: codigo?.toString(),
      codigoCiego: _nonEmpty(codigoCiego),
      codigoTexto: _nonEmpty(codigoTexto),
      categoriaId: _nonEmpty(categoriaId),
      categoriaNombre: _nonEmpty(categoriaNombre),
      categoriaCata: _nonEmpty(categoriaCata),
      incidenciaMotivo: _nonEmpty(incidenciaMotivo),
      puntuacionCatador: null,
      puntuacionMedia: null,
      horaCata: null,
    );
  }

  /// Nombre a mostrar: categoría real de BD, luego subtipo, luego fallback.
  String categoriaDisplay({String? fallback}) {
    if (categoriaNombre != null && categoriaNombre!.isNotEmpty) {
      return categoriaNombre!;
    }
    if (categoriaCata != null && categoriaCata!.isNotEmpty) {
      return categoriaCata!;
    }
    return fallback ?? '';
  }

  String get horaCataLabel {
    if (horaCata == null) return '—';
    final h = horaCata!;
    final hh = h.hour.toString().padLeft(2, '0');
    final mm = h.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String get puntuacionCatadorLabel {
    if (puntuacionCatador == null) return '—';
    return _formatPuntos(puntuacionCatador!);
  }

  String get puntuacionMediaLabel {
    if (puntuacionMedia == null) return '—';
    return _formatPuntos(puntuacionMedia!);
  }

  static String _formatPuntos(double value) {
    return value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String get codigoDisplay {
    if (codigoCiego != null && codigoCiego!.isNotEmpty) return codigoCiego!;
    if (codigoTexto != null && codigoTexto!.isNotEmpty) return codigoTexto!;
    if (codigo != null && codigo!.isNotEmpty) return codigo!;
    return '—';
  }

  String get estadoLabel {
    return switch ((estado ?? '').toLowerCase()) {
      'activa' => 'Activa',
      'pendiente' => 'Pendiente',
      'completada' => 'Completada',
      'en_curso' => 'Activa',
      'finalizada' => 'Completada',
      'incidencia' => 'Incidencia',
      '' => 'Pendiente',
      _ => estado ?? 'Pendiente',
    };
  }
}
