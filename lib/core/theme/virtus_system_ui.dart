import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Iconos claros (hora, wifi, batería) sobre cabecera verde corporativa.
///
/// En Flutter, [SystemUiOverlayStyle.dark] implica fondo de barra oscuro
/// e iconos claros — el nombre es confuso respecto al color de los iconos.
const SystemUiOverlayStyle kVirtusSystemUi = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0xFF1B4332),
  systemNavigationBarIconBrightness: Brightness.light,
);
