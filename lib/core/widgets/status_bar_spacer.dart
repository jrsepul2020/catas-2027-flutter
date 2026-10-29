import 'package:flutter/material.dart';

/// Relleno superior para que el contenido no quede bajo la barra de estado.
class StatusBarSpacer extends StatelessWidget {
  const StatusBarSpacer({
    super.key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    if (top <= 0) return const SizedBox.shrink();

    return ColoredBox(
      color: color,
      child: SizedBox(height: top),
    );
  }
}
