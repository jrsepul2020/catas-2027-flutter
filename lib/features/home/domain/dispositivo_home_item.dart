class DispositivoHomeItem {
  const DispositivoHomeItem({
    required this.id,
    required this.deviceId,
    required this.activo,
    this.catadorId,
    this.catadorNombre = '',
    this.rol,
    this.paisCodigo,
    this.mesaNumero,
    this.mesaNombre,
    this.ultimaVez,
  });

  final String id;
  final int deviceId;
  final bool activo;
  final String? catadorId;
  final String catadorNombre;
  final String? rol;
  final String? paisCodigo;
  final int? mesaNumero;
  final String? mesaNombre;
  final DateTime? ultimaVez;

  bool get tieneCatador => catadorNombre.trim().isNotEmpty;

  bool get esPresidente => rol?.toLowerCase() == 'presidente';

  factory DispositivoHomeItem.fromJoinedJson(Map<String, dynamic> json) {
    final catadorMap = _asMap(json['catadores']);
    final mesaMap = _asMap(catadorMap?['mesas']);

    return DispositivoHomeItem(
      id: json['id']?.toString() ?? '',
      deviceId: _readDeviceId(json['device_id']),
      catadorId: json['catador_id']?.toString(),
      activo: catadorMap != null
          ? _readActivo(catadorMap['activo'])
          : false,
      catadorNombre: catadorMap?['nombre']?.toString().trim() ?? '',
      rol: catadorMap?['rol']?.toString(),
      paisCodigo: catadorMap?['pais_codigo']?.toString(),
      mesaNumero: _readInt(mesaMap?['numero']),
      mesaNombre: mesaMap?['nombre']?.toString(),
      ultimaVez: _readDateTime(json['ultima_vez']),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    return null;
  }

  static int _readDeviceId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _readActivo(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
