import 'package:flutter/material.dart';

/// Tema visual de la ficha de cata.
abstract final class CataV2Theme {
  // ── Constantes de comportamiento ──────────────────────────────────

  /// Información de administrador en la barra superior.
  static const bool mostrarInfoAdministrador = true;

  /// Texto bajo la medalla dibujada (GRAN ORO / ORO / PLATA).
  static const bool mostrarTextoMedalla = true;

  /// Estilo de botones numéricos NO seleccionados.
  static const EstiloBotonNoSeleccionado estiloBotonNoSeleccionado =
      EstiloBotonNoSeleccionado.oscuro;

  static const double alturaBoton = 44;
  static const double anchoBotonMax = 105;
  static const double huecoBotones = 10;
  static const int columnasBotones = 5;

  /// Barra superior única.
  static const double altoCabecera = 54;

  /// Medalla dibujada (diámetro aproximado).
  static const double tamanoMedalla = 120;

  /// Botón Enviar.
  static const double alturaEnviar = 76;

  static const Duration resaltePendientes = Duration(seconds: 2);
  static const Duration animSeleccion = Duration(milliseconds: 150);
  static const Duration pulsoLento = Duration(milliseconds: 1200);

  // ── Tipografía ────────────────────────────────────────────────────

  static const String fontFamily = 'Inter';

  static TextStyle text({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color color = texto,
    double height = 1.2,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      inherit: false,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // ── Colores ───────────────────────────────────────────────────────

  static const Color cabecera = Color(0xFF1B4332);
  /// Barra superior del dashboard del presidente (azul marino).
  static const Color cabeceraPresidente = Color(0xFF0A2540);
  static const Color fondo = Color(0xFFF4F6F4);
  static const Color superficie = Colors.white;
  static const Color texto = Color(0xFF1B1F1B);
  static const Color textoSecundario = Color(0xFF5A635A);
  static const Color textoMuted = Color(0xFF8A928A);
  static const Color borde = Color(0xFFDDE2DD);
  static const Color acentoPendiente = Color(0xFFF9A825);
  static const Color checkCompleto = Color(0xFF66BB6A);

  static const Color botonNeutroOscuro = Color(0xFF2C3E50);
  static const Color botonNeutroClaro = Color(0xFFEEF1EE);
  static const Color botonNeutroClaroBorde = Color(0xFFC5CDC5);
  static const Color botonEnviar = Color(0xFF2E7D32);
  static const Color botonEnviarDisabled = Color(0xFFCFD5CF);

  /// Fondo pastel para la etiqueta de categoría (p. ej. Vinos tranquilos).
  static Color fondoCategoria(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('espumoso') || n.contains('cava')) {
      return const Color(0xFFE3F2FD);
    }
    if (n.contains('aove') || n.contains('aceite')) {
      return const Color(0xFFF1F8E9);
    }
    if (n.contains('destil') || n.contains('licor')) {
      return const Color(0xFFFFF3E0);
    }
    if (n.contains('tranquilo') || n.contains('vino')) {
      return const Color(0xFFE8F5E9);
    }
    return const Color(0xFFEFEBE9);
  }

  static Color textoCategoria(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('espumoso') || n.contains('cava')) {
      return const Color(0xFF1565C0);
    }
    if (n.contains('aove') || n.contains('aceite')) {
      return const Color(0xFF558B2F);
    }
    if (n.contains('destil') || n.contains('licor')) {
      return const Color(0xFFE65100);
    }
    if (n.contains('tranquilo') || n.contains('vino')) {
      return const Color(0xFF2E7D32);
    }
    return const Color(0xFF5D4037);
  }

  static Color seleccionadoGrupo(String nombreGrupo) {
    final n = nombreGrupo.toLowerCase();
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
    return const Color(0xFFC62828);
  }

  static ({Color fondo, Color banda, Color etiqueta}) estiloGrupo(
    String nombreGrupo,
  ) {
    final n = nombreGrupo.toLowerCase();
    if (n.contains('apariencia') || n.contains('vista')) {
      return (
        fondo: const Color(0xFFFFFDF5),
        banda: const Color(0xFFF9A825),
        etiqueta: const Color(0xFF6D4C0D),
      );
    }
    if (n.contains('olor') || n.contains('olfato')) {
      return (
        fondo: const Color(0xFFFCF8FD),
        banda: const Color(0xFF8E24AA),
        etiqueta: const Color(0xFF6A1B9A),
      );
    }
    if (n.contains('sabor') || n.contains('gusto')) {
      return (
        fondo: const Color(0xFFF6FAF6),
        banda: const Color(0xFF2E7D32),
        etiqueta: const Color(0xFF1B5E20),
      );
    }
    if (n.contains('global') || n.contains('final')) {
      return (
        fondo: const Color(0xFFFFF8F8),
        banda: const Color(0xFFC62828),
        etiqueta: const Color(0xFFB71C1C),
      );
    }
    return (
      fondo: const Color(0xFFFAFAFA),
      banda: const Color(0xFF9E9E9E),
      etiqueta: const Color(0xFF424242),
    );
  }

  static Color get botonNoSeleccionadoFondo {
    switch (estiloBotonNoSeleccionado) {
      case EstiloBotonNoSeleccionado.claro:
        return botonNeutroClaro;
      case EstiloBotonNoSeleccionado.oscuro:
        return botonNeutroOscuro;
    }
  }

  static Color get botonNoSeleccionadoTexto {
    switch (estiloBotonNoSeleccionado) {
      case EstiloBotonNoSeleccionado.claro:
        return texto;
      case EstiloBotonNoSeleccionado.oscuro:
        return Colors.white;
    }
  }

  static Color? get botonNoSeleccionadoBorde {
    switch (estiloBotonNoSeleccionado) {
      case EstiloBotonNoSeleccionado.claro:
        return botonNeutroClaroBorde;
      case EstiloBotonNoSeleccionado.oscuro:
        return null;
    }
  }

  // ── Espaciado ─────────────────────────────────────────────────────

  static const double radio = 10;
  static const double radioBoton = 8;
  static const double anchoResumen = 222;
  static const double anchoBandaGrupo = 24;
  static const double anchoEtiquetaCriterio = 118;
  static const double anchoCheck = 20;
  static const double paddingForm = 6;
  static const double huecoEntreGrupos = 3;
}

enum EstiloBotonNoSeleccionado {
  claro,
  oscuro,
}

/// Variante visual de medalla (solo pintura; umbrales en CataMedalla).
enum CataMedallaVisual {
  ninguna,
  plata,
  oro,
  granOro,
}

extension CataMedallaVisualX on String {
  CataMedallaVisual get aMedallaVisual {
    switch (toUpperCase()) {
      case 'GRAN ORO':
        return CataMedallaVisual.granOro;
      case 'ORO':
        return CataMedallaVisual.oro;
      case 'PLATA':
        return CataMedallaVisual.plata;
      default:
        return CataMedallaVisual.ninguna;
    }
  }
}
