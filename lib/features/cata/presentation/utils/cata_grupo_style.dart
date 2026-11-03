import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';

abstract final class CataGrupoStyle {
  static ({Color fondo, Color tab, Color etiqueta, Color borde}) forGrupo(
    String nombre,
  ) {
    final n = nombre.toLowerCase();
    if (n.contains('apariencia') || n.contains('vista')) {
      return (
        fondo: const Color(0xFFFFF9C4),
        tab: const Color(0xFFFBC02D),
        etiqueta: const Color(0xFF6D4C0D),
        borde: const Color(0xFFF9E547),
      );
    }
    if (n.contains('olor') || n.contains('olfato')) {
      return (
        fondo: const Color(0xFFF3E5F5),
        tab: const Color(0xFFCE93D8),
        etiqueta: const Color(0xFF6A1B9A),
        borde: const Color(0xFFCE93D8),
      );
    }
    if (n.contains('sabor') || n.contains('gusto')) {
      return (
        fondo: const Color(0xFFE8F5E9),
        tab: const Color(0xFFA5D6A7),
        etiqueta: const Color(0xFF2E7D32),
        borde: const Color(0xFFA5D6A7),
      );
    }
    if (n.contains('global') || n.contains('final')) {
      return (
        fondo: const Color(0xFFFFEBEE),
        tab: const Color(0xFFEF9A9A),
        etiqueta: const Color(0xFFC62828),
        borde: const Color(0xFFEF9A9A),
      );
    }
    return (
      fondo: const Color(0xFFF5F5F5),
      tab: const Color(0xFFBDBDBD),
      etiqueta: const Color(0xFF424242),
      borde: const Color(0xFFBDBDBD),
    );
  }

  /// Color del botón seleccionado (ficha V2, por grupo sensorial).
  static Color seleccionadoForGrupo(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('apariencia') || n.contains('vista')) {
      return const Color(0xFFF9A825);
    }
    if (n.contains('olor') || n.contains('olfato')) {
      return const Color(0xFF8E24AA);
    }
    if (n.contains('sabor') || n.contains('gusto')) {
      return const Color(0xFF2E7D32);
    }
    if (n.contains('global') || n.contains('final')) {
      return const Color(0xFFC62828);
    }
    return CataColors.botonSeleccionado;
  }
}

/// Umbrales absolutos de medalla (columnas `concursos.gran_oro|oro|plata`).
class MedallaUmbrales {
  const MedallaUmbrales({
    this.granOro = 92,
    this.oro = 85,
    this.plata = 82,
  });

  final double granOro;
  final double oro;
  final double plata;

  static const MedallaUmbrales defecto = MedallaUmbrales();
}

abstract final class CataMedalla {
  /// Evalúa con umbrales absolutos de Supabase (`concursos`).
  ///
  /// [totalMin]/[totalMax] se conservan por compatibilidad; la medalla
  /// se decide por [umbrales] (puntos absolutos, no ratio).
  static ({String label, Color color, Color background}) evaluar({
    required double total,
    double totalMin = 0,
    double totalMax = 100,
    MedallaUmbrales umbrales = MedallaUmbrales.defecto,
  }) {
    if (total >= umbrales.granOro) {
      return (
        label: 'GRAN ORO',
        color: const Color(0xFF6D4C0D),
        background: const Color(0xFFFFF9C4),
      );
    }
    if (total >= umbrales.oro) {
      return (
        label: 'ORO',
        color: const Color(0xFFF57F17),
        background: const Color(0xFFFFF8E1),
      );
    }
    if (total >= umbrales.plata) {
      return (
        label: 'PLATA',
        color: const Color(0xFF546E7A),
        background: const Color(0xFFECEFF1),
      );
    }
    return (
      label: 'SIN MEDALLA',
      color: CataColors.medallaTexto,
      background: CataColors.medallaFondo,
    );
  }
}
