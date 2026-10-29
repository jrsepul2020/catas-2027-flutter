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
    if (n.contains('sabor')) {
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
}

abstract final class CataMedalla {
  static ({String label, Color color, Color background}) evaluar({
    required double total,
    required double totalMin,
    required double totalMax,
  }) {
    if (total < totalMin) {
      return (
        label: 'PUNTOS INSUFICIENTES',
        color: CataColors.medallaTexto,
        background: CataColors.medallaFondo,
      );
    }
    final ratio = totalMax <= 0 ? 0.0 : total / totalMax;
    if (ratio >= 0.92) {
      return (
        label: 'GRAN ORO',
        color: const Color(0xFF6D4C0D),
        background: const Color(0xFFFFF9C4),
      );
    }
    if (ratio >= 0.85) {
      return (
        label: 'ORO',
        color: const Color(0xFFF57F17),
        background: const Color(0xFFFFF8E1),
      );
    }
    if (ratio >= 0.82) {
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
