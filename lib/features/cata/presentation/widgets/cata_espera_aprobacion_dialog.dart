import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';

class CataEsperaAprobacionDialog extends StatelessWidget {
  const CataEsperaAprobacionDialog({
    super.key,
    required this.ficha,
    required this.scores,
    required this.total,
    required this.codigoMuestra,
    required this.onRevisar,
    this.muestraOrden,
    this.tandaMuestrasTotal,
  });

  final FichaDefinicion ficha;
  final Map<String, num> scores;
  final double total;
  final String codigoMuestra;
  final VoidCallback onRevisar;
  final int? muestraOrden;
  final int? tandaMuestrasTotal;

  static const _texto = Color(0xFF1B2B22);
  static const _textoMuted = Color(0xFF6B7C72);
  static const _borde = Color(0xFFD5E0D8);
  static const _fondoDialog = Color(0xFFF7FAF8);

  @override
  Widget build(BuildContext context) {
    final totalTexto = total.truncateToDouble() == total
        ? total.toStringAsFixed(0)
        : total.toStringAsFixed(1);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      backgroundColor: _fondoDialog,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 740, maxHeight: 640),
        child: SizedBox(
          width: 720,
          height: 610,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Puntuación enviada',
                  textAlign: TextAlign.center,
                  style: VirtusTextStyles.plain(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textoMuted,
                    letterSpacing: 0.2,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                const _EsperaPresidenteBanner(),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _CriteriosPanel(
                          ficha: ficha,
                          scores: scores,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _PuntosPanel(
                          puntosTexto: totalTexto,
                          codigoMuestra: codigoMuestra,
                          muestraOrden: muestraOrden,
                          tandaMuestrasTotal: tandaMuestrasTotal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onRevisar,
                    style: FilledButton.styleFrom(
                      backgroundColor: VirtusColors.primario,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor:
                          VirtusColors.primario.withValues(alpha: 0.45),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'REVISAR MI PUNTUACIÓN',
                      style: VirtusTextStyles.plain(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: Colors.white,
                        letterSpacing: 0.6,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EsperaPresidenteBanner extends StatefulWidget {
  const _EsperaPresidenteBanner();

  @override
  State<_EsperaPresidenteBanner> createState() =>
      _EsperaPresidenteBannerState();
}

class _EsperaPresidenteBannerState extends State<_EsperaPresidenteBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_pulse.value);
        return Opacity(
          opacity: 0.62 + 0.38 * t,
          child: child,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: VirtusColors.primario,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: VirtusColors.primario.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Espere la aprobación del presidente',
                      style: VirtusTextStyles.plain(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.15,
                        fontFamily: 'Inter',
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Su ficha ya está registrada. Puede revisar si necesita corregir.',
                      style: VirtusTextStyles.plain(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontFamily: 'Inter',
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CriteriosPanel extends StatelessWidget {
  const _CriteriosPanel({
    required this.ficha,
    required this.scores,
  });

  final FichaDefinicion ficha;
  final Map<String, num> scores;

  @override
  Widget build(BuildContext context) {
    final filas = <Widget>[];
    for (final grupo in ficha.grupos) {
      for (final criterio in grupo.criterios) {
        filas.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    criterio.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VirtusTextStyles.plain(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CataEsperaAprobacionDialog._texto,
                      height: 1.1,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  constraints: const BoxConstraints(minWidth: 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: VirtusColors.fondoSuave,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: VirtusColors.muyClaro),
                  ),
                  child: Text(
                    '${scores[criterio.id]?.round() ?? '—'}',
                    textAlign: TextAlign.center,
                    style: VirtusTextStyles.plain(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: VirtusColors.primario,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CataEsperaAprobacionDialog._borde),
        boxShadow: [
          BoxShadow(
            color: VirtusColors.primario.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: filas,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PuntosPanel extends StatelessWidget {
  const _PuntosPanel({
    required this.puntosTexto,
    required this.codigoMuestra,
    this.muestraOrden,
    this.tandaMuestrasTotal,
  });

  final String puntosTexto;
  final String codigoMuestra;
  final int? muestraOrden;
  final int? tandaMuestrasTotal;

  static TextStyle get _tituloStyle => VirtusTextStyles.plain(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: CataEsperaAprobacionDialog._textoMuted,
        letterSpacing: 0.55,
        fontFamily: 'Inter',
      );

  static TextStyle get _valorSecundarioStyle => VirtusTextStyles.plain(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: CataEsperaAprobacionDialog._texto,
        height: 1.05,
        fontFamily: 'Inter',
      );

  @override
  Widget build(BuildContext context) {
    final mostrarProgreso =
        muestraOrden != null &&
        tandaMuestrasTotal != null &&
        tandaMuestrasTotal! > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CataEsperaAprobacionDialog._borde),
        boxShadow: [
          BoxShadow(
            color: VirtusColors.primario.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('MUESTRA', style: _tituloStyle),
                    const SizedBox(height: 4),
                    Text(
                      codigoMuestra,
                      textAlign: TextAlign.center,
                      style: _valorSecundarioStyle,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('PUNTOS', style: _tituloStyle),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        puntosTexto,
                        style: VirtusTextStyles.plain(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: CataColors.acento,
                          height: 1,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('PROGRESO DE LA TANDA', style: _tituloStyle),
                    const SizedBox(height: 4),
                    Text(
                      mostrarProgreso
                          ? '$muestraOrden / $tandaMuestrasTotal'
                          : '—',
                      textAlign: TextAlign.center,
                      style: _valorSecundarioStyle,
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
