import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/domain/puntuacion_mesa_catador.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_medalla_widget.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';

class CataAprobacionDialog extends StatelessWidget {
  const CataAprobacionDialog({
    super.key,
    required this.resumen,
    required this.aprobando,
    required this.onAprobar,
    required this.onAprobarAdmin,
    required this.onRevisar,
  });

  final ResumenAprobacionMesa resumen;
  final bool aprobando;
  final VoidCallback onAprobar;
  final VoidCallback onAprobarAdmin;
  final VoidCallback onRevisar;

  @override
  Widget build(BuildContext context) {
    final media = resumen.promedio;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 960,
        height: 580,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            if (resumen.todosHanPuntuado)
              const _BannerTodos()
            else
              const _BannerFaltanCatadores(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _TablaCatadores(
                        catadores: resumen.catadores,
                        media: media,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 220,
                      child: _PanelLateral(
                        resumen: resumen,
                        aprobando: aprobando,
                        onAprobar: onAprobar,
                        onAprobarAdmin: onAprobarAdmin,
                        onRevisar: onRevisar,
                        puedeAprobar: resumen.todosHanPuntuado,
                        puedeAprobarAdmin: resumen.puntuacionesRecibidas > 0,
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(
        'APROBACIÓN DE CATA',
        textAlign: TextAlign.center,
        style: VirtusTextStyles.plain(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _BannerTodos extends StatelessWidget {
  const _BannerTodos();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: Text(
        'TODOS LOS CATADORES HAN PUNTUADO',
        textAlign: TextAlign.center,
        style: VirtusTextStyles.plain(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF2E7D32),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BannerFaltanCatadores extends StatefulWidget {
  const _BannerFaltanCatadores();

  @override
  State<_BannerFaltanCatadores> createState() => _BannerFaltanCatadoresState();
}

class _BannerFaltanCatadoresState extends State<_BannerFaltanCatadores>
    with SingleTickerProviderStateMixin {
  static const _naranja = Color(0xFFE65100);
  static const _naranjaClaro = Color(0xFFFF9800);

  late final AnimationController _controller;
  late final Animation<Color?> _fondo;
  late final Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _fondo = ColorTween(begin: _naranja, end: _naranjaClaro).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _escala = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _escala.value,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: _fondo.value,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: _naranja.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Text(
        'FALTAN CATADORES POR PUNTUAR',
        textAlign: TextAlign.center,
        style: VirtusTextStyles.plain(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TablaCatadores extends StatelessWidget {
  const _TablaCatadores({required this.catadores, required this.media});

  final List<PuntuacionMesaCatador> catadores;
  final double? media;

  @override
  Widget build(BuildContext context) {
    final medalla = media == null
        ? null
        : CataMedalla.evaluar(total: media!);
    final visual = medalla?.label.aMedallaVisual ?? CataMedallaVisual.ninguna;
    final totalLabel = media == null
        ? '—'
        : (media!.truncateToDouble() == media
            ? media!.toStringAsFixed(0)
            : media!.toStringAsFixed(1));
    final medallaLabel = media == null
        ? '—'
        : (medalla?.label ?? 'SIN MEDALLA');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: CataV2Theme.cabecera,
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Row(
              children: [
                _th('N.º', flex: 1),
                _th('Catador', flex: 4),
                _th('Puntuación', flex: 2, center: true),
                _th('Estado', flex: 2, center: true),
                _th('Desvío', flex: 3, center: true),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: catadores.length + 1,
              itemBuilder: (context, i) {
                if (i == catadores.length) {
                  // Resumen justo debajo del último catador.
                  return _FilaResumenMedia(
                    totalLabel: totalLabel,
                    medallaLabel: medallaLabel,
                    medalla: medalla,
                    visual: visual,
                  );
                }

                final c = catadores[i];
                final discordante = c.esDiscordante(media);
                final desvio = c.desvioLabel(media);
                final filaColor = discordante
                    ? const Color(0xFFFFEBEE)
                    : c.recibida
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColoredBox(
                      color: filaColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            _td(
                              '${c.orden}',
                              flex: 1,
                              color: discordante
                                  ? const Color(0xFFC62828)
                                  : null,
                            ),
                            _td(
                              c.nombre.toUpperCase(),
                              flex: 4,
                              color: discordante
                                  ? const Color(0xFFC62828)
                                  : null,
                            ),
                            _td(
                              c.total != null ? '${c.total!.round()}' : '—',
                              flex: 2,
                              center: true,
                              bold: true,
                              color: discordante
                                  ? const Color(0xFFC62828)
                                  : CataColors.cabecera,
                              fontSize: 22,
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: c.recibida
                                    ? _EstadoRecibidoBadge(
                                        label: c.estadoLabel,
                                      )
                                    : _EstadoPendienteBadge(
                                        label: c.estadoLabel,
                                      ),
                              ),
                            ),
                            _td(
                              desvio ?? '',
                              flex: 3,
                              center: true,
                              bold: discordante,
                              fontSize: 11,
                              color: discordante
                                  ? const Color(0xFFC62828)
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(String text, {required int flex, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: VirtusTextStyles.plain(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _td(
    String text, {
    required int flex,
    bool center = false,
    bool bold = false,
    Color? color,
    double fontSize = 13,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: VirtusTextStyles.plain(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
          color: color ?? const Color(0xFF212121),
        ),
      ),
    );
  }
}

class _FilaResumenMedia extends StatelessWidget {
  const _FilaResumenMedia({
    required this.totalLabel,
    required this.medallaLabel,
    required this.medalla,
    required this.visual,
  });

  final String totalLabel;
  final String medallaLabel;
  final ({String label, Color color, Color background})? medalla;
  final CataMedallaVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2EE),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          const Expanded(flex: 1, child: SizedBox.shrink()),
          Expanded(
            flex: 4,
            child: Text(
              'PUNTUACIÓN MEDIA',
              style: VirtusTextStyles.plain(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade800,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              totalLabel,
              textAlign: TextAlign.center,
              style: VirtusTextStyles.plain(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFD32F2F),
                height: 1,
                letterSpacing: -0.8,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: visual != CataMedallaVisual.ninguna
                      ? (medalla?.background ?? Colors.grey.shade200)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  medallaLabel,
                  textAlign: TextAlign.center,
                  style: VirtusTextStyles.plain(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: visual != CataMedallaVisual.ninguna
                        ? (medalla?.color ?? Colors.grey.shade700)
                        : Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(flex: 3, child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _EstadoRecibidoBadge extends StatelessWidget {
  const _EstadoRecibidoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF4CAF50)),
          const SizedBox(width: 4),
          Text(
            label,
            style: VirtusTextStyles.plain(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoPendienteBadge extends StatefulWidget {
  const _EstadoPendienteBadge({required this.label});

  final String label;

  @override
  State<_EstadoPendienteBadge> createState() => _EstadoPendienteBadgeState();
}

class _EstadoPendienteBadgeState extends State<_EstadoPendienteBadge>
    with SingleTickerProviderStateMixin {
  static const _naranja = Color(0xFFE65100);
  static const _naranjaClaro = Color(0xFFFFB74D);

  late final AnimationController _controller;
  late final Animation<Color?> _fondo;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _fondo = ColorTween(begin: _naranja, end: _naranjaClaro).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fondo,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _fondo.value,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            widget.label,
            style: VirtusTextStyles.plain(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelLateral extends StatelessWidget {
  const _PanelLateral({
    required this.resumen,
    required this.aprobando,
    required this.onAprobar,
    required this.onAprobarAdmin,
    required this.onRevisar,
    required this.puedeAprobar,
    required this.puedeAprobarAdmin,
  });

  final ResumenAprobacionMesa resumen;
  final bool aprobando;
  final VoidCallback onAprobar;
  final VoidCallback onAprobarAdmin;
  final VoidCallback onRevisar;
  final bool puedeAprobar;
  final bool puedeAprobarAdmin;

  @override
  Widget build(BuildContext context) {
    final ficha = FichaDefinicion.vinosTranquilos();
    final media = resumen.promedio;
    final medalla = media == null
        ? null
        : CataMedalla.evaluar(
            total: media,
            totalMin: ficha.totalMin,
            totalMax: ficha.totalMax,
          );
    final visual = medalla?.label.aMedallaVisual ?? CataMedallaVisual.ninguna;
    final hayPremio = visual != CataMedallaVisual.ninguna;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PanelCard(
          child: Column(
            children: [
              Text(
                'CÓDIGO DE MUESTRA',
                style: VirtusTextStyles.plain(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                resumen.codigoMuestra,
                style: VirtusTextStyles.plain(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _PanelCard(
            child: Column(
              children: [
                Text(
                  'PROMEDIO',
                  style: VirtusTextStyles.plain(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resumen.promedioLabel,
                  style: VirtusTextStyles.plain(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: CataColors.acento,
                    height: 1,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: hayPremio
                        ? CataMedallaWidget(variante: visual, size: 88)
                        : Text(
                            media == null ? '—' : 'SIN MEDALLA',
                            style: VirtusTextStyles.plain(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.4,
                            ),
                          ),
                  ),
                ),
                Text(
                  '${resumen.puntuacionesRecibidas} de ${resumen.totalCatadores} puntuaciones',
                  style: VirtusTextStyles.plain(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: aprobando || !puedeAprobar ? null : onAprobar,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: aprobando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check, color: Colors.white),
          label: Text(
            'APROBAR Y CONTINUAR',
            style: VirtusTextStyles.plain(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: aprobando ? null : onRevisar,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'REVISAR/CORREGIR MI PUNTUACIÓN',
            textAlign: TextAlign.center,
            style: VirtusTextStyles.plain(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: aprobando || !puedeAprobarAdmin ? null : onAprobarAdmin,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE65100),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'APROBAR CATA ADMIN',
            textAlign: TextAlign.center,
            style: VirtusTextStyles.plain(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: Colors.white,
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}
