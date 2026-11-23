import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/enviar_button_v4.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_v51_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/piezas_v51.dart';

/// Panel lateral V5.1 (tablet).
class CataResumenV51 extends StatelessWidget {
  const CataResumenV51({
    super.key,
    required this.totalActual,
    required this.totalMin,
    required this.totalMax,
    required this.criteriosCompletos,
    required this.criteriosTotal,
    required this.categoriaNombre,
    required this.readOnly,
    required this.guardando,
    required this.fichaCompleta,
    required this.onEnviar,
    this.umbrales = MedallaUmbrales.defecto,
    this.onReiniciar,
    this.bannerEnvio,
    this.selectorVersion,
  });

  final double totalActual;
  final double totalMin;
  final double totalMax;
  final int criteriosCompletos;
  final int criteriosTotal;
  final String categoriaNombre;
  final bool readOnly;
  final bool guardando;
  final bool fichaCompleta;
  final VoidCallback onEnviar;
  final MedallaUmbrales umbrales;
  final VoidCallback? onReiniciar;
  final String? bannerEnvio;
  final Widget? selectorVersion;

  @override
  Widget build(BuildContext context) {
    final medalla = CataMedalla.evaluar(
      total: totalActual,
      totalMin: totalMin,
      totalMax: totalMax,
      umbrales: umbrales,
    );
    final provisional = !fichaCompleta;
    final hayPremio = !provisional &&
        medalla.label.aMedallaVisual != CataMedallaVisual.ninguna;
    final totalTexto = fmtTotalV51(totalActual);
    final pieEnvio = hayPremio
        ? '$totalTexto puntos · ${cortoMedallaV51(medalla.label)}'
        : '$totalTexto puntos · Sin medalla';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (selectorVersion != null) ...[
            Align(alignment: Alignment.centerRight, child: selectorVersion!),
            const SizedBox(height: 4),
          ],
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CataV51Theme.tarjeta,
                borderRadius: BorderRadius.circular(CataV51Theme.radioTarjeta),
                border: Border.all(color: CataV51Theme.bordeTarjeta),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              categoriaNombre,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CataV2Theme.text(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: CataV51Theme.textoMuted,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TotalMedallaBloqueV51(
                              totalActual: totalActual,
                              totalMin: totalMin,
                              totalMax: totalMax,
                              fichaCompleta: fichaCompleta,
                              umbrales: umbrales,
                            ),
                            const SizedBox(height: 10),
                            EscalaPremiosV51(
                              total: totalActual,
                              umbrales: umbrales,
                              provisional: provisional,
                            ),
                            const SizedBox(height: 10),
                            BarraCriteriosV51(
                              completos: criteriosCompletos,
                              total: criteriosTotal,
                            ),
                            if (bannerEnvio != null &&
                                bannerEnvio!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _BannerEnvio(texto: bannerEnvio!),
                            ],
                            const SizedBox(height: 8),
                            if (readOnly)
                              Text(
                                'Puntuación aprobada\n(solo lectura)',
                                textAlign: TextAlign.center,
                                style: CataV2Theme.text(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: CataV51Theme.textoMuted,
                                ),
                              )
                            else ...[
                              EnviarButtonV4(
                                fichaCompleta: fichaCompleta,
                                faltanCriterios:
                                    (criteriosTotal - criteriosCompletos)
                                        .clamp(0, 99),
                                guardando: guardando,
                                onEnviar: onEnviar,
                                estiloCompactoV51: true,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pieEnvio,
                                textAlign: TextAlign.center,
                                style: CataV2Theme.text(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: CataV51Theme.textoMuted,
                                ),
                              ),
                            ],
                            if (!readOnly && onReiniciar != null) ...[
                              const SizedBox(height: 14),
                              Divider(
                                height: 1,
                                color: CataV51Theme.bordeTarjeta,
                              ),
                              const SizedBox(height: 8),
                              ReiniciarSecundarioV51(onPressed: onReiniciar!),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerEnvio extends StatelessWidget {
  const _BannerEnvio({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final ok = texto.startsWith('Enviada');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFFE8F5E9) : CataV51Theme.rojoAccionFondo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ok ? const Color(0xFF81C784) : CataV51Theme.rojoAccionBorde,
        ),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: CataV2Theme.text(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: ok ? const Color(0xFF2E7D32) : CataV51Theme.rojoAccion,
        ),
      ),
    );
  }
}
