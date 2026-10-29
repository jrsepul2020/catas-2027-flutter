import 'package:virtus2027/core/models/json_helpers.dart';

class Muestra {
  const Muestra({
    required this.id,
    required this.concursoId,
    required this.nombre,
    required this.activo,
    this.categoriaId,
    this.empresaId,
    this.codigo,
    this.codigoBarras,
    this.codigoTexto,
    this.categoria,
    this.categoriaCata,
    this.categoriaOiv,
    this.descripcion,
    this.origen,
    this.pais,
    this.anio,
    this.igp,
    this.existencias,
    this.mesaId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String concursoId;
  final String nombre;
  final bool activo;
  final String? categoriaId;
  final String? empresaId;
  final int? codigo;
  final String? codigoBarras;
  final String? codigoTexto;
  final String? categoria;
  final String? categoriaCata;
  final String? categoriaOiv;
  final String? descripcion;
  final String? origen;
  final String? pais;
  final int? anio;
  final String? igp;
  final int? existencias;
  final String? mesaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Muestra.fromJson(Map<String, dynamic> json) {
    return Muestra(
      id: JsonHelpers.uuid(json['id']) ?? '',
      concursoId: JsonHelpers.uuid(json['concurso_id']) ?? '',
      nombre: JsonHelpers.stringOrEmpty(json['nombre']),
      activo: JsonHelpers.boolValue(json['activo'], defaultValue: true),
      categoriaId: JsonHelpers.uuid(json['categoria_id']),
      empresaId: JsonHelpers.uuid(json['empresa_id']),
      codigo: JsonHelpers.intValue(json['codigo']),
      codigoBarras: JsonHelpers.string(json['codigo_barras'] ?? json['codigobarras']),
      codigoTexto: JsonHelpers.string(json['codigo_texto'] ?? json['codigotexto']),
      categoria: JsonHelpers.string(json['categoria']),
      categoriaCata: JsonHelpers.string(
        json['categoria_cata'] ?? json['categoriadecata'],
      ),
      categoriaOiv: JsonHelpers.string(json['categoria_oiv'] ?? json['categoriaoiv']),
      descripcion: JsonHelpers.string(json['descripcion']),
      origen: JsonHelpers.string(json['origen']),
      pais: JsonHelpers.string(json['pais']),
      anio: JsonHelpers.intValue(json['anio']),
      igp: JsonHelpers.string(json['igp']),
      existencias: JsonHelpers.intValue(json['existencias']),
      mesaId: JsonHelpers.uuid(json['mesa_id']),
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
      'categoria_id': categoriaId,
      'empresa_id': empresaId,
      'codigo': codigo,
      'codigo_barras': codigoBarras,
      'codigo_texto': codigoTexto,
      'categoria': categoria,
      'categoria_cata': categoriaCata,
      'categoria_oiv': categoriaOiv,
      'descripcion': descripcion,
      'origen': origen,
      'pais': pais,
      'anio': anio,
      'igp': igp,
      'existencias': existencias,
      'mesa_id': mesaId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
