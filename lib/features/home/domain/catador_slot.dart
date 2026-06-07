class CatadorSlot {
  const CatadorSlot({
    required this.posicion,
    required this.nombreCatador,
  });

  final int posicion;
  final String nombreCatador;

  factory CatadorSlot.fromJson(Map<String, dynamic> json) {
    return CatadorSlot(
      posicion: _readNumero(json['numero']),
      nombreCatador: (json['descripcion'] as String? ??
              json['nombre_catador'] as String?)
          ?.trim() ??
          '',
    );
  }

  static int _readNumero(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    throw FormatException('Fila sin número de tablet válido: $value');
  }

  bool get tieneCatador => nombreCatador.isNotEmpty;
}
