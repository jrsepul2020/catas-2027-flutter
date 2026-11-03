import 'package:flutter/material.dart';
import 'package:virtus2027/config/app_build_info.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';

/// Etiqueta de versión muy discreta (junto al botón actualizar).
class AppVersionLabel extends StatelessWidget {
  const AppVersionLabel({
    super.key,
    this.onDark = false,
  });

  /// `true` sobre cabeceras con fondo de color (texto blanco semitransparente).
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.35);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        AppBuildInfo.label,
        style: VirtusTextStyles.plain(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}
