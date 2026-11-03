import 'package:flutter/material.dart';

/// Estilos de texto sin subrayado, compatibles con Flutter Web y TextStyle.lerp.
abstract final class VirtusTextStyles {
  static TextStyle plain({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    String? fontFamily,
  }) {
    return TextStyle(
      inherit: false,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      fontFamily: fontFamily,
      decoration: TextDecoration.none,
      decorationThickness: 0,
      decorationColor: Colors.transparent,
      decorationStyle: TextDecorationStyle.solid,
    );
  }

  static TextSpan span({
    required String text,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    String? fontFamily,
  }) {
    return TextSpan(
      text: text,
      style: plain(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        fontFamily: fontFamily,
      ),
    );
  }
}
