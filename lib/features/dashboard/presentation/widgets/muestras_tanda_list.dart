import 'package:flutter/material.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';

class MuestrasTandaList extends StatelessWidget {
  const MuestrasTandaList({super.key, required this.muestras});

  final List<MuestraEnTanda> muestras;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (muestras.isEmpty) {
      return Center(
        child: Text(
          'Esta tanda no tiene muestras asignadas.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: muestras.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final muestra = muestras[index];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${muestra.orden}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        muestra.nombre,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (muestra.codigo.isNotEmpty ||
                          muestra.categoriaCata.isNotEmpty)
                        Text(
                          [
                            if (muestra.codigo.isNotEmpty)
                              'Cód. ${muestra.codigo}',
                            if (muestra.categoriaCata.isNotEmpty)
                              muestra.categoriaCata,
                          ].join(' · '),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  muestra.estadoLabel,
                  style: theme.textTheme.labelLarge?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
