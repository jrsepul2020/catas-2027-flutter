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
    final enUso = item.activo;
    final mesaLabel = item.mesaNumero?.toString() ?? '—';
    // Número principal = puesto en mesa (orden de asignación).
    final numeroPrincipal = item.puesto?.toString() ?? item.deviceIdLabel;
    final tabletLabel = item.deviceIdLabel;
    final puestoLabel = item.puesto?.toString();
    final esPresidente = item.tieneCatador && item.esPresidente;

    final borderColor = item.tieneCatador
        ? (esPresidente ? VirtusColors.oscuro : VirtusColors.medio)
        : theme.colorScheme.outlineVariant;

    final backgroundColor = item.tieneCatador
        ? (esPresidente
            ? VirtusColors.oscuro
            : theme.colorScheme.primaryContainer)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);

    final textoNombre =
        esPresidente ? Colors.white : VirtusColors.primario;

    final textoSecundario = esPresidente
        ? Colors.white.withValues(alpha: 0.94)
        : VirtusColors.oscuro;

    final textoTablet = esPresidente ? Colors.white : VirtusColors.oscuro;

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
        child: Opacity(
          opacity: enUso ? 0.55 : 1,
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
                    numeroPrincipal,
                    style: VirtusTextStyles.plain(
                      fontSize: _tabletNumeroSize,
                      fontWeight: FontWeight.w900,
                      color: textoTablet,
                      height: 1,
                    ),
                  ),
                ),
                if (enUso)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'EN USO',
                              style: VirtusTextStyles.plain(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
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
                        if (puestoLabel != null &&
                            puestoLabel != tabletLabel) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Tablet $tabletLabel',
                            style: estiloSecundario(
                              color: esPresidente
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ] else ...[
                        Text(
                          'Tablet $tabletLabel',
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
      ),
    );
  }
}
