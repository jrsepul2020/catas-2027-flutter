import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';

class CataResumenPanel extends StatelessWidget {
  const CataResumenPanel({
    super.key,
    required this.totalActual,
    required this.totalMin,
    required this.totalMax,
    required this.faltanCriterios,
    required this.readOnly,
    required this.guardando,
    required this.puedeEnviar,
    required this.onEnviar,
  });

  final double totalActual;
  final double totalMin;
  final double totalMax;
  final int faltanCriterios;
  final bool readOnly;
  final bool guardando;
  final bool puedeEnviar;
  final VoidCallback? onEnviar;

  @override
  Widget build(BuildContext context) {
    final totalTexto = totalActual.toStringAsFixed(
      totalActual.truncateToDouble() == totalActual ? 0 : 1,
    );
    final medalla = CataMedalla.evaluar(
      total: totalActual,
      totalMin: totalMin,
      totalMax: totalMax,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PanelCard(
          child: Column(
            children: [
              Text(
                'PUNTOS TOTALES',
                style: VirtusTextStyles.plain(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                totalTexto,
                style: VirtusTextStyles.plain(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: CataColors.acento,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'MEDALLA',
                style: VirtusTextStyles.plain(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: medalla.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: medalla.color.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  medalla.label,
                  textAlign: TextAlign.center,
                  style: VirtusTextStyles.plain(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: medalla.color,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _PanelCard(
          child: Column(
            children: [
              Text(
                faltanCriterios == 0 ? 'COMPLETA' : 'FALTAN CRITERIOS',
                style: VirtusTextStyles.plain(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$faltanCriterios',
                style: VirtusTextStyles.plain(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: faltanCriterios == 0
                      ? CataColors.checkCompleto
                      : CataColors.faltanCriterios,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (readOnly)
          Text(
            'Puntuación aprobada\n(solo lectura)',
            textAlign: TextAlign.center,
            style: VirtusTextStyles.plain(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: guardando || !puedeEnviar ? null : onEnviar,
              style: FilledButton.styleFrom(
                backgroundColor: CataColors.cabecera,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    CataColors.cabecera.withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Enviar puntuación',
                      style: VirtusTextStyles.plain(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}
