import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';

abstract final class TabletTheme {
  static ThemeData build() {
    const seed = Color(0xFF1E3A5F);
    final colorScheme = ColorScheme.fromSeed(seedColor: seed);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: TabletLayout.titleFontSize,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: TabletLayout.slotNameFontSize,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        labelLarge: TextStyle(
          fontSize: TabletLayout.slotNumberFontSize,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
        bodyMedium: TextStyle(
          fontSize: TabletLayout.errorBodyFontSize,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
