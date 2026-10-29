import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_colors.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';

class MuestrasList extends StatelessWidget {
  const MuestrasList({
    super.key,
    required this.muestras,
    required this.filtro,
    required this.colorPrimario,
    required this.onMuestraTap,
  });

  final List<MuestraEnTanda> muestras;
  final MuestraFiltro filtro;
  final String? colorPrimario;
  final ValueChanged<MuestraEnTanda> onMuestraTap;

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

    final accent = DashboardColors.primario(colorPrimario);
    final showCatadaDetails = filtro == MuestraFiltro.catadas;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          if (showCatadaDetails)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'MUESTRA',
                      style: _headerStyle(accent),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'HORA',
                      style: _headerStyle(accent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'MEDIA',
                      style: _headerStyle(accent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'CATADOR',
                      style: _headerStyle(accent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          if (showCatadaDetails) const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: muestras.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final muestra = muestras[index];
                return _MuestraListRow(
                  muestra: muestra,
                  accent: accent,
                  showCatadaDetails: showCatadaDetails,
                  pillLabel: DashboardMuestraUtils.pillLabel(muestra),
                  onTap: () => onMuestraTap(muestra),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(Color accent) {
    return VirtusTextStyles.plain(
      color: accent,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.3,
    );
  }
}

class _MuestraListRow extends StatelessWidget {
  const _MuestraListRow({
    required this.muestra,
    required this.accent,
    required this.showCatadaDetails,
    required this.pillLabel,
    required this.onTap,
  });

  final MuestraEnTanda muestra;
  final Color accent;
  final bool showCatadaDetails;
  final String pillLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: showCatadaDetails
              ? Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            muestra.codigoDisplay,
                            style: VirtusTextStyles.plain(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '#${muestra.orden}',
                            style: VirtusTextStyles.plain(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        muestra.horaCataLabel,
                        style: VirtusTextStyles.plain(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        muestra.puntuacionMediaLabel,
                        style: VirtusTextStyles.plain(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        muestra.puntuacionCatadorLabel,
                        style: VirtusTextStyles.plain(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: accent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Text(
                      '#${muestra.orden}',
                      style: VirtusTextStyles.plain(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        muestra.codigoDisplay,
                        style: VirtusTextStyles.plain(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        pillLabel,
                        style: VirtusTextStyles.plain(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
