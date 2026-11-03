import 'package:flutter/material.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestra_hero_card.dart';

/// Tabs sobre panel verde corporativo.
class MuestrasFilterTabs extends StatelessWidget {
  const MuestrasFilterTabs({
    super.key,
    required this.filtroActivo,
    required this.catadasCount,
    required this.descalificadasCount,
    required this.colorPrimario,
    required this.onChanged,
  });

  final MuestraFiltro filtroActivo;
  final int catadasCount;
  final int descalificadasCount;
  final String? colorPrimario;
  final ValueChanged<MuestraFiltro> onChanged;

  static const double height = 28;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              label: 'CATADAS ($catadasCount)',
              selected: filtroActivo == MuestraFiltro.catadas,
              onTap: () => onChanged(MuestraFiltro.catadas),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TabChip(
              label: 'DESCALIFICADAS ($descalificadasCount)',
              selected: filtroActivo == MuestraFiltro.descalificadas,
              onTap: () => onChanged(MuestraFiltro.descalificadas),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Colors.white
          : Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            label,
            style: DashboardType.label(
              color: selected
                  ? const Color(0xFF1B4332)
                  : Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
