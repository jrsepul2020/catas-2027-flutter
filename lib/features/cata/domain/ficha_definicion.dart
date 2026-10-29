class FichaCriterio {
  const FichaCriterio({
    required this.id,
    required this.label,
    this.min,
    this.max,
    this.valores = const [],
    this.columnasBotones,
  });

  final String id;
  final String label;
  final int? min;
  final int? max;
  final List<int> valores;
  /// Columnas totales del grid de botones (p. ej. Limpidez: 5, 3, 1 en cols 1, 3 y 5).
  final int? columnasBotones;

  bool get esSlider => min != null && max != null && valores.isEmpty;
  bool get esBotones => valores.isNotEmpty;

  /// Valores mostrables en fila (botones discretos o rango min–max descendente).
  List<int> get valoresDisponibles {
    if (esBotones) return valores;
    if (esSlider && min != null && max != null) {
      return List.generate(max! - min! + 1, (i) => max! - i);
    }
    return [];
  }

  bool get usaBotonesEnFila => valoresDisponibles.isNotEmpty;

  factory FichaCriterio.fromJson(Map<String, dynamic> json) {
    final valoresRaw = json['valores'];
    final valores = <int>[];
    if (valoresRaw is List) {
      for (final item in valoresRaw) {
        if (item is int) {
          valores.add(item);
        } else if (item is num) {
          valores.add(item.toInt());
        }
      }
    }

    return FichaCriterio(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      min: _readInt(json['min']),
      max: _readInt(json['max']),
      valores: valores,
      columnasBotones: _readInt(json['columnas']),
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class FichaGrupo {
  const FichaGrupo({
    required this.nombre,
    required this.criterios,
  });

  final String nombre;
  final List<FichaCriterio> criterios;

  factory FichaGrupo.fromJson(Map<String, dynamic> json) {
    final criteriosRaw = json['criterios'];
    final criterios = <FichaCriterio>[];
    if (criteriosRaw is List) {
      for (final item in criteriosRaw) {
        if (item is Map<String, dynamic>) {
          criterios.add(FichaCriterio.fromJson(item));
        } else if (item is Map) {
          criterios.add(
            FichaCriterio.fromJson(item.map((k, v) => MapEntry(k.toString(), v))),
          );
        }
      }
    }

    return FichaGrupo(
      nombre: json['nombre']?.toString() ?? '',
      criterios: criterios,
    );
  }
}

class FichaDefinicion {
  const FichaDefinicion({
    required this.grupos,
    required this.totalMin,
    required this.totalMax,
  });

  final List<FichaGrupo> grupos;
  final double totalMin;
  final double totalMax;

  List<FichaCriterio> get todosLosCriterios =>
      grupos.expand((grupo) => grupo.criterios).toList();

  factory FichaDefinicion.fromJson(Map<String, dynamic> json) {
    final gruposRaw = json['grupos'];
    final grupos = <FichaGrupo>[];
    if (gruposRaw is List) {
      for (final item in gruposRaw) {
        if (item is Map<String, dynamic>) {
          grupos.add(FichaGrupo.fromJson(item));
        } else if (item is Map) {
          grupos.add(
            FichaGrupo.fromJson(item.map((k, v) => MapEntry(k.toString(), v))),
          );
        }
      }
    }

    return FichaDefinicion(
      grupos: grupos,
      totalMin: _readDouble(json['total_min']) ?? 0,
      totalMax: _readDouble(json['total_max']) ?? 100,
    );
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, num> valoresPorDefecto() {
    final defaults = <String, num>{};
    for (final criterio in todosLosCriterios) {
      if (criterio.esSlider && criterio.min != null) {
        defaults[criterio.id] = criterio.min!;
      }
    }
    return defaults;
  }

  /// Ficha canónica de puntuación (Vinos Tranquilos — referencia Virtus tablet).
  factory FichaDefinicion.vinosTranquilos() {
    return FichaDefinicion.fromJson(const {
      'total_min': 82,
      'total_max': 100,
      'grupos': [
        {
          'nombre': 'APARIENCIA',
          'criterios': [
            {
              'id': 'limpidez',
              'label': 'Limpidez',
              'valores': [5, 3, 1],
              'columnas': 5,
            },
            {
              'id': 'color_matices',
              'label': 'Color y matices',
              'valores': [5, 4, 3, 2, 1],
            },
          ],
        },
        {
          'nombre': 'OLOR',
          'criterios': [
            {
              'id': 'pureza_olor',
              'label': 'Pureza',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'intensidad_aromatica',
              'label': 'Intensidad aromática',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'complejidad_aromatica',
              'label': 'Complejidad aromática',
              'valores': [10, 9, 8, 7, 6],
            },
          ],
        },
        {
          'nombre': 'SABOR',
          'criterios': [
            {
              'id': 'pureza_sabor',
              'label': 'Pureza',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'intensidad_sabores',
              'label': 'Intensidad sabores',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'estructura_complejidad',
              'label': 'Estructura y Complejidad',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'persistencia',
              'label': 'Persistencia',
              'valores': [10, 9, 8, 7, 6],
            },
          ],
        },
        {
          'nombre': 'GLOBAL',
          'criterios': [
            {
              'id': 'equilibrio_armonia',
              'label': 'Equilibrio y armonía',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'valoracion_general',
              'label': 'Valoración General',
              'valores': [10, 9, 8, 7, 6],
            },
          ],
        },
      ],
    });
  }

  /// Reasigna puntuaciones guardadas a los ids de esta ficha (p. ej. tras migrar desde Supabase).
  Map<String, num> remapScores(
    Map<String, num> guardados, {
    Map<String, dynamic>? fichaDb,
  }) {
    if (guardados.isEmpty) return {};

    final dbFicha = fichaDb != null && fichaDb.isNotEmpty
        ? FichaDefinicion.fromJson(fichaDb)
        : null;

    final porClave = <String, num>{};

    for (final entry in guardados.entries) {
      porClave[entry.key] = entry.value;

      if (dbFicha == null) continue;

      for (final grupo in dbFicha.grupos) {
        for (final criterio in grupo.criterios) {
          if (criterio.id != entry.key) continue;
          porClave[_criterioKey(grupo.nombre, criterio.label)] = entry.value;
        }
      }
    }

    final result = <String, num>{};
    for (final grupo in grupos) {
      for (final criterio in grupo.criterios) {
        final clave = _criterioKey(grupo.nombre, criterio.label);
        num? valor;

        if (guardados.containsKey(criterio.id)) {
          valor = guardados[criterio.id];
        } else if (porClave.containsKey(clave)) {
          valor = porClave[clave];
        }

        if (valor != null && criterio.valoresDisponibles.contains(valor.round())) {
          result[criterio.id] = valor;
        }
      }
    }

    return result;
  }

  static String _criterioKey(String grupo, String label) {
    final g = _normGrupo(grupo);
    return '$g|${_normLabel(label)}';
  }

  static String _normGrupo(String nombre) {
    final n = nombre.toLowerCase().trim();
    if (n.contains('vista') || n.contains('apariencia')) return 'apariencia';
    if (n.contains('olfato') || n.contains('olor')) return 'olor';
    if (n.contains('sabor')) return 'sabor';
    if (n.contains('global') || n.contains('final')) return 'global';
    return n;
  }

  static String _normLabel(String label) {
    return label
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
