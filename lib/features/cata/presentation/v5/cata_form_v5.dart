import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v5/cata_resumen_v5.dart';
import 'package:virtus2027/features/cata/presentation/v5/cata_v5_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5/grupo_criterios_v5.dart';

/// Cuerpo de la ficha V5 (vinos): criterios (izq) + resumen (der). Sin scroll.
class CataFormV5 extends StatelessWidget {
  const CataFormV5({
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
    this.onIncidencia,
    this.bannerEnvio,
    this.selectorVersion,
    this.estiloBotones = CataBotonesEstiloV5.pastel,
    this.onEstiloBotonesChanged,
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
  final VoidCallback? onIncidencia;
  final String? bannerEnvio;
  final Widget? selectorVersion;
  final CataBotonesEstiloV5 estiloBotones;
  final ValueChanged<CataBotonesEstiloV5>? onEstiloBotonesChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CataV5Theme.fondo,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 0, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CabeceraNivelesV5(),
                  Expanded(
                    child: Column(
                      children: [
                        for (final grupo in ficha.grupos)
                          Expanded(
                            flex: grupo.criterios.length,
                            child: GrupoCriteriosV5(
                              grupo: grupo,
                              scores: scores,
                              readOnly: readOnly,
                              criteriosResaltados: criteriosResaltados,
                              estiloBotones: estiloBotones,
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
              width: CataV5Theme.anchoResumen,
              child: CataResumenV5(
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
                onIncidencia: onIncidencia,
                bannerEnvio: bannerEnvio,
                selectorVersion: selectorVersion,
                estiloBotones: estiloBotones,
                onEstiloBotonesChanged: onEstiloBotonesChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
