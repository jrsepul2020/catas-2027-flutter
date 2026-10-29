import 'package:virtus2027/core/models/json_helpers.dart';

class Tanda {
  const Tanda({
    required this.id,
    required this.concursoId,
    required this.nombre,
    required this.estado,
    required this.activa,
    this.mesaId,
    this.categoriaId,
    this.codigo,
    this.descripcion,
    this.fecha,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String concursoId;
  final String nombre;
  final String estado;
  final bool activa;
  final String? mesaId;
  final String? categoriaId;
  final String? codigo;
  final String? descripcion;
  final DateTime? fecha;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Tanda.fromJson(Map<String, dynamic> json) {
    return Tanda(
      id: JsonHelpers.uuid(json['id']) ?? '',
      concursoId: JsonHelpers.uuid(json['concurso_id']) ?? '',
      nombre: JsonHelpers.stringOrEmpty(json['nombre']),
      estado: JsonHelpers.stringOrEmpty(json['estado']),
      activa: JsonHelpers.boolValue(json['activa']),
      mesaId: JsonHelpers.uuid(json['mesa_id']),
      categoriaId: JsonHelpers.uuid(json['categoria_id']),
      codigo: JsonHelpers.string(json['codigo']),
      descripcion: JsonHelpers.string(json['descripcion']),
      fecha: JsonHelpers.dateTime(json['fecha']),
      createdAt: JsonHelpers.dateTime(json['created_at']),
      updatedAt: JsonHelpers.dateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concurso_id': concursoId,
      'nombre': nombre,
      'estado': estado,
      'activa': activa,
      'mesa_id': mesaId,
      'categoria_id': categoriaId,
      'codigo': codigo,
      'descripcion': descripcion,
      'fecha': fecha?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get estadoLabel {
    return switch (estado) {
      'en_curso' => 'En curso',
      'pendiente' => 'Pendiente',
      'finalizada' => 'Finalizada',
      _ => estado,
    };
  }
}
