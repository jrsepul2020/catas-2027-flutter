import 'package:virtus2027/core/models/json_helpers.dart';

class Dispositivo {
  const Dispositivo({
    required this.id,
    required this.concursoId,
    required this.numero,
    required this.activo,
    this.descripcion,
    this.mesaId,
    this.catadorId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String concursoId;
  final int numero;
  final bool activo;
  final String? descripcion;
  final String? mesaId;
  final String? catadorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Dispositivo.fromJson(Map<String, dynamic> json) {
    return Dispositivo(
      id: JsonHelpers.uuid(json['id']) ?? '',
      concursoId: JsonHelpers.uuid(json['concurso_id']) ?? '',
      numero: JsonHelpers.intOrZero(json['numero']),
      activo: JsonHelpers.boolValue(json['activo'], defaultValue: true),
      descripcion: JsonHelpers.string(json['descripcion']),
      mesaId: JsonHelpers.uuid(json['mesa_id']),
      catadorId: JsonHelpers.uuid(json['catador_id']),
      createdAt: JsonHelpers.dateTime(json['created_at']),
      updatedAt: JsonHelpers.dateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concurso_id': concursoId,
      'numero': numero,
      'activo': activo,
      'descripcion': descripcion,
      'mesa_id': mesaId,
      'catador_id': catadorId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
