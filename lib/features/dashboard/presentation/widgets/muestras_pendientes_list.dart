import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_colors.dart';

class MuestrasPendientesList extends StatelessWidget {
  const MuestrasPendientesList({
    super.key,
    required this.muestras,
    required this.colorPrimario,
    this.onMuestraTap,
  });

  final List<MuestraEnTanda> muestras;
  final String? colorPrimario;
  final ValueChanged<MuestraEnTanda>? onMuestraTap;

  @override
  Widget build(BuildContext context) {
    final accent = DashboardColors.primario(colorPrimario);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Text(
              'PENDIENTES (${muestras.length})',
              style: VirtusTextStyles.plain(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: muestras.isEmpty
                ? Center(
                    child: Text(
                      'No hay muestras pendientes.',
                      style: VirtusTextStyles.plain(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    itemCount: muestras.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final muestra = muestras[index];
                      return _PendienteRow(
                        muestra: muestra,
                        accent: accent,
                        onTap: onMuestraTap == null
                            ? null
                            : () => onMuestraTap!(muestra),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PendienteRow extends StatelessWidget {
  const _PendienteRow({
    required this.muestra,
    required this.accent,
    this.onTap,
  });

  final MuestraEnTanda muestra;
  final Color accent;
  final VoidCallback? onTap;

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
          child: Row(
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
            ],
          ),
        ),
      ),
    );
  }
}
