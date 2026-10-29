import 'package:virtus2027/core/models/json_helpers.dart';

class Puntuacion {
  const Puntuacion({
    required this.id,
    required this.tandaMuestraId,
    required this.catadorId,
    required this.tipoHoja,
    required this.datos,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tandaMuestraId;
  final String catadorId;
  final String tipoHoja;
  final Map<String, dynamic> datos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Puntuacion.fromJson(Map<String, dynamic> json) {
    final datos = JsonHelpers.map(json['datos']);
    if (datos.isEmpty) {
      for (final entry in json.entries) {
        final key = entry.key;
        if (key.startsWith('vt_') ||
            key.startsWith('vg_') ||
            key.startsWith('ve_') ||
            key.startsWith('va_')) {
          datos[key] = entry.value;
        }
      }
    }

    return Puntuacion(
      id: JsonHelpers.uuid(json['id']) ?? '',
      tandaMuestraId: JsonHelpers.uuid(json['tanda_muestra_id']) ?? '',
      catadorId: JsonHelpers.uuid(json['catador_id']) ?? '',
      tipoHoja: JsonHelpers.stringOrEmpty(json['tipo_hoja']),
      datos: datos,
      createdAt: JsonHelpers.dateTime(json['created_at']),
      updatedAt: JsonHelpers.dateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanda_muestra_id': tandaMuestraId,
      'catador_id': catadorId,
      'tipo_hoja': tipoHoja,
      'datos': datos,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      ...datos,
    };
  }
}
