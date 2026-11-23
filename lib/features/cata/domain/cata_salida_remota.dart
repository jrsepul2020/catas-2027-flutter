/// Motivo por el que Realtime/poll expulsa de la ficha al panel.
enum CataSalidaMotivo {
  /// Cierre normal (aprobación local o remota → completada).
  muestraAprobada,

  /// Gestión (u otro puesto) activó otra muestra de la tanda.
  otraMuestraActiva,

  /// Esta muestra dejó de estar activa (pendiente, incidencia, etc.).
  muestraDetenida,
}

/// Resultado de [Navigator.pop] cuando la salida la fuerza el servidor.
class CataSalidaRemota {
  const CataSalidaRemota({
    required this.motivo,
    this.nuevaMuestraId,
    this.codigoMuestraActual,
  });

  final CataSalidaMotivo motivo;
  final String? nuevaMuestraId;
  final String? codigoMuestraActual;

  /// Modal al presidente/catador: solo si manda Gestión por encima del flujo normal.
  bool get avisarUsuario =>
      motivo == CataSalidaMotivo.otraMuestraActiva ||
      motivo == CataSalidaMotivo.muestraDetenida;

  bool get intentarAbrirActiva =>
      motivo == CataSalidaMotivo.otraMuestraActiva ||
      motivo == CataSalidaMotivo.muestraDetenida;

  String get tituloModal => switch (motivo) {
        CataSalidaMotivo.otraMuestraActiva => 'Cambio de muestra',
        CataSalidaMotivo.muestraDetenida => 'Cata interrumpida',
        CataSalidaMotivo.muestraAprobada => 'Muestra cerrada',
      };

  String get mensajeModal {
    final codigo = (codigoMuestraActual ?? '').trim();
    final de = codigo.isEmpty ? 'esta muestra' : 'la muestra $codigo';
    return switch (motivo) {
      CataSalidaMotivo.otraMuestraActiva =>
        'Gestión ha cambiado la muestra activa. Se cierra $de y volvéis al panel.',
      CataSalidaMotivo.muestraDetenida =>
        'Gestión ha detenido o cambiado $de. Volvéis al panel principal.',
      CataSalidaMotivo.muestraAprobada =>
        'La muestra ha sido cerrada. Volvéis al panel.',
    };
  }
}
