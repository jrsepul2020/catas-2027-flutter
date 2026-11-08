import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/cata_v4_theme.dart';

/// Fila de criterio V4: etiqueta + 5 columnas (sin check).
class CriterioBotonesV4 extends StatelessWidget {
  const CriterioBotonesV4({
    super.key,
    required this.label,
    required this.valores,
    required this.valorSeleccionado,
    required this.onSelected,
    this.readOnly = false,
    this.resaltarPendiente = false,
  });

  final String label;
  final List<int> valores;
  final int? valorSeleccionado;
  final ValueChanged<int>? onSelected;
  final bool readOnly;
  final bool resaltarPendiente;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final btnH = maxH.isFinite && maxH > 0
            ? (maxH - 6).clamp(CataV4Theme.alturaBotonMin, 58.0)
            : CataV4Theme.alturaBotonMin;

        return AnimatedContainer(
          duration: CataV2Theme.animSeleccion,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: resaltarPendiente
                  ? CataV2Theme.acentoPendiente
                  : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Row(
            children: [
              SizedBox(
                width: CataV4Theme.anchoEtiqueta,
                child: Text(
                  label,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                  style: CataV2Theme.text(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CataV4Theme.texto,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: CataV4Theme.huecoEtiquetaPuntos),
              Expanded(child: _grid(btnH)),
            ],
          ),
        );
      },
    );
  }

  Widget _grid(double btnH) {
    final slots =
        List<({int valor, int col})?>.filled(CataV4Theme.columnas, null);
    for (var i = 0; i < valores.length; i++) {
      final col = CataV4Theme.columnaParaValor(i, valores.length);
      slots[col] = (valor: valores[i], col: col);
    }

    return Row(
      children: [
        for (var c = 0; c < CataV4Theme.columnas; c++) ...[
          if (c > 0) const SizedBox(width: CataV4Theme.huecoBotones),
          Expanded(
            child: slots[c] == null
                ? const SizedBox.shrink()
                : _BotonNivel(
                    valor: slots[c]!.valor,
                    columna: slots[c]!.col,
                    selected: valorSeleccionado == slots[c]!.valor,
                    height: btnH,
                    onTap: readOnly
                        ? null
                        : () => onSelected?.call(slots[c]!.valor),
                  ),
          ),
        ],
      ],
    );
  }
}

class _BotonNivel extends StatelessWidget {
  const _BotonNivel({
    required this.valor,
    required this.columna,
    required this.selected,
    required this.height,
    this.onTap,
  });

  final int valor;
  final int columna;
  final bool selected;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg =
        selected ? CataV4Theme.oscuro(columna) : CataV4Theme.claro(columna);
    final borderColor = selected
        ? CataV4Theme.oscuro(columna)
        : CataV4Theme.bordeClaro(columna);
    final fg = selected ? Colors.white : Colors.black;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CataV4Theme.radioBoton),
        child: AnimatedContainer(
          duration: CataV2Theme.animSeleccion,
          curve: Curves.easeOut,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(CataV4Theme.radioBoton),
            border: Border.all(
              color: borderColor,
              width: CataV4Theme.bordeBoton,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: CataV4Theme.oscuro(columna).withValues(alpha: 0.32),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            '$valor',
            style: CataV2Theme.text(
              fontSize: CataV4Theme.tamanoNumero,
              fontWeight: FontWeight.w800,
              color: fg,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
