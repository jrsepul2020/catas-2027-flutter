import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestra_hero_card.dart';

class MuestrasPendientesList extends StatelessWidget {
  const MuestrasPendientesList({
    super.key,
    required this.muestras,
    required this.colorPrimario,
    this.categoriaNombre,
    this.onMuestraTap,
    this.muestraDestacadaId,
    this.destacadaEnCurso = false,
  });

  final List<MuestraEnTanda> muestras;
  final String? colorPrimario;
  final String? categoriaNombre;
  final ValueChanged<MuestraEnTanda>? onMuestraTap;
  final String? muestraDestacadaId;
  final bool destacadaEnCurso;

  static const Color _verdeCabecera = Color(0xFF2D6A4F);
  static const Color _verdeFondo = Color(0xFFE8F5E9);
  static const int filasMinimasVisibles = 24;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CataV2Theme.superficie,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _verdeCabecera.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: const BoxDecoration(
              color: _verdeFondo,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(8.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pending_actions_rounded,
                  size: 22,
                  color: _verdeCabecera,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'MUESTRAS PENDIENTES DE CATAR',
                    style: CataV2Theme.text(
                      color: _verdeCabecera,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _verdeCabecera,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${muestras.length}',
                    style: DashboardType.label(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: CataV2Theme.borde),
          Expanded(
            child: muestras.isEmpty
                ? Center(
                    child: Text(
                      'No hay muestras pendientes.',
                      style: DashboardType.body(
                        color: CataV2Theme.textoMuted,
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final extent =
                          (constraints.maxHeight / filasMinimasVisibles)
                              .clamp(15.0, 20.0);
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        itemExtent: extent,
                        itemCount: muestras.length,
                        itemBuilder: (context, index) {
                          final muestra = muestras[index];
                          final destacada = muestraDestacadaId != null &&
                              muestra.muestraId == muestraDestacadaId;
                          final cat = muestra.categoriaDisplay(
                            fallback: categoriaNombre,
                          );
                          return _PendienteRow(
                            muestra: muestra,
                            categoria: cat,
                            destacada: destacada,
                            etiqueta: destacada
                                ? (destacadaEnCurso
                                    ? 'En curso'
                                    : 'Siguiente')
                                : null,
                            onTap: onMuestraTap == null
                                ? null
                                : () => onMuestraTap!(muestra),
                          );
                        },
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
    required this.categoria,
    required this.destacada,
    this.etiqueta,
    this.onTap,
  });

  final MuestraEnTanda muestra;
  final String categoria;
  final bool destacada;
  final String? etiqueta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: destacada
          ? MuestrasPendientesList._verdeFondo
          : const Color(0xFFF7F8F7),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Text(
                '#${muestra.orden}',
                style: CataV2Theme.text(
                  color: MuestrasPendientesList._verdeCabecera,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: muestra.codigoDisplay,
                        style: CataV2Theme.text(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CataV2Theme.texto,
                        ),
                      ),
                      if (categoria.isNotEmpty)
                        TextSpan(
                          text: '  ·  $categoria',
                          style: CataV2Theme.text(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: CataV2Theme.textoSecundario,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (etiqueta != null)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: MuestrasPendientesList._verdeCabecera
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    etiqueta!,
                    style: CataV2Theme.text(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: MuestrasPendientesList._verdeCabecera,
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
