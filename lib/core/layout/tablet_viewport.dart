import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';

/// Encapsula la UI en el canvas 1003×627 y escala de forma uniforme si la
/// pantalla física difiere (p. ej. al probar en Chrome).
class TabletViewport extends StatelessWidget {
  const TabletViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF121212),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: TabletLayout.width,
            height: TabletLayout.height,
            child: child,
          ),
        ),
      ),
    );
  }
}
