import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/theme/virtus_system_ui.dart';

/// Encapsula la UI en el canvas 1003×627 y escala de forma uniforme si la
/// pantalla física difiere (p. ej. al probar en Chrome).
///
/// En una ZTE a 1003×627 nativos el factor de escala es 1 (sin bordes).
class TabletViewport extends StatelessWidget {
  const TabletViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kVirtusSystemUi,
      child: ColoredBox(
        color: const Color(0xFF121212),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: TabletLayout.width,
                  height: TabletLayout.height,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: TabletLayout.size,
                    ),
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
