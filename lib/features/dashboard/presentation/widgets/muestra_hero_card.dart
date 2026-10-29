import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_colors.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';

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

  static const double height = 196;

  static TextStyle _blanco({
    required double fontSize,
    required FontWeight fontWeight,
    double alpha = 1,
    double? height,
    double? letterSpacing,
  }) {
    return VirtusTextStyles.plain(
      color: Colors.white.withValues(alpha: alpha),
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = DashboardColors.primario(colorPrimario);
    final oscuro = DashboardColors.oscuro(base);
    final medio = DashboardColors.medio(base);

    final card = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [medio, oscuro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
        boxShadow: [
          BoxShadow(
            color: oscuro.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: muestra == null
            ? Center(
                child: Text(
                  'No hay muestra activa en esta tanda',
                  style: _blanco(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              )
            : _buildContent(oscuro),
      ),
    );

    if (flexibleHeight) return card;
    return SizedBox(height: height, child: card);
  }

  Widget _buildContent(Color oscuro) {
    final m = muestra!;
    final subtipo = m.categoriaCata?.isNotEmpty == true
        ? m.categoriaCata!.toUpperCase()
        : categoriaNombre.toUpperCase();

    final estado = (m.estado ?? '').toLowerCase().trim();
    final cataActiva = estado == 'activa' || estado == 'en_curso';
    final esperandoApertura =
        estado == 'pendiente' || estado.isEmpty;

    final centerPanel = DecoratedBox(
      decoration: BoxDecoration(
        color: oscuro.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  !tandaAbierta
                      ? Icons.lock_outline
                      : cataActiva
                          ? Icons.check_circle_outline
                          : Icons.hourglass_empty,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  !tandaAbierta
                      ? 'CATA CERRADA'
                      : cataActiva
                          ? 'CATA ABIERTA'
                          : 'ESPERANDO APERTURA',
                  style: _blanco(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    alpha: 0.92,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              m.codigoDisplay,
              style: _blanco(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtipo,
              style: _blanco(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                alpha: 0.85,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Orden ${m.orden}',
              style: _blanco(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                alpha: 0.92,
              ),
            ),
            const SizedBox(height: 12),
            _PulsingCatarButton(
              label: esPresidente && esperandoApertura
                  ? 'ABRIR CATA'
                  : 'ENTRAR A CATAR',
              icon: esPresidente && esperandoApertura
                  ? Icons.play_arrow
                  : Icons.wine_bar,
              enabled: esPresidente && esperandoApertura
                  ? onAbrirCata != null
                  : onEntrarCatar != null,
              oscuro: oscuro,
              onPressed: esPresidente && esperandoApertura
                  ? onAbrirCata
                  : onEntrarCatar,
            ),
          ],
        ),
      ),
    );

    if (hideSideMeta && !showStats) {
      return centerPanel;
    }

    return Row(
      children: [
        if (!hideSideMeta) ...[
          SizedBox(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MetaLine(label: 'Tanda', value: '${tandaNumero ?? '—'}'),
                _MetaLine(label: 'Mesa', value: '$mesaNumero'),
                _MetaLine(label: 'Orden', value: '${m.orden}'),
                const SizedBox(height: 4),
                Text(
                  categoriaNombre.toUpperCase(),
                  style: _blanco(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    alpha: 0.85,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
        Expanded(child: centerPanel),
        if (showStats)
          SizedBox(
            width: 148,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatLine(label: 'Quedan', value: '${stats.quedan}'),
                _StatLine(label: 'Catadas', value: '${stats.catadas}'),
                _StatLine(
                  label: 'Pospuestas',
                  value: '${stats.pospuestas}',
                ),
                _StatLine(
                  label: 'Descalif.',
                  value: '${stats.descalificadas}',
                ),
                _StatLine(
                  label: 'Pendientes',
                  value: '${stats.pendientes}/${stats.total}',
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stats.progreso.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Progreso: ${stats.catadas}/${stats.total}',
                  style: _blanco(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    alpha: 0.88,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PulsingCatarButton extends StatefulWidget {
  const _PulsingCatarButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.oscuro,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final Color oscuro;
  final VoidCallback? onPressed;

  @override
  State<_PulsingCatarButton> createState() => _PulsingCatarButtonState();
}

class _PulsingCatarButtonState extends State<_PulsingCatarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 1, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulsingCatarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ScaleTransition(
        scale: widget.enabled ? _scale : const AlwaysStoppedAnimation(1),
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: widget.oscuro,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(widget.icon, size: 20, color: widget.oscuro),
          label: Text(
            widget.label,
            style: VirtusTextStyles.plain(
              color: widget.oscuro,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: VirtusTextStyles.plain(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
          ),
          children: [
            VirtusTextStyles.span(text: '$label: '),
            VirtusTextStyles.span(
              text: value,
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: VirtusTextStyles.plain(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: VirtusTextStyles.plain(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
