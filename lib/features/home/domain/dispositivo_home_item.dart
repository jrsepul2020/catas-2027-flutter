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
    this.puesto,
    this.ultimaVez,
    this.deviceIdRaw,
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
  final int? puesto;
  final DateTime? ultimaVez;
  /// Valor crudo de `dispositivos.device_id` (p. ej. `tablet-001`).
  final String? deviceIdRaw;

  bool get tieneCatador => catadorNombre.trim().isNotEmpty;

  bool get esPresidente => rol?.toLowerCase() == 'presidente';

  /// Número de tablet para UI (evita un `0` engañoso si el parse falla).
  String get deviceIdLabel =>
      deviceId > 0 ? deviceId.toString() : (deviceIdRaw?.trim().isNotEmpty == true
          ? deviceIdRaw!.trim()
          : '—');

  factory DispositivoHomeItem.fromJoinedJson(Map<String, dynamic> json) {
    final catadorMap = _asMap(json['catadores']);
    final mesaMap = _asMap(catadorMap?['mesas']);
    final rawDevice = json['device_id']?.toString();

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
      puesto: _readInt(catadorMap?['puesto']),
      ultimaVez: _readDateTime(json['ultima_vez']),
      deviceIdRaw: rawDevice,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    return null;
  }

  /// Acepta `12`, `"12"` o `"tablet-012"` → `12`.
  static int _readDeviceId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      final direct = int.tryParse(trimmed);
      if (direct != null) return direct;
      final match = RegExp(r'(\d+)\s*$').firstMatch(trimmed);
      if (match != null) return int.parse(match.group(1)!);
    }
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
