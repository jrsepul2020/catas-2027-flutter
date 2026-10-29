import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';

abstract final class TabletTheme {
  /// Estilo base sin subrayado, compatible con TextStyle.lerp de Material.
  static const TextStyle sinSubrayado = TextStyle(
    inherit: false,
    decoration: TextDecoration.none,
    decorationThickness: 0,
    decorationColor: Colors.transparent,
  );

  static ThemeData build() {
    const seed = VirtusColors.primario;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      primary: VirtusColors.primario,
      secondary: VirtusColors.secundario,
      surface: Colors.white,
    );

    TextStyle baseStyle({
      required double fontSize,
      required FontWeight fontWeight,
      required Color color,
    }) {
      return TextStyle(
        inherit: false,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: TextDecoration.none,
        decorationThickness: 0,
        decorationColor: Colors.transparent,
      );
    }

    final overrides = TextTheme(
      displayLarge: baseStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: VirtusColors.primario,
      ),
      displayMedium: baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: VirtusColors.primario,
      ),
      displaySmall: baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: VirtusColors.primario,
      ),
      headlineLarge: baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: VirtusColors.primario,
      ),
      headlineMedium: baseStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: VirtusColors.primario,
      ),
      headlineSmall: baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: VirtusColors.secundario,
      ),
      titleLarge: baseStyle(
        fontSize: TabletLayout.titleFontSize,
        fontWeight: FontWeight.w700,
        color: VirtusColors.primario,
      ),
      titleMedium: baseStyle(
        fontSize: TabletLayout.slotNameFontSize,
        fontWeight: FontWeight.w700,
        color: VirtusColors.primario,
      ),
      titleSmall: baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: VirtusColors.secundario,
      ),
      bodyLarge: baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseStyle(
        fontSize: TabletLayout.errorBodyFontSize,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodySmall: baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: baseStyle(
        fontSize: TabletLayout.slotNumberFontSize,
        fontWeight: FontWeight.w600,
        color: VirtusColors.secundario,
      ),
      labelMedium: baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: VirtusColors.secundario,
      ),
      labelSmall: baseStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: VirtusColors.secundario,
      ),
    );

    final textTheme = Typography.material2021(platform: TargetPlatform.android)
        .black
        .merge(overrides)
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: VirtusColors.primario,
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: VirtusColors.fondoSuave,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: const IconThemeData(
        color: VirtusColors.primario,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: VirtusColors.primario,
        foregroundColor: Colors.white,
        titleTextStyle: baseStyle(
          fontSize: TabletLayout.titleFontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
