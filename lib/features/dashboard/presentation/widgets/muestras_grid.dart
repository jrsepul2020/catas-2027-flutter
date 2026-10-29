import 'package:flutter/material.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_colors.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';

class MuestrasGrid extends StatelessWidget {
  const MuestrasGrid({
    super.key,
    required this.muestras,
    required this.categoriaNombre,
    required this.colorPrimario,
    required this.onMuestraTap,
  });

  final List<MuestraEnTanda> muestras;
  final String categoriaNombre;
  final String? colorPrimario;
  final ValueChanged<MuestraEnTanda> onMuestraTap;

  static const int _columns = 6;
  static const double _spacing = 8;

  @override
  Widget build(BuildContext context) {
    if (muestras.isEmpty) {
      return Center(
        child: Text(
          'No hay muestras en esta sección.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        crossAxisSpacing: _spacing,
        mainAxisSpacing: _spacing,
        childAspectRatio: 1.45,
      ),
      itemCount: muestras.length,
      itemBuilder: (context, index) {
        return _MuestraCard(
          muestra: muestras[index],
          categoriaNombre: categoriaNombre,
          colorPrimario: DashboardColors.primario(colorPrimario),
          onTap: () => onMuestraTap(muestras[index]),
        );
      },
    );
  }
}

class _MuestraCard extends StatelessWidget {
  const _MuestraCard({
    required this.muestra,
    required this.categoriaNombre,
    required this.colorPrimario,
    required this.onTap,
  });

  final MuestraEnTanda muestra;
  final String categoriaNombre;
  final Color colorPrimario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pillLabel = DashboardMuestraUtils.pillLabel(muestra);
    final pillColor = _pillColor(pillLabel);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        muestra.codigoDisplay,
                        style: VirtusColors.titulo(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: VirtusColors.oscuro,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '#${muestra.orden}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  (muestra.categoriaCata?.isNotEmpty == true
                          ? muestra.categoriaCata!
                          : categoriaNombre)
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: pillColor.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      pillLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: pillColor.foreground,
                        letterSpacing: 0.2,
                      ),
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

  ({Color background, Color foreground}) _pillColor(String label) {
    return switch (label) {
      'CATADA' => (
          background: DashboardColors.pillActiva(colorPrimario),
          foreground: DashboardColors.oscuro(colorPrimario),
        ),
      'ACTIVA' => (
          background: VirtusColors.fondoSuave,
          foreground: VirtusColors.primario,
        ),
      'DESCALIF.' => (
          background: const Color(0xFFE0ECE4),
          foreground: VirtusColors.oscuro,
        ),
      'POSPUESTA' => (
          background: VirtusColors.muyClaro,
          foreground: VirtusColors.secundario,
        ),
      _ => (
          background: const Color(0xFFE8F0EA),
          foreground: VirtusColors.secundario,
        ),
    };
  }
}
