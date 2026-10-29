import 'package:virtus2027/core/models/json_helpers.dart';

class Medalla {
  const Medalla({
    required this.id,
    required this.concursoId,
    required this.nombre,
    required this.codigo,
    required this.activa,
    this.tipo,
    this.umbralMin,
    this.umbralMax,
    this.orden,
    this.color,
    this.svgUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String concursoId;
  final String nombre;
  final String codigo;
  final bool activa;
  final String? tipo;
  final double? umbralMin;
  final double? umbralMax;
  final int? orden;
  final String? color;
  final String? svgUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Medalla.fromJson(Map<String, dynamic> json) {
    return Medalla(
      id: JsonHelpers.uuid(json['id']) ?? '',
      concursoId: JsonHelpers.uuid(json['concurso_id']) ?? '',
      nombre: JsonHelpers.stringOrEmpty(json['nombre']),
      codigo: JsonHelpers.stringOrEmpty(json['codigo']),
      activa: JsonHelpers.boolValue(json['activa'], defaultValue: true),
      tipo: JsonHelpers.string(json['tipo']),
      umbralMin: JsonHelpers.doubleValue(json['umbral_min']),
      umbralMax: JsonHelpers.doubleValue(json['umbral_max']),
      orden: JsonHelpers.intValue(json['orden']),
      color: JsonHelpers.string(json['color']),
      svgUrl: JsonHelpers.string(json['svg_url']),
      createdAt: JsonHelpers.dateTime(json['created_at']),
      updatedAt: JsonHelpers.dateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concurso_id': concursoId,
      'nombre': nombre,
      'codigo': codigo,
      'activa': activa,
      'tipo': tipo,
      'umbral_min': umbralMin,
      'umbral_max': umbralMax,
      'orden': orden,
      'color': color,
      'svg_url': svgUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
