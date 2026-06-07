import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/features/home/domain/catador_slot.dart';
import 'package:virtus2027/features/home/presentation/widgets/catador_slot_tile.dart';

/// Cuadrícula 5×5 calculada para el área útil 1003×627.
class CatadoresGrid extends StatelessWidget {
  const CatadoresGrid({
    super.key,
    required this.slots,
    required this.onSlotTap,
  });

  final List<CatadorSlot> slots;
  final ValueChanged<CatadorSlot> onSlotTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: TabletLayout.screenPadding.copyWith(top: 0),
      child: Column(
        children: List.generate(TabletLayout.gridRows, (row) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: row < TabletLayout.gridRows - 1
                    ? TabletLayout.gridSpacing
                    : 0,
              ),
              child: Row(
                children: List.generate(TabletLayout.gridColumns, (col) {
                  final index = row * TabletLayout.gridColumns + col;
                  final slot = index < slots.length
                      ? slots[index]
                      : CatadorSlot(
                          posicion: index + 1,
                          nombreCatador: '',
                        );

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: col < TabletLayout.gridColumns - 1
                            ? TabletLayout.gridSpacing
                            : 0,
                      ),
                      child: CatadorSlotTile(
                        slot: slot,
                        onTap: () => onSlotTap(slot),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        }),
      ),
    );
  }
}
