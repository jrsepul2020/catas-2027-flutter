import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';

/// Estética V4: 5 niveles OIV, panel lateral compacto (tablet 1003×627).
abstract final class CataV4Theme {
  static const int columnas = 5;
  static const double alturaBotonMin = 46;
  static const double huecoBotones = 6;
  static const double radioBoton = 10;
  static const double radioTarjeta = 10;
  /// Ancho columna panel (incluye margen exterior 12 del resumen).
  static const double anchoResumen = 236;
  /// ~+25 % respecto a 108.
  static const double anchoEtiqueta = 135;
  static const double anchoBanda = 22;
  static const double bordeBoton = 1.5;
  /// Números de los botones de puntuación (más legibles tras quitar el toggle).
  static const double tamanoNumero = 26;
  /// Hueco entre etiqueta de criterio y columnas de puntos.
  static const double huecoEtiquetaPuntos = 10;

  static const Color fondo = Color(0xFFF0F3F6);
  static const Color tarjeta = Colors.white;
  static const Color borde = Color(0xFFD8DEE6);
  static const Color texto = Color(0xFF1B1F1B);
  static const Color rojoTotal = Color(0xFFE5262B);
  static const Color rojoAccion = Color(0xFFC62828);
  static const Color rojoAccionFondo = Color(0xFFFFEBEE);
  static const Color rojoAccionBorde = Color(0xFFEF9A9A);
  static const Color naranjaAccion = Color(0xFFE65100);
  static const Color naranjaAccionFondo = Color(0xFFFFF3E0);
  static const Color naranjaAccionBorde = Color(0xFFFFB74D);

  static const List<String> etiquetas = [
    'EXCELENTE',
    'MUY BUENO',
    'BUENO',
    'SUFICIENTE',
    'INSUFICIENTE',
  ];

  /// Oscuro (elegido) / claro (no elegido).
  static const List<Color> oscuros = [
    Color(0xFF14532D),
    Color(0xFF1E7D32),
    Color(0xFF6A9A45),
    Color(0xFFE08A1E),
    Color(0xFFD64045),
  ];

  static const List<Color> claros = [
    Color(0xFFD5EBD9),
    Color(0xFFDCEFE0),
    Color(0xFFE6EBD3),
    Color(0xFFFCE6C8),
    Color(0xFFFBD5D5),
  ];

  static Color oscuro(int col) => oscuros[col.clamp(0, 4)];
  static Color claro(int col) => claros[col.clamp(0, 4)];

  /// Borde del botón no elegido: un poco más oscuro que el relleno.
  static Color bordeClaro(int col) =>
      Color.lerp(claro(col), oscuro(col), 0.38)!;

  static TextStyle etiquetaNivel(int col) => CataV2Theme.text(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: oscuro(col),
        letterSpacing: 0.05,
        height: 1.05,
      );

  /// 3 valores → columnas 1, 3 y 5 (índices 0, 2, 4).
  static int columnaParaValor(int indice, int totalValores) {
    if (totalValores == 3) {
      return const [0, 2, 4][indice.clamp(0, 2)];
    }
    if (totalValores == columnas) return indice;
    if (totalValores <= 1) return 0;
    return (indice * (columnas - 1) / (totalValores - 1)).round().clamp(0, 4);
  }
}
