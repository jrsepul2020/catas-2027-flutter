import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/core/widgets/status_bar_spacer.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_colors.dart';
import 'package:virtus2027/features/home/utils/pais_flag.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.concursoNombre,
    required this.catadorNombre,
    required this.rolLabel,
    required this.paisCodigo,
    required this.mesaNumero,
    required this.tandaNumero,
    required this.colorPrimario,
    this.esPresidente = false,
    this.mostrarModoPruebas = false,
    this.onBack,
    this.onRefresh,
    this.onEstadisticas,
    this.onTrucos,
  });

  final String concursoNombre;
  final String catadorNombre;
  final String rolLabel;
  final String? paisCodigo;
  final int mesaNumero;
  final int? tandaNumero;
  final String? colorPrimario;
  final bool esPresidente;
  final bool mostrarModoPruebas;
  final VoidCallback? onBack;
  final VoidCallback? onRefresh;
  final VoidCallback? onEstadisticas;
  final VoidCallback? onTrucos;

  static const double height = 50;

  @override
  Widget build(BuildContext context) {
    final bg = DashboardColors.primario(colorPrimario);

    return ColoredBox(
      color: bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBarSpacer(color: bg),
          SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                flex: 3,
                child: Text(
                  concursoNombre.toUpperCase(),
                  style: VirtusColors.titulo(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            PaisFlag.emoji(paisCodigo),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              catadorNombre.toUpperCase(),
                              style: VirtusTextStyles.plain(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RolBadge(label: rolLabel, esPresidente: esPresidente),
                    const SizedBox(width: 10),
                    Text(
                      'Mesa $mesaNumero',
                      style: VirtusTextStyles.plain(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (tandaNumero != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Tanda $tandaNumero',
                        style: VirtusTextStyles.plain(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (mostrarModoPruebas) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'MODO PRUEBAS',
                          style: VirtusTextStyles.plain(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (onTrucos != null)
                        TextButton(
                          onPressed: onTrucos,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black.withValues(alpha: 0.25),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'TRUCOS',
                            style: VirtusTextStyles.plain(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                    ],
                    if (onEstadisticas != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.settings,
                          size: TabletLayout.headerIconSize - 4,
                          color: Colors.white,
                        ),
                        tooltip: 'Ajustes',
                        padding: EdgeInsets.zero,
                        offset: const Offset(0, 40),
                        color: Colors.white,
                        onSelected: (value) {
                          if (value == 'estadisticas') onEstadisticas!();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'estadisticas',
                            child: Text(
                              'Estadísticas',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    if (onRefresh != null)
                      _HeaderIcon(
                        icon: Icons.refresh,
                        onPressed: onRefresh,
                        tooltip: 'Actualizar',
                      ),
                    if (onBack != null)
                      _HeaderIcon(
                        icon: Icons.logout,
                        onPressed: onBack,
                        tooltip: 'Volver',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }
}

class _RolBadge extends StatelessWidget {
  const _RolBadge({required this.label, required this.esPresidente});

  final String label;
  final bool esPresidente;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: esPresidente
            ? VirtusColors.claro
            : Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: VirtusTextStyles.plain(
          color: esPresidente ? VirtusColors.oscuro : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: TabletLayout.headerIconSize - 4,
      color: Colors.white,
      icon: Icon(icon),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
