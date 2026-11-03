import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';

/// Tipografía del dashboard: pocos tamaños, pocos pesos.
abstract final class DashboardType {
  static TextStyle label({Color color = CataV2Theme.textoMuted}) =>
      CataV2Theme.text(fontSize: 11, fontWeight: FontWeight.w700, color: color);

  static TextStyle body({Color color = CataV2Theme.texto}) =>
      CataV2Theme.text(fontSize: 13, fontWeight: FontWeight.w600, color: color);

  static TextStyle title({Color color = CataV2Theme.texto}) =>
      CataV2Theme.text(fontSize: 16, fontWeight: FontWeight.w800, color: color);

  static TextStyle code({Color color = Colors.white}) =>
      CataV2Theme.text(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.05,
        letterSpacing: 0.8,
      );
}

/// Tarjeta de muestra en foco: mismo ancho que el listado inferior.
///
/// Ámbar = pendiente (parpadeo). Verde = cata abierta (parpadeo suave).
class MuestraHeroCard extends StatelessWidget {
  const MuestraHeroCard({
    super.key,
    required this.muestra,
    required this.mesaNumero,
    required this.tandaNumero,
    required this.categoriaNombre,
    required this.tandaAbierta,
    required this.stats,
    required this.colorPrimario,
    required this.onEntrarCatar,
    this.onAbrirCata,
    this.esPresidente = false,
    this.showStats = true,
    this.hideSideMeta = false,
    this.flexibleHeight = false,
  });

  final MuestraEnTanda? muestra;
  final int mesaNumero;
  final int? tandaNumero;
  final String categoriaNombre;
  final bool tandaAbierta;
  final DashboardMuestraStats stats;
  final String? colorPrimario;
  final VoidCallback? onEntrarCatar;
  final VoidCallback? onAbrirCata;
  final bool esPresidente;
  final bool showStats;
  final bool hideSideMeta;
  final bool flexibleHeight;

  /// Alto del bloque (cuadrado compacto; el ancho lo da la columna).
  static const double height = 176;

  static TextStyle codeGrande({Color color = Colors.white}) =>
      CataV2Theme.text(
        fontSize: 44,
        fontWeight: FontWeight.w900,
        color: color,
        height: 1.0,
        letterSpacing: 1.2,
      );

  static const Color amber = Color(0xFFE6A117);
  static const Color amberDeep = Color(0xFFB87A00);
  static const Color green = Color(0xFF2D6A4F);
  static const Color greenDeep = Color(0xFF1B4332);

  @override
  Widget build(BuildContext context) {
    final estado = (muestra?.estado ?? '').toLowerCase().trim();
    final esperando =
        tandaAbierta && (estado == 'pendiente' || estado.isEmpty);
    final abierta =
        tandaAbierta && (estado == 'activa' || estado == 'en_curso');

    final card = SizedBox(
      height: height,
      width: double.infinity,
      child: muestra == null
          ? const _HeroVacio()
          : _HeroActivo(
              muestra: muestra!,
              categoriaNombre: categoriaNombre,
              tandaAbierta: tandaAbierta,
              stats: stats,
              esPresidente: esPresidente,
              esperando: esperando,
              abierta: abierta,
              onAbrirCata: onAbrirCata,
              onEntrarCatar: onEntrarCatar,
            ),
    );

    return card;
  }
}

class _HeroVacio extends StatelessWidget {
  const _HeroVacio();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CataV2Theme.superficie,
        borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
        border: Border.all(color: CataV2Theme.borde),
      ),
      child: Center(
        child: Text(
          'No hay muestra activa en esta tanda',
          style: DashboardType.body(color: CataV2Theme.textoSecundario),
        ),
      ),
    );
  }
}

class _HeroActivo extends StatefulWidget {
  const _HeroActivo({
    required this.muestra,
    required this.categoriaNombre,
    required this.tandaAbierta,
    required this.stats,
    required this.esPresidente,
    required this.esperando,
    required this.abierta,
    this.onAbrirCata,
    this.onEntrarCatar,
  });

  final MuestraEnTanda muestra;
  final String categoriaNombre;
  final bool tandaAbierta;
  final DashboardMuestraStats stats;
  final bool esPresidente;
  final bool esperando;
  final bool abierta;
  final VoidCallback? onAbrirCata;
  final VoidCallback? onEntrarCatar;

