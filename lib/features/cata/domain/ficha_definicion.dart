import 'dart:math';

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

  /// Ficha desde `categorias.ficha` (JSON en Supabase).
  /// Si falta o está vacía, elige factory canónica por nombre/código.
  factory FichaDefinicion.deCategoria(
    Map<String, dynamic>? fichaJson, {
    String? nombre,
    String? codigo,
  }) {
    if (fichaJson != null && fichaJson.isNotEmpty) {
      try {
        final ficha = FichaDefinicion.fromJson(fichaJson);
        if (ficha.grupos.isNotEmpty) return ficha;
      } catch (_) {
        // Fallback abajo.
      }
    }
    return FichaDefinicion.canonicaPara(
      nombre: nombre,
      codigo: codigo,
    );
  }

  /// Factory canónica según categoría (sin JSON de BD).
  factory FichaDefinicion.canonicaPara({String? nombre, String? codigo}) {
    final cod = (codigo ?? '').toLowerCase().trim();
    final nom = (nombre ?? '').toLowerCase();
    if (cod == 'ao' ||
        nom.contains('aove') ||
        nom.contains('aceite') ||
        nom.contains('oliva')) {
      return FichaDefinicion.aoves();
    }
    if (cod == 've' || nom.contains('espumos') || nom.contains('cava')) {
      return FichaDefinicion.espumosos();
    }
    if (cod == 'vg' ||
        nom.contains('generos') ||
        nom.contains('espirituos') ||
        nom.contains('licor')) {
      return FichaDefinicion.generososEspirituosos();
    }
    return FichaDefinicion.vinosTranquilos();
  }

  /// Relleno de prueba: total aleatorio entre [82, 100] (valores válidos de cada criterio).
  Map<String, num> scoresPruebaSobre87() {
    final criterios = todosLosCriterios
        .where((c) => c.valoresDisponibles.isNotEmpty)
        .toList();
    if (criterios.isEmpty) return {};

    // Empieza en máximo de cada criterio.
    final scores = <String, num>{
      for (final c in criterios) c.id: c.valoresDisponibles.first,
    };

    num suma() => scores.values.fold<num>(0, (a, b) => a + b);

    final maxTotal = suma().round();
    final hi = maxTotal.clamp(0, 100);
    final lo = hi < 82 ? hi : 82;
    if (lo >= hi) return scores;

    final rnd = Random();
    final objetivo = lo + rnd.nextInt(hi - lo + 1);

    // Baja criterios al azar hasta llegar al objetivo (o no poder bajar más).
    var guard = 0;
    while (suma() > objetivo && guard < 800) {
      guard++;
      final c = criterios[rnd.nextInt(criterios.length)];
      final vals = c.valoresDisponibles;
      final actual = scores[c.id]!.round();
      final idx = vals.indexOf(actual);
      if (idx < 0 || idx >= vals.length - 1) continue;
      scores[c.id] = vals[idx + 1];
    }

    return scores;
  }

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

  /// Generosos y Espirituosos (`categorias.codigo = vg`). Total máx. 100.
  factory FichaDefinicion.generososEspirituosos() {
    return FichaDefinicion.fromJson(const {
      'total_min': 82,
      'total_max': 100,
      'grupos': [
        {
          'nombre': 'VISTA',
          'criterios': [
            {
              'id': 'limpidez',
              'label': 'Limpidez',
              'valores': [5, 3, 1],
              'columnas': 5,
            },
            {
              'id': 'color_viscosidad',
              'label': 'Color y viscosidad',
              'valores': [5, 4, 3, 2, 1],
            },
          ],
        },
        {
          'nombre': 'OLFATO',
          'criterios': [
            {
              'id': 'o_intensidad',
              'label': 'Intensidad aromática',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'o_pureza',
              'label': 'Pureza',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'o_complejidad',
              'label': 'Complejidad aromática',
              'valores': [10, 9, 8, 7, 6],
            },
          ],
        },
        {
          'nombre': 'SABOR',
          'criterios': [
            {
              'id': 's_pureza',
              'label': 'Pureza',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 's_intensidad',
              'label': 'Intensidad de los sabores',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 's_estructura',
              'label': 'Estructura y complejidad',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 's_persistencia',
              'label': 'Persistencia',
              'valores': [10, 9, 8, 7, 6],
            },
          ],
        },
        {
          'nombre': 'FINAL',
          'criterios': [
            {
              'id': 'g_equilibrio',
              'label': 'Equilibrio y armonía',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'g_valoracion',
              'label': 'Valoración general',
              'valores': [10, 9, 8, 7, 6],
            },
          ],
        },
      ],
    });
  }

  /// Espumosos (`categorias.codigo = ve`). Total máx. 100.
  factory FichaDefinicion.espumosos() {
    return FichaDefinicion.fromJson(const {
      'total_min': 82,
      'total_max': 100,
      'grupos': [
        {
          'nombre': 'VISTA',
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
            {
              'id': 'efervescencia',
              'label': 'Efervescencia',
              'valores': [5, 4, 3, 2, 1],
            },
          ],
        },
        {
          'nombre': 'OLFATO',
          'criterios': [
            {
              'id': 'o_pureza',
              'label': 'Pureza',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'o_intensidad',
              'label': 'Intensidad aromática',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'o_complejidad',
              'label': 'Complejidad aromática',
              'valores': [10, 9, 8, 7, 6],
            },
          ],
        },
        {
          'nombre': 'SABOR',
          'criterios': [
            {
              'id': 's_efervescencia',
              'label': 'Efervescencia',
              'valores': [5, 4, 3, 2, 1],
            },
            {
              'id': 's_pureza',
              'label': 'Pureza',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 's_intensidad',
              'label': 'Intensidad de los sabores',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 's_complejidad',
              'label': 'Complejidad y persistencia',
              'valores': [10, 9, 8, 7, 6],
            },
          ],
        },
        {
          'nombre': 'FINAL',
          'criterios': [
            {
              'id': 'g_equilibrio',
              'label': 'Equilibrio y armonía',
              'valores': [10, 9, 8, 7, 6],
            },
            {
              'id': 'g_valoracion',
              'label': 'Valoración general',
              'valores': [10, 9, 8, 7, 6],
            },
          ],
        },
      ],
    });
  }

  /// Ficha canónica AOVE (Virtus tablet / `categorias.codigo = ao`).
  /// Olfato 34 + Gusto 46 + Final 20 = 100.
  factory FichaDefinicion.aoves() {
    return FichaDefinicion.fromJson(const {
      'total_min': 80,
      'total_max': 100,
      'grupos': [
        {
          'nombre': 'OLFATO',
          'criterios': [
            {
              'id': 'o_frutado',
              'label': 'Frutado aceituna',
              'valores': [6, 5, 3, 1, 0],
            },
            {
              'id': 'o_otros',
              'label': 'Otros frutos',
              'valores': [4, 3, 2, 1, 0],
            },
            {
              'id': 'o_verde',
              'label': 'Verde, hierba, hoja',
              'valores': [4, 3, 2, 1, 0],
            },
            {
              'id': 'o_armonia',
              'label': 'Armonía',
              'valores': [20, 15, 10, 5, 0],
            },
          ],
        },
        {
          'nombre': 'GUSTO',
          'criterios': [
            {
              'id': 'g_frutado',
              'label': 'Frutado aceituna',
              'valores': [10, 8, 5, 2, 0],
            },
            {
              'id': 'g_dulce',
              'label': 'Dulce',
              'valores': [4, 3, 2, 1, 0],
            },
            {
              'id': 'g_amargo',
              'label': 'Amargo',
              'valores': [4, 3, 2, 1, 0],
            },
            {
              'id': 'g_picante',
              'label': 'Picante',
              'valores': [4, 3, 2, 1, 0],
            },
            {
              'id': 'g_verde',
              'label': 'Verde, hierba, hoja',
              'valores': [4, 3, 2, 1, 0],
            },
            {
              'id': 'g_armonia',
              'label': 'Armonía',
              'valores': [20, 15, 10, 5, 0],
            },
          ],
        },
        {
          'nombre': 'FINAL',
          'criterios': [
            {
              'id': 'f_armonia',
              'label': 'Armonía',
              'valores': [10, 8, 5, 2, 0],
            },
            {
              'id': 'f_persistencia',
              'label': 'Persistencia',
              'valores': [10, 8, 5, 2, 0],
            },
          ],
        },
      ],
    });
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
    if (n.contains('sabor') || n.contains('gusto')) return 'sabor';
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
