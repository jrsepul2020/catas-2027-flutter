import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5/cata_v5_theme.dart';

/// Fila de criterio V5: check + etiqueta una línea + 5 columnas.
class CriterioBotonesV5 extends StatelessWidget {
  const CriterioBotonesV5({
    super.key,
    required this.label,
    required this.valores,
    required this.valorSeleccionado,
    required this.onSelected,
    this.readOnly = false,
    this.resaltarPendiente = false,
    this.estiloBotones = CataBotonesEstiloV5.pastel,
  });

  final String label;
  final List<int> valores;
  final int? valorSeleccionado;
  final ValueChanged<int>? onSelected;
  final bool readOnly;
  final bool resaltarPendiente;
  final CataBotonesEstiloV5 estiloBotones;

  @override
  Widget build(BuildContext context) {
    final puntuado = valorSeleccionado != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final btnH = maxH.isFinite && maxH > 0
            ? (maxH - 6).clamp(CataV5Theme.alturaBotonMin, 56.0)
            : CataV5Theme.alturaBotonMin;

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
                width: CataV5Theme.anchoEtiqueta,
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: puntuado
                          ? const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Color(0xFF2E7D32),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: CataV2Theme.text(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: CataV5Theme.texto,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CataV5Theme.huecoEtiquetaPuntos),
              Expanded(child: _grid(btnH)),
            ],
          ),
        );
      },
    );
  }

  Widget _grid(double btnH) {
    final slots =
        List<({int valor, int col})?>.filled(CataV5Theme.columnas, null);
    for (var i = 0; i < valores.length; i++) {
      final col = CataV5Theme.columnaParaValor(i, valores.length);
      slots[col] = (valor: valores[i], col: col);
    }

    return Row(
      children: [
        for (var c = 0; c < CataV5Theme.columnas; c++) ...[
          if (c > 0) const SizedBox(width: CataV5Theme.huecoBotones),
          Expanded(
            child: slots[c] == null
                ? const SizedBox.shrink()
                : Align(
                    child: FractionallySizedBox(
                      widthFactor: CataV5Theme.factorAnchoBoton,
                      child: _BotonNivel(
                        valor: slots[c]!.valor,
                        columna: slots[c]!.col,
                        selected: valorSeleccionado == slots[c]!.valor,
                        height: btnH,
                        estilo: estiloBotones,
                        onTap: readOnly
                            ? null
                            : () => onSelected?.call(slots[c]!.valor),
                      ),
                    ),
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
    required this.estilo,
    this.onTap,
  });

  final int valor;
  final int columna;
  final bool selected;
  final double height;
  final CataBotonesEstiloV5 estilo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color borderColor;
    final Color fg;

    if (estilo == CataBotonesEstiloV5.pastel) {
      bg = selected
          ? CataV5Theme.oscuro(columna)
          : CataV5Theme.claro(columna);
      borderColor = selected
          ? CataV5Theme.oscuro(columna)
          : CataV5Theme.bordeClaro(columna);
      fg = selected ? Colors.white : Colors.black;
    } else {
      bg = selected
          ? CataV5Theme.oscuro(columna)
          : CataV5Theme.botonIdleFondo;
      borderColor = CataV5Theme.oscuro(columna);
      fg = selected ? Colors.white : CataV5Theme.numeroIdle;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CataV5Theme.radioBoton),
        child: AnimatedContainer(
          duration: CataV2Theme.animSeleccion,
          curve: Curves.easeOut,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(CataV5Theme.radioBoton),
            border: Border.all(
              color: borderColor,
              width: CataV5Theme.bordeBoton,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color:
                          CataV5Theme.oscuro(columna).withValues(alpha: 0.28),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Text(
            '$valor',
            style: CataV2Theme.text(
              fontSize: CataV5Theme.tamanoNumero,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