  @override
  State<_HeroActivo> createState() => _HeroActivoState();
}

class _HeroActivoState extends State<_HeroActivo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  bool get _debeParpadear =>
      widget.tandaAbierta && (widget.esperando || widget.abierta);

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    if (_debeParpadear) _blink.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _HeroActivo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_debeParpadear) {
      if (!_blink.isAnimating) _blink.repeat(reverse: true);
    } else {
      _blink.stop();
      _blink.value = 0;
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoria =
        widget.muestra.categoriaDisplay(fallback: widget.categoriaNombre);
    final botonEnabled = widget.esperando
        ? widget.onAbrirCata != null
        : widget.onEntrarCatar != null;
    final botonOnPressed =
        widget.esperando ? widget.onAbrirCata : widget.onEntrarCatar;
    final progreso = widget.stats.total == 0
        ? 0.0
        : (widget.stats.catadas / widget.stats.total).clamp(0.0, 1.0);

    final base = !widget.tandaAbierta
        ? const Color(0xFF5A635A)
        : widget.esperando
            ? MuestraHeroCard.amberDeep
            : widget.abierta
                ? MuestraHeroCard.greenDeep
                : CataV2Theme.cabecera;
    final highlight = widget.esperando
        ? MuestraHeroCard.amber
        : widget.abierta
            ? MuestraHeroCard.green
            : base;

    final estadoLabel = !widget.tandaAbierta
        ? 'Cata cerrada'
        : widget.esperando
            ? 'Muestra en preparación'
            : widget.abierta
                ? 'Cata abierta'
                : 'En espera';

    return AnimatedBuilder(
      animation: _blink,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_blink.value);
        final intensity = _debeParpadear ? t : 0.45;
        final bg = Color.lerp(base, highlight, intensity)!;
        final borderAlpha = _debeParpadear ? 0.25 + t * 0.7 : 0.3;
        final titleOpacity = _debeParpadear ? 0.55 + t * 0.45 : 1.0;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderAlpha),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: highlight.withValues(
                  alpha: _debeParpadear ? 0.2 + t * 0.35 : 0.15,
                ),
                blurRadius: _debeParpadear ? 8 + t * 14 : 6,
                spreadRadius: _debeParpadear ? t * 2 : 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: titleOpacity,
                        child: Text(
                          estadoLabel.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: CataV2Theme.text(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.muestra.codigoDisplay,
                        textAlign: TextAlign.center,
                        style: MuestraHeroCard.codeGrande(),
                      ),
                      if (categoria.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          categoria,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CataV2Theme.text(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '${widget.stats.catadas}/${widget.stats.total}',
                            style: DashboardType.label(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progreso,
                                minHeight: 3,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.25),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '#${widget.muestra.orden}',
                            style: DashboardType.label(
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.esPresidente) ...[
                  const SizedBox(height: 8),
                  _CtaFlechas(
                    label: widget.esperando ? 'ABRIR CATA' : 'ENTRAR A CATAR',
                    enabled: botonEnabled,
                    onPressed: botonOnPressed,
                    animate: botonEnabled,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CTA a ancho completo: `>>>  label  <<<` con flechas animadas.
class _CtaFlechas extends StatefulWidget {
  const _CtaFlechas({
    required this.label,
    required this.enabled,
    required this.animate,
    this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool animate;
  final VoidCallback? onPressed;

  @override
  State<_CtaFlechas> createState() => _CtaFlechasState();
}

class _CtaFlechasState extends State<_CtaFlechas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    if (widget.enabled && widget.animate) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _CtaFlechas oldWidget) {
    super.didUpdateWidget(oldWidget);
    final run = widget.enabled && widget.animate;
    if (run && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!run) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown:
          widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          height: 42,
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B1F1B),
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.45),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_c.value);
                final gap = 1.0 + t * 4.0;
                final arrowOpacity = 0.45 + t * 0.55;
                const arrowsLeft = '>>>>>';
                const arrowsRight = '<<<<<';
                return Row(
                  children: [
                    Opacity(
                      opacity: arrowOpacity,
                      child: Text(
                        arrowsLeft,
                        style: CataV2Theme.text(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1B1F1B),
                          letterSpacing: gap,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CataV2Theme.text(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1B1F1B),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: arrowOpacity,
                      child: Text(
                        arrowsRight,
                        style: CataV2Theme.text(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1B1F1B),
                          letterSpacing: gap,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
