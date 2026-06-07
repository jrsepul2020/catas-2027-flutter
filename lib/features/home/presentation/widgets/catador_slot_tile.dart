import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/features/home/domain/catador_slot.dart';

class CatadorSlotTile extends StatelessWidget {
  const CatadorSlotTile({
    super.key,
    required this.slot,
    this.onTap,
  });

  final CatadorSlot slot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assigned = slot.tieneCatador;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: assigned
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
            border: Border.all(
              color: assigned
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: assigned ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${slot.posicion}',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: Text(
                      assigned ? slot.nombreCatador : 'Sin asignar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: assigned
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
