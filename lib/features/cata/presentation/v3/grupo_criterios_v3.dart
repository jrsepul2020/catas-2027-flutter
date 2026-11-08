import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v3/cata_v3_theme.dart';
import 'package:virtus2027/features/cata/presentation/v3/criterio_botones_v3.dart';

/// Grupo V3: tarjeta blanca sobre fondo azulado (sin cabecera de calidades).
class GrupoCriteriosV3 extends StatelessWidget {
  const GrupoCriteriosV3({
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

    return Padding(
      padding: const EdgeInsets.only(bottom: CataV3Theme.huecoGrupos),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CataV3Theme.tarjeta,
          borderRadius: BorderRadius.circular(CataV3Theme.radioTarjeta),
          border: Border.all(color: CataV3Theme.bordeTarjeta),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A2540).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: CataV2Theme.anchoBandaGrupo + 2,
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
                          color: CataV3Theme.divisorCriterioPuntos,
                        ),
                      Expanded(
                        child: _buildCriterio(grupo.criterios[i]),
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

  Widget _buildCriterio(FichaCriterio criterio) {
    final completado = scores.containsKey(criterio.id);
    if (!criterio.usaBotonesEnFila) {
      return Text(
        'Criterio no configurado: ${criterio.label}',
        style: CataV2Theme.text(fontSize: 11),
      );
    }

    return CriterioBotonesV3(
      label: criterio.label,
      valores: criterio.valoresDisponibles,
      valorSeleccionado: scores[criterio.id]?.round(),
      completado: completado,
      readOnly: readOnly,
      resaltarPendiente: criteriosResaltados.contains(criterio.id),
      pulsarUnicoPendiente: idCriterioUnicoPendiente == criterio.id,
      totalColumnas: criterio.columnasBotones ?? CataV3Theme.columnas,
      onSelected: (value) => onScoreChanged(criterio.id, value),
    );
  }
}

/// Cabecera única de calidades (alineada con la columna de puntos).
class CabeceraCalidadesV3 extends StatelessWidget {
  const CabeceraCalidadesV3({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
      child: Row(
        children: [
          SizedBox(width: CataV2Theme.anchoBandaGrupo + 2),
          SizedBox(width: CataV3Theme.anchoColumnaCriterios),
          const SizedBox(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  for (var c = 0; c < CataV3Theme.columnas; c++) ...[
                    if (c > 0) const SizedBox(width: CataV3Theme.huecoBotones),
                    Expanded(
                      child: Text(
                        CataV3Theme.etiquetasCalidad[c],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CataV3Theme.etiquetaCalidadStyle(c),
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
