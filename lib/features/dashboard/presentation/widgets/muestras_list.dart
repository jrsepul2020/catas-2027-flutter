import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestra_hero_card.dart';

/// Panel de catadas / descalificadas (verde corporativo, texto blanco).
class MuestrasList extends StatelessWidget {
  const MuestrasList({
    super.key,
    required this.muestras,
    required this.filtro,
    required this.colorPrimario,
    required this.onMuestraTap,
    this.categoriaFallback,
    this.readOnly = false,
    this.compactCodigoCategoria = false,
  });

  final List<MuestraEnTanda> muestras;
  final MuestraFiltro filtro;
  final String? colorPrimario;
  final ValueChanged<MuestraEnTanda>? onMuestraTap;
  final String? categoriaFallback;
  final bool readOnly;
  /// Conservado por compatibilidad; el layout catadas ya une código·categoría.
  final bool compactCodigoCategoria;

  static const int filasMinimasVisibles = 24;
  static const Color verde = CataV2Theme.cabecera;
  static const Color verdeClaro = Color(0xFF2D6A4F);

  @override
  Widget build(BuildContext context) {
    if (muestras.isEmpty) {
      return Center(
        child: Text(
          'No hay muestras en esta sección.',
          style: DashboardType.body(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    final showCatadaDetails = filtro == MuestraFiltro.catadas;

    return Column(
      children: [
        if (showCatadaDetails)
          const Padding(
            padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: _ColHeader('#', center: true, soft: true),
                ),
                Expanded(child: _ColHeader('CÓDIGO · CATEGORÍA')),
                SizedBox(width: 76, child: _ColHeader('MEDALLA', center: true)),
                SizedBox(width: 40, child: _ColHeader('PTS', center: true)),
                SizedBox(width: 54, child: _ColHeader('ESTADO', center: true)),
              ],
            ),
          ),
        if (showCatadaDetails)
          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final extent = (constraints.maxHeight / filasMinimasVisibles)
                  .clamp(15.0, 20.0);
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemExtent: extent,
                itemCount: muestras.length,
                itemBuilder: (context, index) {
                  final muestra = muestras[index];
                  return _MuestraListRow(
                    muestra: muestra,
                    showCatadaDetails: showCatadaDetails,
                    categoriaFallback: categoriaFallback,
                    pillLabel: DashboardMuestraUtils.pillLabel(muestra),
                    onTap: readOnly || onMuestraTap == null
                        ? null
                        : () => onMuestraTap!(muestra),
                    zebra: index.isOdd,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.text, {this.center = false, this.soft = false});

  final String text;
  final bool center;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: DashboardType.label(
        color: Colors.white.withValues(alpha: soft ? 0.28 : 0.65),
      ),
    );
  }
}

class _MuestraListRow extends StatelessWidget {
  const _MuestraListRow({
    required this.muestra,
    required this.showCatadaDetails,
    required this.pillLabel,
    required this.zebra,
    this.categoriaFallback,
    this.onTap,
  });

  final MuestraEnTanda muestra;
  final bool showCatadaDetails;
  final String pillLabel;
  final bool zebra;
  final String? categoriaFallback;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final categoria = muestra.categoriaDisplay(fallback: categoriaFallback);
    final medalla = _medallaFromScore(muestra.puntuacionMedia);

    return Material(
      color: zebra
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: showCatadaDetails
              ? Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        '${muestra.orden}',
                        style: CataV2Theme.text(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: muestra.codigoDisplay,
                              style: CataV2Theme.text(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (categoria.isNotEmpty)
                              TextSpan(
                                text: '  ·  $categoria',
                                style: CataV2Theme.text(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 76,
                      child: Center(child: _MedallaChip(medalla: medalla)),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        muestra.puntuacionMediaLabel,
                        style: CataV2Theme.text(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 54,
                      child: Text(
                        pillLabel,
                        style: CataV2Theme.text(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Text(
                      '#${muestra.orden}',
                      style: CataV2Theme.text(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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
                                color: Colors.white,
                              ),
                            ),
                            if (categoria.isNotEmpty)
                              TextSpan(
                                text: '  ·  $categoria',
                                style: CataV2Theme.text(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      pillLabel,
                      style: CataV2Theme.text(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

({String label, Color fg, Color bg}) _medallaFromScore(double? score) {
  if (score == null) {
    return (
      label: 'SIN MEDALLA',
      fg: Colors.white70,
      bg: Colors.white24,
    );
  }
  final m = CataMedalla.evaluar(total: score);
  return switch (m.label) {
    'GRAN ORO' => (
        label: 'GRAN ORO',
        fg: const Color(0xFF3E2723),
        bg: const Color(0xFFFFD54F),
      ),
    'ORO' => (
        label: 'ORO',
        fg: const Color(0xFF3E2723),
        bg: const Color(0xFFFFB300),
      ),
    'PLATA' => (
        label: 'PLATA',
        fg: const Color(0xFF263238),
        bg: const Color(0xFFCFD8DC),
      ),
    _ => (
        label: 'SIN MEDALLA',
        fg: Colors.white70,
        bg: Colors.white24,
      ),
  };
}

class _MedallaChip extends StatelessWidget {
  const _MedallaChip({required this.medalla});

  final ({String label, Color fg, Color bg}) medalla;

  @override
  Widget build(BuildContext context) {
    if (medalla.label == 'SIN MEDALLA') {
      return Text(
        'SIN MEDALLA',
        style: DashboardType.label(color: Colors.white54).copyWith(fontSize: 8),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: medalla.bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        medalla.label,
        style: DashboardType.label(color: medalla.fg).copyWith(fontSize: 9),
        maxLines: 1,
      ),
    );
  }
}
