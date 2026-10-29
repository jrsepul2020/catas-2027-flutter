import 'package:virtus2027/core/models/json_helpers.dart';

class Categoria {
  const Categoria({
    required this.id,
    required this.concursoId,
    required this.nombre,
    required this.codigo,
    required this.activa,
    required this.ficha,
    this.orden,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String concursoId;
  final String nombre;
  final String codigo;
  final bool activa;
  final Map<String, dynamic> ficha;
  final int? orden;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: JsonHelpers.uuid(json['id']) ?? '',
      concursoId: JsonHelpers.uuid(json['concurso_id']) ?? '',
      nombre: JsonHelpers.stringOrEmpty(json['nombre']),
      codigo: JsonHelpers.stringOrEmpty(json['codigo']),
      activa: JsonHelpers.boolValue(json['activa'], defaultValue: true),
      ficha: JsonHelpers.map(json['ficha']),
      orden: JsonHelpers.intValue(json['orden']),
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
      'ficha': ficha,
      'orden': orden,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
