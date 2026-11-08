import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';

abstract final class DashboardEstadoStyle {
  static ({Color background, Color foreground, String label}) tanda(String estado) {
    return switch (estado.toLowerCase()) {
      'abierta' => (
          background: VirtusColors.fondoSuave,
          foreground: VirtusColors.primario,
          label: 'Abierta',
        ),
      'pendiente' => (
          background: const Color(0xFFE8F0EA),
          foreground: VirtusColors.secundario,
          label: 'Pendiente',
        ),
      'completada' => (
          background: VirtusColors.muyClaro,
          foreground: VirtusColors.oscuro,
          label: 'Completada',
        ),
      _ => (
          background: const Color(0xFFE8F0EA),
          foreground: VirtusColors.secundario,
          label: estado,
        ),
    };
  }

  static ({Color dot, Color text, String label}) muestra(String estado) {
    return switch (estado.toLowerCase()) {
      'activa' || 'en_curso' => (
          dot: VirtusColors.medio,
          text: VirtusColors.primario,
          label: 'Activa',
        ),
      'pendiente' => (
          dot: VirtusColors.muyClaro,
          text: VirtusColors.secundario,
          label: 'Pendiente',
        ),
      'completada' || 'finalizada' => (
          dot: VirtusColors.claro,
          text: VirtusColors.oscuro,
          label: 'Cerrada',
        ),
      'incidencia' => (
          dot: const Color(0xFFE65100),
          text: const Color(0xFFBF360C),
          label: 'Incidencia',
        ),
      _ => (
          dot: VirtusColors.muyClaro,
          text: VirtusColors.secundario,
          label: estado,
        ),
    };
  }

  static Color parseHexColor(String? hex, {Color fallback = VirtusColors.primario}) {
    return VirtusColors.primarioUi(hex);
  }
}
