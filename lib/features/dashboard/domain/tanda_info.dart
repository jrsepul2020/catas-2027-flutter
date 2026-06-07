class TandaInfo {
  const TandaInfo({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.descripcion,
    required this.estado,
    required this.categoriaCata,
    required this.activa,
  });

  final int id;
  final String nombre;
  final String codigo;
  final String descripcion;
  final String estado;
  final String categoriaCata;
  final bool activa;

  factory TandaInfo.fromJson(Map<String, dynamic> json) {
    return TandaInfo(
      id: json['id'] as int,
      nombre: (json['nombre'] as String?) ?? '',
      codigo: (json['codigo'] as String?) ?? '',
      descripcion: (json['descripcion'] as String?) ?? '',
      estado: (json['estado'] as String?) ?? '',
      categoriaCata: (json['categoriadecata'] as String?) ?? '',
      activa: json['activa'] as bool? ?? false,
    );
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
