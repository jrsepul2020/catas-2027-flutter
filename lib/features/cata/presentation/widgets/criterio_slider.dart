import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/widgets/criterio_botones.dart';

/// Criterio con rango min–max renderizado como fila de botones (estilo tablet).
class CriterioSlider extends StatelessWidget {
  const CriterioSlider({
    super.key,
    required this.label,
    required this.min,
    required this.max,
    required this.value,
    required this.completado,
    required this.onChanged,
    this.readOnly = false,
    this.fillWidth = false,
  });

  final String label;
  final int min;
  final int max;
  final int value;
  final bool completado;
  final ValueChanged<int>? onChanged;
  final bool readOnly;
  final bool fillWidth;

  @override
  Widget build(BuildContext context) {
    final valores = List.generate(max - min + 1, (i) => max - i);

    return CriterioBotones(
      label: label,
      valores: valores,
      valorSeleccionado: value,
      completado: completado,
      readOnly: readOnly,
      fillWidth: fillWidth,
      onSelected: onChanged,
    );
  }
}
