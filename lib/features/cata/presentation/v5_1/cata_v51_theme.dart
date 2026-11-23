import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v3/cata_v3_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/cata_v4_theme.dart';

/// V5.1: proporciones V3 + pasteles con encendido/apagado (estilo definitivo).
abstract final class CataV51Theme {
  static const int columnas = CataV3Theme.columnas;
  static const double alturaBotonMin = CataV3Theme.alturaBotonMin;
  static const double alturaBotonMax = CataV3Theme.alturaBotonMax;
  static const double huecoBotones = CataV3Theme.huecoBotones;
  static const double huecoBotonesMin = 4;
  static const double huecoGrupos = CataV3Theme.huecoGrupos;
  static const double anchoColumnaCriterios = CataV3Theme.anchoColumnaCriterios;
  static const double anchoCheckColumna = 28;
  static const double anchoBanda = CataV2Theme.anchoBandaGrupo + 2;
  static const double anchoResumen = CataV2Theme.anchoResumen;
  static const double radioPastilla = CataV3Theme.radioPastilla;
  static const double radioTarjeta = CataV3Theme.radioTarjeta;
  static const double tamanoNumero = 16;
  static const double anchoBotonMax = CataV2Theme.anchoBotonMax;
  static const double anchoCheck = CataV2Theme.anchoCheck;

  static const Color fondo = Color(0xFFF0F3F6);
  static const Color tarjeta = Colors.white;
  static const Color bordeTarjeta = Color(0xFFE5E7EB);
  static const Color divisor = Color(0xFFE2E8F0);
  static const Color texto = Color(0xFF1B1F1B);
  static const Color textoMuted = Color(0xFF6B7280);
  static const Color numeroApagado = Color(0xFF5E6470);
  static const Color rojoTotal = CataV4Theme.rojoTotal;
  static const Color rojoAccion = CataV4Theme.rojoAccion;
  static const Color rojoAccionFondo = CataV4Theme.rojoAccionFondo;
  static const Color rojoAccionBorde = CataV4Theme.rojoAccionBorde;

  static const List<String> etiquetas = CataV4Theme.etiquetas;

  static Color oscuro(int col) => CataV4Theme.oscuro(col);

  /// Pastel de nivel ~35 % menos saturado (apagado legible).
  static Color pastelApagado(int col) {
    final base = CataV4Theme.claro(col);
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withSaturation((hsl.saturation * 0.62).clamp(0.0, 1.0))
        .withLightness((hsl.lightness + 0.04).clamp(0.0, 1.0))
        .toColor();
  }

  static Color bordeApagadoPastel(int col) =>
      Color.lerp(pastelApagado(col), oscuro(col), 0.22)!;

  static TextStyle etiquetaNivel(int col) => CataV2Theme.text(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: oscuro(col),
        letterSpacing: 0.15,
        height: 1.05,
      );

  static int columnaParaValor(int indice, int totalValores) =>
      CataV4Theme.columnaParaValor(indice, totalValores);
}
