import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_resumen_v2.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v2/grupo_criterios_v2.dart';

/// Cuerpo de la ficha V2: criterios (izq) + resumen (der).
class CataFormV2 extends StatelessWidget {
  const CataFormV2({
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
      color: CataV2Theme.fondo,
      child: Padding(
        padding: const EdgeInsets.all(CataV2Theme.paddingForm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: CataV2Theme.superficie,
                  borderRadius: BorderRadius.circular(CataV2Theme.radio),
                  border: Border.all(color: CataV2Theme.borde),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CataV2Theme.radio - 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (selectorVersion != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: selectorVersion!,
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            children: [
                              for (final grupo in ficha.grupos)
                                Expanded(
                                  flex: grupo.criterios.length,
                                  child: GrupoCriteriosV2(
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
                ),
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
