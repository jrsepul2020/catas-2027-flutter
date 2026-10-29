import 'package:virtus2027/core/models/json_helpers.dart';

class TandaMuestra {
  const TandaMuestra({
    required this.id,
    required this.tandaId,
    required this.muestraId,
    required this.orden,
    required this.estado,
    this.incidenciaMotivo,
    this.descalificadaMotivo,
    this.aprobadaPor,
    this.aprobadaAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tandaId;
  final String muestraId;
  final int orden;
  final String estado;
  final String? incidenciaMotivo;
  final String? descalificadaMotivo;
  final String? aprobadaPor;
  final DateTime? aprobadaAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TandaMuestra.fromJson(Map<String, dynamic> json) {
    return TandaMuestra(
      id: JsonHelpers.uuid(json['id']) ?? json['id']?.toString() ?? '',
      tandaId: JsonHelpers.uuid(json['tanda_id']) ?? json['tanda_id']?.toString() ?? '',
      muestraId:
          JsonHelpers.uuid(json['muestra_id']) ?? json['muestra_id']?.toString() ?? '',
      orden: JsonHelpers.intOrZero(json['orden']),
      estado: JsonHelpers.stringOrEmpty(json['estado']),
      incidenciaMotivo: JsonHelpers.string(json['incidencia_motivo']),
      descalificadaMotivo: JsonHelpers.string(json['descalificada_motivo']),
      aprobadaPor: JsonHelpers.uuid(json['aprobada_por']),
      aprobadaAt: JsonHelpers.dateTime(json['aprobada_at']),
      createdAt: JsonHelpers.dateTime(json['created_at']),
      updatedAt: JsonHelpers.dateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanda_id': tandaId,
      'muestra_id': muestraId,
      'orden': orden,
      'estado': estado,
      'incidencia_motivo': incidenciaMotivo,
      'descalificada_motivo': descalificadaMotivo,
      'aprobada_por': aprobadaPor,
      'aprobada_at': aprobadaAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
