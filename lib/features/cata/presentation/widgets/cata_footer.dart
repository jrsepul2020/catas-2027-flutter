import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';

class CataFooter extends StatelessWidget {
  const CataFooter({
    super.key,
    required this.totalActual,
    required this.totalMin,
    required this.totalMax,
    required this.colorPrimario,
    required this.puedeEnviar,
    required this.readOnly,
    required this.guardando,
    required this.onGuardarBorrador,
    required this.onEnviar,
  });

  final double totalActual;
  final double totalMin;
  final double totalMax;
  final Color colorPrimario;
  final bool puedeEnviar;
  final bool readOnly;
  final bool guardando;
  final VoidCallback? onGuardarBorrador;
  final VoidCallback? onEnviar;

  static const double height = 92;
  static const _gold = VirtusColors.claro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rango = totalMax - totalMin;
    final progreso = rango <= 0
        ? 0.0
        : ((totalActual - totalMin) / rango).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            TabletLayout.screenPadding.left,
            8,
            TabletLayout.screenPadding.right,
            10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    totalActual.toStringAsFixed(
                      totalActual.truncateToDouble() == totalActual ? 0 : 1,
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _gold,
                    ),
                  ),
                  Text(
                    ' / ${totalMax.toStringAsFixed(0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progreso,
                        minHeight: 8,
                        backgroundColor: colorPrimario.withValues(alpha: 0.15),
                        color: colorPrimario,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (readOnly)
                Center(
                  child: Text(
                    'Puntuación aprobada — solo lectura',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: guardando ? null : onGuardarBorrador,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar borrador'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            guardando || !puedeEnviar ? null : onEnviar,
                        style: FilledButton.styleFrom(
                          backgroundColor: colorPrimario,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              colorPrimario.withValues(alpha: 0.35),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Enviar puntuación'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
