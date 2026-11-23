import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_form_v51_movil.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_resumen_v51.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_v51_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/grupo_criterios_v51.dart';

/// Umbral: lado más corto < 600 → disposición móvil vertical.
const double kFichaMovilShortestSideMax = 600;

bool esDisposicionFichaMovil(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide < kFichaMovilShortestSideMax;

/// Ficha V5.1: tablet (horizontal) o móvil (vertical). Solo se construye una.
class CataFormV51 extends StatelessWidget {
  const CataFormV51({
    super.key,
    required this.ficha,
    required this.scores,
    required this.readOnly,
    required this.onScoreChanged,
    required this.totalActual,
    required this.criteriosCompletos,
    required this.categoriaNombre,
    required this.guardando,
    required this.fichaCompleta,
    required this.onEnviar,
    this.umbrales = MedallaUmbrales.defecto,
    this.criteriosResaltados = const {},
    this.onReiniciar,
    this.bannerEnvio,
    this.selectorVersion,
  });

  final FichaDefinicion ficha;
  final Map<String, num> scores;
  final bool readOnly;
  final void Function(String criterioId, num value) onScoreChanged;
  final double totalActual;
  final int criteriosCompletos;
  final String categoriaNombre;
  final bool guardando;
  final bool fichaCompleta;
  final VoidCallback onEnviar;
  final MedallaUmbrales umbrales;
  final Set<String> criteriosResaltados;
  final VoidCallback? onReiniciar;
  final String? bannerEnvio;
  final Widget? selectorVersion;

  @override
  Widget build(BuildContext context) {
    if (esDisposicionFichaMovil(context)) {
      return CataFormV51Movil(
        ficha: ficha,
        scores: scores,
        readOnly: readOnly,
        onScoreChanged: onScoreChanged,
        totalActual: totalActual,
        criteriosCompletos: criteriosCompletos,
        categoriaNombre: categoriaNombre,
        guardando: guardando,
        fichaCompleta: fichaCompleta,
        onEnviar: onEnviar,
        umbrales: umbrales,
        criteriosResaltados: criteriosResaltados,
        onReiniciar: onReiniciar,
        bannerEnvio: bannerEnvio,
        selectorVersion: selectorVersion,
      );
    }
    return _CataFormV51Tablet(
      ficha: ficha,
      scores: scores,
      readOnly: readOnly,
      onScoreChanged: onScoreChanged,
      totalActual: totalActual,
      criteriosCompletos: criteriosCompletos,
      categoriaNombre: categoriaNombre,
      guardando: guardando,
      fichaCompleta: fichaCompleta,
      onEnviar: onEnviar,
      umbrales: umbrales,
      criteriosResaltados: criteriosResaltados,
      onReiniciar: onReiniciar,
      bannerEnvio: bannerEnvio,
      selectorVersion: selectorVersion,
    );
  }
}

class _CataFormV51Tablet extends StatelessWidget {
  const _CataFormV51Tablet({
    required this.ficha,
    required this.scores,
    required this.readOnly,
    required this.onScoreChanged,
    required this.totalActual,
    required this.criteriosCompletos,
    required this.categoriaNombre,
    required this.guardando,
    required this.fichaCompleta,
    required this.onEnviar,
    required this.umbrales,
    required this.criteriosResaltados,
    this.onReiniciar,
    this.bannerEnvio,
    this.selectorVersion,
  });

  final FichaDefinicion ficha;
  final Map<String, num> scores;
  final bool readOnly;
  final void Function(String criterioId, num value) onScoreChanged;
  final double totalActual;
  final int criteriosCompletos;
  final String categoriaNombre;
  final bool guardando;
  final bool fichaCompleta;
  final VoidCallback onEnviar;
  final MedallaUmbrales umbrales;
  final Set<String> criteriosResaltados;
  final VoidCallback? onReiniciar;
  final String? bannerEnvio;
  final Widget? selectorVersion;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CataV51Theme.fondo,
      child: Padding(
        padding: const EdgeInsets.all(CataV2Theme.paddingForm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: CabeceraNivelesV51(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: Column(
                        children: [
                          for (final grupo in ficha.grupos)
                            Expanded(
                              flex: grupo.criterios.length,
                              child: GrupoCriteriosV51(
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
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: CataV51Theme.anchoResumen,
              child: CataResumenV51(
                totalActual: totalActual,
                totalMin: ficha.totalMin,
                totalMax: ficha.totalMax,
                umbrales: umbrales,
                criteriosCompletos: criteriosCompletos,
                criteriosTotal: ficha.todosLosCriterios.length,
                categoriaNombre: categoriaNombre,
                readOnly: readOnly,
                guardando: guardando,
                fichaCompleta: fichaCompleta,
                onEnviar: onEnviar,
                onReiniciar: onReiniciar,
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
