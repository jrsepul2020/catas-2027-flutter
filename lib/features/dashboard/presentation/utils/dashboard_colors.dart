import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';

abstract final class DashboardColors {
  static Color primario(String? hex) => VirtusColors.primarioUi(hex);

  static Color oscuro(Color base) => VirtusColors.oscuroDe(base);

  static Color medio(Color base) => VirtusColors.medioDe(base);

  static Color claro(Color base) => VirtusColors.claroDe(base);

  static Color pillActiva(Color base) => VirtusColors.pillActivaDe(base);
}
