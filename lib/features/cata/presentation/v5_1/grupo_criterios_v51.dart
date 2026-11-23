import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_v51_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/criterio_botones_v51.dart';

class GrupoCriteriosV51 extends StatelessWidget {
  const GrupoCriteriosV51({
    super.key,
    required this.grupo,
    required this.scores,
    required this.readOnly,
    required this.onScoreChanged,
    this.criteriosResaltados = const {},
  });

  final FichaGrupo grupo;
  final Map<String, num> scores;
  final bool readOnly;
  final void Function(String criterioId, num value) onScoreChanged;
  final Set<String> criteriosResaltados;

  @override
  Widget build(BuildContext context) {
    final estilo = CataV2Theme.estiloGrupo(grupo.nombre);

    return Padding(
      padding: const EdgeInsets.only(bottom: CataV51Theme.huecoGrupos),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CataV51Theme.tarjeta,
          borderRadius: BorderRadius.circular(CataV51Theme.radioTarjeta),
          border: Border.all(color: CataV51Theme.bordeTarjeta),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: CataV51Theme.anchoBanda,
              decoration: BoxDecoration(
                color: estilo.banda,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(11),
                ),
              ),
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    grupo.nombre.toUpperCase(),
                    style: CataV2Theme.text(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < grupo.criterios.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: CataV51Theme.divisor,
                        ),
                      Expanded(child: _criterio(grupo.criterios[i])),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _criterio(FichaCriterio c) {
    if (!c.usaBotonesEnFila) {
      return Text(c.label, style: CataV2Theme.text(fontSize: 12));
    }
    return CriterioBotonesV51(
      label: c.label,
      valores: c.valoresDisponibles,
      valorSeleccionado: scores[c.id]?.round(),
      completado: scores.containsKey(c.id),
      readOnly: readOnly,
      resaltarPendiente: criteriosResaltados.contains(c.id),
      onSelected: (v) => onScoreChanged(c.id, v),
    );
  }
}

/// Cabecera EXCELENTE…INSUFICIENTE alineada con columnas de puntos.
class CabeceraNivelesV51 extends StatelessWidget {
  const CabeceraNivelesV51({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: CataV51Theme.anchoBanda),
          SizedBox(width: CataV51Theme.anchoColumnaCriterios),
          SizedBox(width: CataV51Theme.anchoCheckColumna),
          const SizedBox(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  for (var c = 0; c < CataV51Theme.columnas; c++) ...[
                    if (c > 0)
                      const SizedBox(width: CataV51Theme.huecoBotones),
                    Expanded(
                      child: Text(
                        CataV51Theme.etiquetas[c],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: CataV51Theme.etiquetaNivel(c),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
