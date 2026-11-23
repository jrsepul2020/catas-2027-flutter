import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/enviar_button_v4.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_v51_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/criterio_botones_v51.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/piezas_v51.dart';

/// Disposición vertical móvil de la ficha V5.1 (reutiliza piezas tablet).
class CataFormV51Movil extends StatelessWidget {
  const CataFormV51Movil({
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
    final criteriosTotal = ficha.todosLosCriterios.length;
    final provisional = !fichaCompleta;

    return ColoredBox(
      color: CataV51Theme.fondo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bloque fijo: total + progreso + medalla/escala.
          Material(
            color: CataV51Theme.tarjeta,
            elevation: 1,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                children: [
                  if (selectorVersion != null) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: selectorVersion!,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    categoriaNombre,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CataV2Theme.text(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CataV51Theme.textoMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TotalMedallaBloqueV51(
                    totalActual: totalActual,
                    totalMin: ficha.totalMin,
                    totalMax: ficha.totalMax,
                    fichaCompleta: fichaCompleta,
                    umbrales: umbrales,
                    compacto: true,
                  ),
                  const SizedBox(height: 8),
                  BarraCriteriosV51(
                    completos: criteriosCompletos,
                    total: criteriosTotal,
                  ),
                  const SizedBox(height: 8),
                  EscalaPremiosV51(
                    total: totalActual,
                    umbrales: umbrales,
                    provisional: provisional,
                  ),
                ],
              ),
            ),
          ),
          // Lista desplazable de grupos/criterios.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              itemCount: ficha.grupos.length,
              itemBuilder: (context, index) {
                final grupo = ficha.grupos[index];
                return _GrupoMovil(
                  grupo: grupo,
                  scores: scores,
                  readOnly: readOnly,
                  criteriosResaltados: criteriosResaltados,
                  onScoreChanged: onScoreChanged,
                );
              },
            ),
          ),
          // Pie fijo: ENVIAR + reiniciar.
          Material(
            color: CataV51Theme.tarjeta,
            elevation: 4,
            shadowColor: Colors.black38,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (bannerEnvio != null && bannerEnvio!.isNotEmpty) ...[
                      Text(
                        bannerEnvio!,
                        textAlign: TextAlign.center,
                        style: CataV2Theme.text(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: bannerEnvio!.startsWith('Enviada')
                              ? const Color(0xFF2E7D32)
                              : CataV51Theme.rojoAccion,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (readOnly)
                      Text(
                        'Puntuación aprobada (solo lectura)',
                        textAlign: TextAlign.center,
                        style: CataV2Theme.text(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CataV51Theme.textoMuted,
                        ),
                      )
                    else ...[
                      EnviarButtonV4(
                        fichaCompleta: fichaCompleta,
                        faltanCriterios:
                            (criteriosTotal - criteriosCompletos).clamp(0, 99),
                        guardando: guardando,
                        onEnviar: onEnviar,
                        estiloCompactoV51: true,
                      ),
                      if (onReiniciar != null) ...[
                        const SizedBox(height: 4),
                        ReiniciarSecundarioV51(onPressed: onReiniciar!),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrupoMovil extends StatelessWidget {
  const _GrupoMovil({
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
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CataV51Theme.tarjeta,
          borderRadius: BorderRadius.circular(CataV51Theme.radioTarjeta),
          border: Border.all(color: CataV51Theme.bordeTarjeta),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: CataV51Theme.anchoBanda,
              constraints: const BoxConstraints(minHeight: 72),
              decoration: BoxDecoration(
                color: estilo.banda,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(11),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 6, 6),
                child: Column(
                  children: [
                    for (final c in grupo.criterios)
                      if (c.usaBotonesEnFila)
                        CriterioBotonesV51Movil(
                          label: c.label,
                          valores: c.valoresDisponibles,
                          valorSeleccionado: scores[c.id]?.round(),
                          completado: scores.containsKey(c.id),
                          readOnly: readOnly,
                          resaltarPendiente:
                              criteriosResaltados.contains(c.id),
                          onSelected: (v) => onScoreChanged(c.id, v),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            c.label,
                            style: CataV2Theme.text(fontSize: 12),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
