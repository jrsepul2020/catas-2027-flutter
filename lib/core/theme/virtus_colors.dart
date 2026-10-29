import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';

/// Paleta verde Virtus — tonalidades para toda la UI de tablet.
abstract final class VirtusColors {
  static const primario = Color(0xFF1B4332);
  static const secundario = Color(0xFF2D6A4F);
  static const medio = Color(0xFF40916C);
  static const claro = Color(0xFF52B788);
  static const muyClaro = Color(0xFF95D5B2);
  static const fondoSuave = Color(0xFFD8F3DC);
  static const oscuro = Color(0xFF081C15);
  static const botonNeutro = Color(0xFF3D5A45);

  static Color primarioUi(String? _) => primario;

  static Color oscuroDe(Color _) => oscuro;

  static Color medioDe(Color _) => secundario;

  static Color claroDe(Color _) => fondoSuave;

  static Color pillActivaDe(Color _) => muyClaro;

  /// Estilo de título sin subrayado (evita artefactos en web).
  static TextStyle titulo({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    return VirtusTextStyles.plain(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? primario,
    );
  }

  /// Combina un estilo con la regla global sin subrayado.
  static TextStyle sinSubrayadoDe(TextStyle style) {
    return TextStyle(
      inherit: false,
      decoration: TextDecoration.none,
      decorationThickness: 0,
      decorationColor: Colors.transparent,
    ).merge(style);
  }
}
