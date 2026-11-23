import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_v51_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/piezas_v51.dart';

/// Fila V5.1 tablet: nombre (2 líneas) | check | botones.
class CriterioBotonesV51 extends StatelessWidget {
  const CriterioBotonesV51({
    super.key,
    required this.label,
    required this.valores,
    required this.valorSeleccionado,
    required this.completado,
    required this.onSelected,
    this.readOnly = false,
    this.resaltarPendiente = false,
  });

  final String label;
  final List<int> valores;
  final int? valorSeleccionado;
  final bool completado;
  final ValueChanged<int>? onSelected;
  final bool readOnly;
  final bool resaltarPendiente;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final btnH = maxH.isFinite && maxH > 0
            ? (maxH - 6).clamp(
                CataV51Theme.alturaBotonMin,
                CataV51Theme.alturaBotonMax,
              )
            : CataV51Theme.alturaBotonMin;

        final gap = _huecoParaAncho(constraints.maxWidth);

        return AnimatedContainer(
          duration: CataV2Theme.animSeleccion,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: resaltarPendiente
                  ? CataV2Theme.acentoPendiente
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: CataV51Theme.anchoColumnaCriterios,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: CataV2Theme.text(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: CataV51Theme.texto,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: CataV51Theme.anchoCheckColumna,
                child: Center(child: CheckCriterioV51(completado: completado)),
              ),
              Container(width: 1, color: CataV51Theme.divisor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.center,
                    child: BotonesPuntuacionFilaV51(
                      valores: valores,
                      valorSeleccionado: valorSeleccionado,
                      height: btnH,
                      gap: gap,
                      readOnly: readOnly,
                      onSelected: onSelected,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _huecoParaAncho(double rowWidth) {
    final puntosApprox = rowWidth -
        CataV51Theme.anchoColumnaCriterios -
        CataV51Theme.anchoCheckColumna -
        1 -
        16;
    if (puntosApprox < 320) return CataV51Theme.huecoBotonesMin;
    if (puntosApprox < 380) return 6;
    return CataV51Theme.huecoBotones;
  }
}

/// Criterio móvil: nombre + check arriba; botones debajo a todo el ancho.
class CriterioBotonesV51Movil extends StatelessWidget {
  const CriterioBotonesV51Movil({
    super.key,
    required this.label,
    required this.valores,
    required this.valorSeleccionado,
    required this.completado,
    required this.onSelected,
    this.readOnly = false,
    this.resaltarPendiente = false,
  });

  final String label;
  final List<int> valores;
  final int? valorSeleccionado;
  final bool completado;
  final ValueChanged<int>? onSelected;
  final bool readOnly;
  final bool resaltarPendiente;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: CataV2Theme.animSeleccion,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resaltarPendiente
              ? CataV2Theme.acentoPendiente
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: CataV2Theme.text(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CataV51Theme.texto,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CheckCriterioV51(completado: completado),
            ],
          ),
          const SizedBox(height: 8),
          BotonesPuntuacionFilaV51(
            valores: valores,
            valorSeleccionado: valorSeleccionado,
            height: 44,
            gap: CataV51Theme.huecoBotones,
            readOnly: readOnly,
            onSelected: onSelected,
            maxAnchoBoton: double.infinity,
          ),
        ],
      ),
    );
  }
}
