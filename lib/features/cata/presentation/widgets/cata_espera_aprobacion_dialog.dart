import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';

class CataEsperaAprobacionDialog extends StatefulWidget {
  const CataEsperaAprobacionDialog({
    super.key,
    required this.ficha,
    required this.scores,
    required this.total,
    required this.onRevisar,
  });

  final FichaDefinicion ficha;
  final Map<String, num> scores;
  final double total;
  final VoidCallback onRevisar;

  @override
  State<CataEsperaAprobacionDialog> createState() =>
      _CataEsperaAprobacionDialogState();
}

class _CataEsperaAprobacionDialogState extends State<CataEsperaAprobacionDialog>
    with TickerProviderStateMixin {
  static const _verdeOscuro = Color(0xFF2E7D32);
  static const _verdeClaro = Color(0xFF66BB6A);
  static const _textoOscuro = Color(0xFF212121);
  static const _textoGris = Color(0xFF546E7A);

  late final AnimationController _tituloController;
  late final AnimationController _esperaController;
  late final Animation<Color?> _tituloColor;
  late final Animation<double> _esperaEscala;

  @override
  void initState() {
    super.initState();
    _tituloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _esperaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _tituloColor = ColorTween(
      begin: _verdeOscuro,
      end: _verdeClaro,
    ).animate(CurvedAnimation(
      parent: _tituloController,
      curve: Curves.easeInOut,
    ));

    _esperaEscala = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _esperaController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _esperaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTexto = widget.total.truncateToDouble() == widget.total
        ? widget.total.toStringAsFixed(0)
        : widget.total.toStringAsFixed(1);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      backgroundColor: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 700,
        height: 540,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedBuilder(
              animation: _tituloColor,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _tituloColor.value ?? _verdeOscuro,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: (_tituloColor.value ?? _verdeOscuro)
                            .withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Text(
                'PUNTUACIÓN ENVIADA',
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _esperaController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.65 + _esperaController.value * 0.35,
                  child: Transform.scale(
                    scale: _esperaEscala.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF9800),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'ESPERE APROBACIÓN PRESIDENTE',
                  textAlign: TextAlign.center,
                  style: VirtusTextStyles.plain(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE65100),
                    letterSpacing: 0.35,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            for (final grupo in widget.ficha.grupos) ...[
                              Text(
                                grupo.nombre.toUpperCase(),
                                style: VirtusTextStyles.plain(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: CataColors.cabecera,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              for (final criterio in grupo.criterios) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          criterio.label,
                                          style: VirtusTextStyles.plain(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _textoOscuro,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                        ),
                                        child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: CataColors.cabecera
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${widget.scores[criterio.id]?.round() ?? '—'}',
                                          textAlign: TextAlign.center,
                                          style: VirtusTextStyles.plain(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: CataColors.acento,
                                          ),
                                        ),
                                      ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'TOTAL',
                              style: VirtusTextStyles.plain(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _textoGris,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              totalTexto,
                              style: VirtusTextStyles.plain(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: CataColors.acento,
                                height: 1,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: widget.onRevisar,
                style: FilledButton.styleFrom(
                  backgroundColor: _verdeOscuro,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'REVISAR MI PUNTUACIÓN',
                  style: VirtusTextStyles.plain(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
