import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/home/domain/dispositivo_home_item.dart';
import 'package:virtus2027/features/home/utils/pais_flag.dart';

class DispositivoCard extends StatelessWidget {
  const DispositivoCard({
    super.key,
    required this.item,
    this.onTap,
    this.showMesaEnTarjeta = true,
  });

  final DispositivoHomeItem item;
  final VoidCallback? onTap;
  final bool showMesaEnTarjeta;

  static const _textoSecundarioSize = 11.0;
  static const _tabletNumeroSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activo = item.activo;
    final mesaLabel = item.mesaNumero?.toString() ?? '—';
    final tabletLabel = item.deviceId.toString();
    final puestoLabel = item.puesto?.toString();
    final esPresidente = item.tieneCatador && item.esPresidente;

    final borderColor = item.tieneCatador
        ? (esPresidente ? VirtusColors.oscuro : VirtusColors.medio)
        : (activo ? VirtusColors.primario : theme.colorScheme.outlineVariant);

    final backgroundColor = item.tieneCatador
        ? (esPresidente
            ? VirtusColors.oscuro
            : (activo
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest))
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);

    final textoNombre = esPresidente
        ? Colors.white
        : (activo ? VirtusColors.primario : theme.colorScheme.onSurfaceVariant);

    final textoSecundario = esPresidente
        ? Colors.white.withValues(alpha: 0.94)
        : (activo ? VirtusColors.oscuro : theme.hintColor);

    final textoTablet = esPresidente
        ? Colors.white
        : (activo ? VirtusColors.oscuro : theme.colorScheme.onSurfaceVariant);

    TextStyle estiloSecundario({Color? color}) {
      return VirtusTextStyles.plain(
        fontSize: _textoSecundarioSize,
        fontWeight: FontWeight.w800,
        color: color ?? textoSecundario,
        letterSpacing: 0.2,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
            border: Border.all(
              color: borderColor,
              width: item.tieneCatador ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 4,
                right: 6,
                child: Text(
                  tabletLabel,
                  style: VirtusTextStyles.plain(
                    fontSize: _tabletNumeroSize,
                    fontWeight: FontWeight.w900,
                    color: textoTablet,
                    height: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      PaisFlag.emoji(item.paisCodigo),
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.tieneCatador ? item.catadorNombre : 'Sin asignar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 12,
                        decoration: TextDecoration.none,
                        color: textoNombre,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (esPresidente) ...[
                      const SizedBox(height: 4),
                      Text(
                        'PRESIDENTE',
                        style: estiloSecundario(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    if (showMesaEnTarjeta) ...[
                      Text(
                        'Mesa $mesaLabel',
                        style: estiloSecundario(
                          color: esPresidente
                              ? Colors.white.withValues(alpha: 0.88)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (puestoLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Puesto $puestoLabel',
                          style: estiloSecundario(
                            color: esPresidente
                                ? Colors.white.withValues(alpha: 0.85)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ] else if (puestoLabel != null) ...[
                      Text(
                        'PUESTO $puestoLabel',
                        style: estiloSecundario(
                          color: esPresidente
                              ? Colors.white.withValues(alpha: 0.85)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
