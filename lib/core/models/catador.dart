import 'package:virtus2027/core/models/json_helpers.dart';

class Catador {
  const Catador({
    required this.id,
    required this.concursoId,
    required this.nombre,
    required this.activo,
    this.mesaId,
    this.dispositivoId,
    this.email,
    this.pais,
    this.rol,
    this.codigoCatador,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String concursoId;
  final String nombre;
  final bool activo;
  final String? mesaId;
  final String? dispositivoId;
  final String? email;
  final String? pais;
  final String? rol;
  final int? codigoCatador;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Catador.fromJson(Map<String, dynamic> json) {
    return Catador(
      id: JsonHelpers.uuid(json['id']) ?? '',
      concursoId: JsonHelpers.uuid(json['concurso_id']) ?? '',
      nombre: JsonHelpers.stringOrEmpty(json['nombre']),
      activo: JsonHelpers.boolValue(json['activo'], defaultValue: true),
      mesaId: JsonHelpers.uuid(json['mesa_id']),
      dispositivoId: JsonHelpers.uuid(json['dispositivo_id']),
      email: JsonHelpers.string(json['email']),
      pais: JsonHelpers.string(json['pais']),
      rol: JsonHelpers.string(json['rol']),
      codigoCatador: JsonHelpers.intValue(
        json['puesto'] ?? json['codigo_catador'] ?? json['codigocatador'],
      ),
      createdAt: JsonHelpers.dateTime(json['created_at']),
      updatedAt: JsonHelpers.dateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concurso_id': concursoId,
      'nombre': nombre,
      'activo': activo,
      'mesa_id': mesaId,
      'dispositivo_id': dispositivoId,
      'email': email,
      'pais': pais,
      'rol': rol,
      'codigo_catador': codigoCatador,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
