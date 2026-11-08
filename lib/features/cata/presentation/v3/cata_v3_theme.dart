import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';

/// Estética V3 (vinos tranquilos): fondo azulado, tarjetas blancas, pastillas.
abstract final class CataV3Theme {
  static const int columnas = 5;
  static const double radioPastilla = 12;
  static const double radioTarjeta = 12;
  static const double alturaBotonMin = 46;
  static const double alturaBotonMax = 56;
  static const double huecoBotones = 8;
  static const double huecoGrupos = 8;
  static const double anchoColumnaCriterios = 128;

  /// Fondo general azulado (referencia Virtus).
  static const Color fondo = Color(0xFFE8EEF5);

  /// Número siempre azul oscuro (no hereda el color de columna).
  static const Color numero = Color(0xFF0A2540);

  static const Color tarjeta = Colors.white;
  static const Color bordeTarjeta = Color(0xFFD5DEE8);
  static const Color divisorCriterioPuntos = Color(0xFFE2E8F0);

  /// Cabeceras de calidad (una sola vez arriba).
  static const List<String> etiquetasCalidad = [
    'EXCELENTE',
    'MUY BUENO',
    'BUENO',
    'SUFICIENTE',
    'INSUFIC.',
  ];

  /// Tinte pastel de columna (solo fondo del botón).
  static Color fondoColumna(int col) {
    return switch (col.clamp(0, 4)) {
      0 => const Color(0xFFD4EDDA),
      1 => const Color(0xFFFFE4C4),
      2 => const Color(0xFFFFF3CD),
      3 => const Color(0xFFFFE8A3),
      _ => const Color(0xFFF8D7DA),
    };
  }

  static Color bordeColumna(int col) {
    return switch (col.clamp(0, 4)) {
      0 => const Color(0xFF81C784),
      1 => const Color(0xFFFFB74D),
      2 => const Color(0xFFFFD54F),
      3 => const Color(0xFFFFCA28),
      _ => const Color(0xFFE57373),
    };
  }

  /// Selección: tono más saturado; el número pasa a blanco.
  static Color seleccionadoColumna(int col) {
    return switch (col.clamp(0, 4)) {
      0 => const Color(0xFF2E7D32),
      1 => const Color(0xFFEF6C00),
      2 => const Color(0xFFF9A825),
      3 => const Color(0xFFFFA000),
      _ => const Color(0xFFC62828),
    };
  }

  static Color etiquetaCabecera(int col) {
    return switch (col.clamp(0, 4)) {
      0 => const Color(0xFF2E7D32),
      1 => const Color(0xFFEF6C00),
      2 => const Color(0xFFF9A825),
      3 => const Color(0xFFFFA000),
      _ => const Color(0xFFC62828),
    };
  }

  static TextStyle etiquetaCalidadStyle(int col) => CataV2Theme.text(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: etiquetaCabecera(col),
        letterSpacing: 0.2,
        height: 1.05,
      );
}
