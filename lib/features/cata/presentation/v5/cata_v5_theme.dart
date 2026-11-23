import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/cata_v4_theme.dart';

/// Estilo de botones de puntuación en V5 (comparar en modo pruebas).
enum CataBotonesEstiloV5 {
  /// Como V4: fondo pastel / relleno oscuro al elegir.
  pastel,
  /// Contorno de nivel / relleno oscuro al elegir.
  contorno,
}

/// Estética V5 (vinos): total en vivo, botones más cuadrados, panel legible.
abstract final class CataV5Theme {
  static const int columnas = CataV4Theme.columnas;
  static const double alturaBotonMin = 44;
  static const double huecoBotones = 10;
  static const double radioBoton = 10;
  static const double radioTarjeta = 12;
  static const double anchoResumen = 236;
  /// Más ancho de etiqueta: botones más estrechos + check.
  static const double anchoEtiqueta = 158;
  static const double anchoBanda = 22;
  static const double bordeBoton = 1.5;
  /// ~10 % menos que V4 (24 → 22).
  static const double tamanoNumero = 22;
  static const double huecoEtiquetaPuntos = 8;
  static const double gapGrupos = 8;
  /// Factor de ancho del botón respecto a la celda (~25 % más estrecho).
  static const double factorAnchoBoton = 0.75;

  static const Color fondo = Color(0xFFF0F3F6);
  static const Color tarjeta = Colors.white;
  static const Color borde = Color(0xFFE5E7EB);
  static const Color texto = Color(0xFF1B1F1B);
  static const Color textoMuted = Color(0xFF6B7280);
  static const Color rojoTotal = CataV4Theme.rojoTotal;
  static const Color rojoAccion = CataV4Theme.rojoAccion;
  static const Color rojoAccionFondo = CataV4Theme.rojoAccionFondo;
  static const Color rojoAccionBorde = CataV4Theme.rojoAccionBorde;
  static const Color naranjaAccion = CataV4Theme.naranjaAccion;
  static const Color naranjaAccionFondo = CataV4Theme.naranjaAccionFondo;
  static const Color naranjaAccionBorde = CataV4Theme.naranjaAccionBorde;
  static const Color botonIdleFondo = Color(0xFFFAFAFA);
  static const Color numeroIdle = Color(0xFF374151);

  static const List<String> etiquetas = CataV4Theme.etiquetas;

  static Color oscuro(int col) => CataV4Theme.oscuro(col);
  static Color claro(int col) => CataV4Theme.claro(col);
  static Color bordeClaro(int col) => CataV4Theme.bordeClaro(col);

  static TextStyle etiquetaNivel(int col) => CataV2Theme.text(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: oscuro(col),
        letterSpacing: 0.05,
        height: 1.05,
      );

  static int columnaParaValor(int indice, int totalValores) =>
      CataV4Theme.columnaParaValor(indice, totalValores);
}
