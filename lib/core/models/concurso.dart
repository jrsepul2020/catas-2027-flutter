import 'package:virtus2027/core/models/json_helpers.dart';

class Concurso {
  const Concurso({
    required this.id,
    required this.nombre,
    required this.anio,
    required this.activo,
    this.descripcion,
    this.lugar,
    this.fechaInicio,
    this.fechaFin,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nombre;
  final int anio;
  final bool activo;
  final String? descripcion;
  final String? lugar;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Concurso.fromJson(Map<String, dynamic> json) {
    return Concurso(
      id: JsonHelpers.uuid(json['id']) ?? '',
      nombre: JsonHelpers.stringOrEmpty(json['nombre']),
      anio: JsonHelpers.intOrZero(json['anio']),
      activo: JsonHelpers.boolValue(json['activo']),
      descripcion: JsonHelpers.string(json['descripcion']),
      lugar: JsonHelpers.string(json['lugar']),
      fechaInicio: JsonHelpers.dateTime(json['fecha_inicio']),
      fechaFin: JsonHelpers.dateTime(json['fecha_fin']),
      createdAt: JsonHelpers.dateTime(json['created_at']),
      updatedAt: JsonHelpers.dateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'anio': anio,
      'activo': activo,
      'descripcion': descripcion,
      'lugar': lugar,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
