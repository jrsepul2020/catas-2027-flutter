import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/cata_v4_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/criterio_botones_v4.dart';

class GrupoCriteriosV4 extends StatelessWidget {
  const GrupoCriteriosV4({
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
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CataV4Theme.tarjeta,
          borderRadius: BorderRadius.circular(CataV4Theme.radioTarjeta),
          border: Border.all(color: CataV4Theme.borde),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: CataV4Theme.anchoBanda,
              decoration: BoxDecoration(
                color: estilo.banda,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(9),
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
                          color: CataV4Theme.borde.withValues(alpha: 0.7),
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
    return CriterioBotonesV4(
      label: c.label,
      valores: c.valoresDisponibles,
      valorSeleccionado: scores[c.id]?.round(),
      readOnly: readOnly,
      resaltarPendiente: criteriosResaltados.contains(c.id),
      onSelected: (v) => onScoreChanged(c.id, v),
    );
  }
}

/// Cabecera única de niveles (siempre visible arriba, texto entero).
class CabeceraNivelesV4 extends StatelessWidget {
  const CabeceraNivelesV4({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: CataV4Theme.anchoBanda),
          SizedBox(
            width: CataV4Theme.anchoEtiqueta + CataV4Theme.huecoEtiquetaPuntos,
          ),
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < CataV4Theme.columnas; c++) ...[
                  if (c > 0) const SizedBox(width: CataV4Theme.huecoBotones),
                  Expanded(
                    child: SizedBox(
                      height: 22,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CataV4Theme.etiquetas[c],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: CataV4Theme.etiquetaNivel(c),
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
