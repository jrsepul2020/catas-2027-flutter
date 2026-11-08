import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_resumen_v2.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v3/cata_v3_theme.dart';
import 'package:virtus2027/features/cata/presentation/v3/grupo_criterios_v3.dart';

/// Ficha V3: fondo azulado, tarjetas blancas, cabecera de calidades única.
class CataFormV3 extends StatelessWidget {
  const CataFormV3({
    super.key,
    required this.ficha,
    required this.scores,
    required this.readOnly,
    required this.onScoreChanged,
    required this.totalActual,
    required this.faltanCriterios,
    required this.criteriosCompletos,
    required this.codigoMuestra,
    required this.categoriaNombre,
    required this.guardando,
    required this.fichaCompleta,
    required this.onEnviar,
    this.umbrales = MedallaUmbrales.defecto,
    this.criteriosResaltados = const {},
    this.idCriterioUnicoPendiente,
    this.nombreCriterioUnicoPendiente,
    this.onReiniciar,
    this.onDescartar,
    this.bannerEnvio,
    this.selectorVersion,
  });

  final FichaDefinicion ficha;
  final Map<String, num> scores;
  final bool readOnly;
  final void Function(String criterioId, num value) onScoreChanged;
  final double totalActual;
  final int faltanCriterios;
  final int criteriosCompletos;
  final String codigoMuestra;
  final String categoriaNombre;
  final bool guardando;
  final bool fichaCompleta;
  final VoidCallback onEnviar;
  final MedallaUmbrales umbrales;
  final Set<String> criteriosResaltados;
  final String? idCriterioUnicoPendiente;
  final String? nombreCriterioUnicoPendiente;
  final VoidCallback? onReiniciar;
  final VoidCallback? onDescartar;
  final String? bannerEnvio;
  final Widget? selectorVersion;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CataV3Theme.fondo,
      child: Padding(
        padding: const EdgeInsets.all(CataV2Theme.paddingForm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
                        child: CabeceraCalidadesV3(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                          child: Column(
                            children: [
                              for (final grupo in ficha.grupos)
                                Expanded(
                                  flex: grupo.criterios.length,
                                  child: GrupoCriteriosV3(
                                    grupo: grupo,
                                    scores: scores,
                                    readOnly: readOnly,
                                    criteriosResaltados: criteriosResaltados,
                                    idCriterioUnicoPendiente:
                                        idCriterioUnicoPendiente,
                                    onScoreChanged: onScoreChanged,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectorVersion != null)
                    Positioned(
                      top: 2,
                      right: 8,
                      child: selectorVersion!,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: CataV2Theme.anchoResumen,
              child: CataResumenV2(
                totalActual: totalActual,
                totalMin: ficha.totalMin,
                totalMax: ficha.totalMax,
                umbrales: umbrales,
                faltanCriterios: faltanCriterios,
                criteriosCompletos: criteriosCompletos,
                criteriosTotal: ficha.todosLosCriterios.length,
                codigoMuestra: codigoMuestra,
                categoriaNombre: categoriaNombre,
                nombreCriterioUnicoPendiente: nombreCriterioUnicoPendiente,
                readOnly: readOnly,
                guardando: guardando,
                fichaCompleta: fichaCompleta,
                onEnviar: onEnviar,
                onReiniciar: onReiniciar,
                onDescartar: onDescartar,
                bannerEnvio: bannerEnvio,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
