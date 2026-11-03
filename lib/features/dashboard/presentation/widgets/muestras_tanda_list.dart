import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_viewport.dart';
import 'package:virtus2027/core/models/catador.dart';
import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/models/tanda.dart';
import 'package:virtus2027/features/cata/presentation/cata_page.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_estado_style.dart';

class MuestrasTandaList extends StatelessWidget {
  const MuestrasTandaList({
    super.key,
    required this.muestras,
    required this.tanda,
    required this.catador,
    this.categoria,
    this.colorPrimario,
  });

  final List<MuestraEnTanda> muestras;
  final Tanda tanda;
  final Catador catador;
  final Categoria? categoria;
  final String? colorPrimario;

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
        final estadoKey = muestra.estado ?? '';
        final estado = DashboardEstadoStyle.muestra(estadoKey);
        final codigo = muestra.codigoDisplay;
        final estadoLabel = muestra.estadoLabel;

        return Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _abrirCata(context, muestra),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${muestra.orden}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        codigo,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _EstadoIndicador(
                      dotColor: estado.dot,
                      textColor: estado.text,
                      label: estadoLabel,
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _abrirCata(BuildContext context, MuestraEnTanda muestra) {
    final cat = categoria;
    if (cat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay categoría asignada a esta tanda.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => TabletViewport(
          child: CataPage(
            muestra: muestra,
            tanda: tanda,
            categoria: cat,
            catador: catador,
            esPresidente: catador.rol?.toLowerCase() == 'presidente',
            mesaId: catador.mesaId,
            colorPrimario: colorPrimario,
            tandaMuestrasTotal: muestras.length,
          ),
        ),
      ),
    );
  }
}

class _EstadoIndicador extends StatelessWidget {
  const _EstadoIndicador({
    required this.dotColor,
    required this.textColor,
    required this.label,
  });

  final Color dotColor;
  final Color textColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
