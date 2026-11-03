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
    this.granOro = 92,
    this.oro = 85,
    this.plata = 82,
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

  /// Umbrales de medalla desde `concursos` (Supabase).
  final double granOro;
  final double oro;
  final double plata;

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
      granOro: JsonHelpers.doubleValue(json['gran_oro']) ?? 92,
      oro: JsonHelpers.doubleValue(json['oro']) ?? 85,
      plata: JsonHelpers.doubleValue(json['plata']) ?? 82,
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
      'gran_oro': granOro,
      'oro': oro,
      'plata': plata,
    };
  }
}
