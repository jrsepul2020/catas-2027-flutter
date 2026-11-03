import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virtus2027/core/theme/virtus_system_ui.dart';

/// Relleno superior para que el contenido no quede bajo la barra de estado.
/// Fuerza iconos claros (hora, batería, wifi) sobre cabeceras oscuras.
class StatusBarSpacer extends StatelessWidget {
  const StatusBarSpacer({
    super.key,
    required this.color,
    this.iconosClaros = true,
  });

  final Color color;
  final bool iconosClaros;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bar = ColoredBox(
      color: color,
      child: top <= 0 ? const SizedBox.shrink() : SizedBox(height: top),
    );

    if (!iconosClaros) return bar;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kVirtusSystemUi,
      child: bar,
    );
  }
}