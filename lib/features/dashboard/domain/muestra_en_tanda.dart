class MuestraEnTanda {
  const MuestraEnTanda({
    required this.orden,
    required this.estado,
    required this.nombre,
    required this.codigo,
    required this.categoriaCata,
  });

  final int orden;
  final String estado;
  final String nombre;
  final String codigo;
  final String categoriaCata;

  String get estadoLabel {
    return switch (estado) {
      'pendiente' => 'Pendiente',
      'en_curso' => 'En curso',
      'finalizada' => 'Finalizada',
      _ => estado,
    };
  }
}
