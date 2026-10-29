class CataPuntuacion {
  const CataPuntuacion({
    required this.id,
    required this.scores,
    required this.total,
    required this.estado,
  });

  final String id;
  final Map<String, num> scores;
  final double total;
  final String estado;

  bool get soloLectura => estado.toLowerCase() == 'aprobada';

  factory CataPuntuacion.fromJson(Map<String, dynamic> json) {
    final scoresRaw = json['scores'];
    final scores = <String, num>{};
    if (scoresRaw is Map) {
      scoresRaw.forEach((key, value) {
        if (value is num) {
          scores[key.toString()] = value;
        } else if (value is String) {
          final parsed = num.tryParse(value);
          if (parsed != null) scores[key.toString()] = parsed;
        }
      });
    }

    return CataPuntuacion(
      id: json['id']?.toString() ?? '',
      scores: scores,
      total: _readDouble(json['total']) ?? 0,
      estado: json['estado']?.toString() ?? 'borrador',
    );
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
