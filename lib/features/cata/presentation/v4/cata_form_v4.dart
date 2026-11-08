import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v4/cata_resumen_v4.dart';
import 'package:virtus2027/features/cata/presentation/v4/cata_v4_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/grupo_criterios_v4.dart';

/// Cuerpo de la ficha V4: criterios (izq) + resumen (der). Sin scroll.
class CataFormV4 extends StatelessWidget {
  const CataFormV4({
    super.key,
    required this.ficha,
    required this.scores,
    required this.readOnly,
    required this.onScoreChanged,
    required this.totalActual,
    required this.criteriosCompletos,
    required this.codigoMuestra,
    required this.categoriaNombre,
    required this.guardando,
    required this.fichaCompleta,
    required this.onEnviar,
    this.umbrales = MedallaUmbrales.defecto,
    this.criteriosResaltados = const {},
    this.onReiniciar,
    this.onIncidencia,
    this.bannerEnvio,
    this.selectorVersion,
  });

  final FichaDefinicion ficha;
  final Map<String, num> scores;
  final bool readOnly;
  final void Function(String criterioId, num value) onScoreChanged;
  final double totalActual;
  final int criteriosCompletos;
  final String codigoMuestra;
  final String categoriaNombre;
  final bool guardando;
  final bool fichaCompleta;
  final VoidCallback onEnviar;
  final MedallaUmbrales umbrales;
  final Set<String> criteriosResaltados;
  final VoidCallback? onReiniciar;
  final VoidCallback? onIncidencia;
  final String? bannerEnvio;
  /// Solo esModoPruebas: se muestra en el panel de puntuación (no en la ficha).
  final Widget? selectorVersion;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CataV4Theme.fondo,
      child: Padding(
        // El margen del panel lateral lo aporta CataResumenV4 (12 px).
        padding: const EdgeInsets.fromLTRB(6, 4, 0, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CabeceraNivelesV4(),
                  Expanded(
                    child: Column(
                      children: [
                        for (final grupo in ficha.grupos)
                          Expanded(
                            flex: grupo.criterios.length,
                            child: GrupoCriteriosV4(
                              grupo: grupo,
                              scores: scores,
                              readOnly: readOnly,
                              criteriosResaltados: criteriosResaltados,
                              onScoreChanged: onScoreChanged,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: CataV4Theme.anchoResumen,
              child: CataResumenV4(
                totalActual: totalActual,
                totalMin: ficha.totalMin,
                totalMax: ficha.totalMax,
                umbrales: umbrales,
                criteriosCompletos: criteriosCompletos,
                criteriosTotal: ficha.todosLosCriterios.length,
                codigoMuestra: codigoMuestra,
                categoriaNombre: categoriaNombre,
                readOnly: readOnly,
                guardando: guardando,
                fichaCompleta: fichaCompleta,
                onEnviar: onEnviar,
                onReiniciar: onReiniciar,
                onIncidencia: onIncidencia,
                bannerEnvio: bannerEnvio,
                selectorVersion: selectorVersion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
