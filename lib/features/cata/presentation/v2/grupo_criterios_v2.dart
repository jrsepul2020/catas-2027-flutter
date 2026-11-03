import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v2/criterio_botones_v2.dart';

/// Grupo sensorial de la ficha V2 (banda de color + criterios).
class GrupoCriteriosV2 extends StatelessWidget {
  const GrupoCriteriosV2({
    super.key,
    required this.grupo,
    required this.scores,
    required this.readOnly,
    required this.onScoreChanged,
    this.criteriosResaltados = const {},
    this.idCriterioUnicoPendiente,
  });

  final FichaGrupo grupo;
  final Map<String, num> scores;
  final bool readOnly;
  final void Function(String criterioId, num value) onScoreChanged;
  final Set<String> criteriosResaltados;
  final String? idCriterioUnicoPendiente;

  @override
  Widget build(BuildContext context) {
    final estilo = CataV2Theme.estiloGrupo(grupo.nombre);
    final colorSel = CataV2Theme.seleccionadoGrupo(grupo.nombre);

    return Padding(
      padding: const EdgeInsets.only(bottom: CataV2Theme.huecoEntreGrupos),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: estilo.fondo,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: estilo.banda.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: CataV2Theme.anchoBandaGrupo,
              decoration: BoxDecoration(
                color: estilo.banda,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(7),
                ),
              ),
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    grupo.nombre.toUpperCase(),
                    style: CataV2Theme.text(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
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
                          thickness: 1,
                          color: estilo.banda.withValues(alpha: 0.12),
                        ),
                      Expanded(
                        child: _buildCriterio(grupo.criterios[i], colorSel),
                      ),
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

  Widget _buildCriterio(FichaCriterio criterio, Color colorSel) {
    final completado = scores.containsKey(criterio.id);
    if (!criterio.usaBotonesEnFila) {
      return Text(
        'Criterio no configurado: ${criterio.label}',
        style: CataV2Theme.text(fontSize: 11),
      );
    }

    return CriterioBotonesV2(
      label: criterio.label,
      valores: criterio.valoresDisponibles,
      valorSeleccionado: scores[criterio.id]?.round(),
      completado: completado,
      colorSeleccionado: colorSel,
      readOnly: readOnly,
      resaltarPendiente: criteriosResaltados.contains(criterio.id),
      pulsarUnicoPendiente: idCriterioUnicoPendiente == criterio.id,
      totalColumnas: criterio.columnasBotones ?? CataV2Theme.columnasBotones,
      onSelected: (value) => onScoreChanged(criterio.id, value),
    );
  }
}
