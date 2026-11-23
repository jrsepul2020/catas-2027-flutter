import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5/cata_v5_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5/criterio_botones_v5.dart';

class GrupoCriteriosV5 extends StatelessWidget {
  const GrupoCriteriosV5({
    super.key,
    required this.grupo,
    required this.scores,
    required this.readOnly,
    required this.onScoreChanged,
    this.criteriosResaltados = const {},
    this.estiloBotones = CataBotonesEstiloV5.pastel,
  });

  final FichaGrupo grupo;
  final Map<String, num> scores;
  final bool readOnly;
  final void Function(String criterioId, num value) onScoreChanged;
  final Set<String> criteriosResaltados;
  final CataBotonesEstiloV5 estiloBotones;

  @override
  Widget build(BuildContext context) {
    final estilo = CataV2Theme.estiloGrupo(grupo.nombre);

    return Padding(
      padding: const EdgeInsets.only(bottom: CataV5Theme.gapGrupos),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CataV5Theme.tarjeta,
          borderRadius: BorderRadius.circular(CataV5Theme.radioTarjeta),
          border: Border.all(color: CataV5Theme.borde, width: 1),
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
              width: CataV5Theme.anchoBanda,
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
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 6, 2),
                child: Column(
                  children: [
                    for (var i = 0; i < grupo.criterios.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          color: CataV5Theme.borde.withValues(alpha: 0.85),
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
    return CriterioBotonesV5(
      label: c.label,
      valores: c.valoresDisponibles,
      valorSeleccionado: scores[c.id]?.round(),
      readOnly: readOnly,
      resaltarPendiente: criteriosResaltados.contains(c.id),
      estiloBotones: estiloBotones,
      onSelected: (v) => onScoreChanged(c.id, v),
    );
  }
}

/// Cabecera de niveles OIV (colores de siempre).
class CabeceraNivelesV5 extends StatelessWidget {
  const CabeceraNivelesV5({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const SizedBox(width: CataV5Theme.anchoBanda),
          SizedBox(
            width: CataV5Theme.anchoEtiqueta + CataV5Theme.huecoEtiquetaPuntos,
          ),
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < CataV5Theme.columnas; c++) ...[
                  if (c > 0) const SizedBox(width: CataV5Theme.huecoBotones),
                  Expanded(
                    child: Align(
                      child: FractionallySizedBox(
                        widthFactor: CataV5Theme.factorAnchoBoton,
                        child: SizedBox(
                          height: 22,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CataV5Theme.etiquetas[c],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              softWrap: false,
                              style: CataV5Theme.etiquetaNivel(c),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
