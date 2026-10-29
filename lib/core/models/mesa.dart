import 'package:virtus2027/core/models/json_helpers.dart';

class Mesa {
  const Mesa({
    required this.id,
    required this.concursoId,
    required this.numero,
    required this.nombre,
    required this.capacidad,
    required this.activa,
    required this.ocupada,
    required this.catadoresActuales,
    this.aprobacionParcialHabilitada = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String concursoId;
  final int numero;
  final String nombre;
  final int capacidad;
  final bool activa;
  final bool ocupada;
  final int catadoresActuales;
  final bool aprobacionParcialHabilitada;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: JsonHelpers.uuid(json['id']) ?? '',
      concursoId: JsonHelpers.uuid(json['concurso_id']) ?? '',
      numero: JsonHelpers.intOrZero(json['numero']),
      nombre: JsonHelpers.stringOrEmpty(json['nombre']),
      capacidad: JsonHelpers.intOrZero(json['capacidad']),
      activa: JsonHelpers.boolValue(json['activa'], defaultValue: true),
      ocupada: JsonHelpers.boolValue(json['ocupada']),
      catadoresActuales: JsonHelpers.intOrZero(json['catadores_actuales']),
      aprobacionParcialHabilitada: JsonHelpers.boolValue(
        json['aprobacion_parcial_habilitada'],
      ),
      createdAt: JsonHelpers.dateTime(json['created_at']),
      updatedAt: JsonHelpers.dateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concurso_id': concursoId,
      'numero': numero,
      'nombre': nombre,
      'capacidad': capacidad,
      'activa': activa,
      'ocupada': ocupada,
      'catadores_actuales': catadoresActuales,
      'aprobacion_parcial_habilitada': aprobacionParcialHabilitada,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
