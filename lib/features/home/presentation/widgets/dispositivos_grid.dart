import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/home/domain/dispositivo_home_item.dart';
import 'package:virtus2027/features/home/presentation/widgets/dispositivo_card.dart';

class DispositivosGrid extends StatelessWidget {
  const DispositivosGrid({
    super.key,
    required this.dispositivos,
    required this.onDispositivoTap,
  });

  final List<DispositivoHomeItem> dispositivos;
  final ValueChanged<DispositivoHomeItem> onDispositivoTap;

  @override
  Widget build(BuildContext context) {
    if (dispositivos.isEmpty) {
      return Center(
        child: Text(
          'No hay dispositivos configurados.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final porMesa = _agruparPorMesa(dispositivos);
    final mesas = porMesa.keys.toList()..sort();

    return Padding(
      padding: TabletLayout.screenPadding.copyWith(top: 6),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: mesas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final mesaNumero = mesas[index];
          final items = porMesa[mesaNumero]!
            ..sort((a, b) => a.deviceId.compareTo(b.deviceId));

          return _MesaRow(
            mesaNumero: mesaNumero,
            dispositivos: items,
            onDispositivoTap: onDispositivoTap,
          );
        },
      ),
    );
  }

  Map<int, List<DispositivoHomeItem>> _agruparPorMesa(
    List<DispositivoHomeItem> items,
  ) {
    final map = <int, List<DispositivoHomeItem>>{};
    for (final item in items) {
      final key = item.mesaNumero ?? 0;
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
}

class _MesaRow extends StatelessWidget {
  const _MesaRow({
    required this.mesaNumero,
    required this.dispositivos,
    required this.onDispositivoTap,
  });

  final int mesaNumero;
  final List<DispositivoHomeItem> dispositivos;
  final ValueChanged<DispositivoHomeItem> onDispositivoTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: VirtusColors.primario.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
              border: Border.all(
                color: VirtusColors.primario.withValues(alpha: 0.35),
              ),
            ),
            child: SizedBox(
              width: 52,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MESA',
                      style: VirtusTextStyles.plain(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: VirtusColors.oscuro,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      mesaNumero == 0 ? '—' : '$mesaNumero',
                      style: VirtusTextStyles.plain(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: VirtusColors.primario,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < dispositivos.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: DispositivoCard(
                      item: dispositivos[i],
                      showMesaEnTarjeta: false,
                      onTap: () => onDispositivoTap(dispositivos[i]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
