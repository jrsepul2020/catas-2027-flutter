import 'package:flutter/material.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_colors.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';

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

  static const double height = 38;

  @override
  Widget build(BuildContext context) {
    final primario = DashboardColors.primario(colorPrimario);

    return SizedBox(
      height: height,
      child: Row(
        children: [
          _TabChip(
            label: 'CATADAS ($catadasCount)',
            selected: filtroActivo == MuestraFiltro.catadas,
            colorPrimario: primario,
            onTap: () => onChanged(MuestraFiltro.catadas),
          ),
          const SizedBox(width: 8),
          _TabChip(
            label: 'DESCALIFICADAS ($descalificadasCount)',
            selected: filtroActivo == MuestraFiltro.descalificadas,
            colorPrimario: primario,
            onTap: () => onChanged(MuestraFiltro.descalificadas),
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
    required this.colorPrimario,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color colorPrimario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colorPrimario : const Color(0xFFE8E8E8),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
