import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_medalla_widget.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/enviar_button_v4.dart';
import 'package:virtus2027/features/cata/presentation/v5/cata_v5_theme.dart';

/// Panel derecho V5: total en vivo, escala pedida por catadores, enviar.
class CataResumenV5 extends StatelessWidget {
  const CataResumenV5({
    super.key,
    required this.totalActual,
    required this.totalMin,
    required this.totalMax,
    required this.criteriosCompletos,
    required this.criteriosTotal,
    required this.categoriaNombre,
    required this.readOnly,
    required this.guardando,
    required this.fichaCompleta,
    required this.onEnviar,
    this.umbrales = MedallaUmbrales.defecto,
    this.onReiniciar,
    this.onIncidencia,
    this.bannerEnvio,
    this.selectorVersion,
    this.estiloBotones = CataBotonesEstiloV5.pastel,
    this.onEstiloBotonesChanged,
  });

  final double totalActual;
  final double totalMin;
  final double totalMax;
  final int criteriosCompletos;
  final int criteriosTotal;
  final String categoriaNombre;
  final bool readOnly;
  final bool guardando;
  final bool fichaCompleta;
  final VoidCallback onEnviar;
  final MedallaUmbrales umbrales;
  final VoidCallback? onReiniciar;
  final VoidCallback? onIncidencia;
  final String? bannerEnvio;
  final Widget? selectorVersion;
  final CataBotonesEstiloV5 estiloBotones;
  final ValueChanged<CataBotonesEstiloV5>? onEstiloBotonesChanged;

  static const _margenPanel = 10.0;

  String _fmt(double v) =>
      v.truncateToDouble() == v ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final medalla = CataMedalla.evaluar(
      total: totalActual,
      totalMin: totalMin,
      totalMax: totalMax,
      umbrales: umbrales,
    );
    // En vivo desde la primera pulsación (no espera a completar la ficha).
    final visual = medalla.label.aMedallaVisual;
    final hayPremio = visual != CataMedallaVisual.ninguna;
    final nombreMedalla = hayPremio ? medalla.label : 'SIN MEDALLA';
    final totalTexto = _fmt(totalActual);
    final pieEnvio = hayPremio
        ? '$totalTexto puntos · ${_tituloCorto(medalla.label)}'
        : '$totalTexto puntos · Sin medalla';
    final mostrarAcciones = !readOnly && onReiniciar != null;

    return Padding(
      padding: const EdgeInsets.all(_margenPanel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (selectorVersion != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: selectorVersion!,
            ),
            const SizedBox(height: 6),
          ],
          if (onEstiloBotonesChanged != null) ...[
            _EstiloBotonesToggle(
              estilo: estiloBotones,
              onChanged: onEstiloBotonesChanged!,
            ),
            const SizedBox(height: 6),
          ],
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CataV5Theme.tarjeta,
                borderRadius: BorderRadius.circular(CataV5Theme.radioTarjeta),
                border: Border.all(color: CataV5Theme.borde),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'PUNTUACIÓN TOTAL',
                              textAlign: TextAlign.center,
                              style: CataV2Theme.text(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: CataV5Theme.textoMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              totalTexto,
                              textAlign: TextAlign.center,
                              style: CataV2Theme.text(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: CataV5Theme.rojoTotal,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CataMedallaWidget(
                                  variante: visual,
                                  size: 44,
                                  mostrarTexto: false,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    nombreMedalla,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: CataV2Theme.text(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: hayPremio
                                          ? const Color(0xFF5D4037)
                                          : CataV5Theme.textoMuted,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _EscalaPremiosFila(
                              total: totalActual,
                              umbrales: umbrales,
                              fmt: _fmt,
                            ),
                            const SizedBox(height: 10),
                            _BarraProgreso(
                              completos: criteriosCompletos,
                              total: criteriosTotal,
                            ),
                            if (bannerEnvio != null &&
                                bannerEnvio!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _BannerEnvio(texto: bannerEnvio!),
                            ],
                            const SizedBox(height: 8),
                            if (readOnly)
                              Text(
                                'Puntuación aprobada\n(solo lectura)',
                                textAlign: TextAlign.center,
                                style: CataV2Theme.text(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: CataV5Theme.textoMuted,
                                ),
                              )
                            else ...[
                              EnviarButtonV4(
                                fichaCompleta: fichaCompleta,
                                faltanCriterios:
                                    (criteriosTotal - criteriosCompletos)
                                        .clamp(0, 99),
                                guardando: guardando,
                                onEnviar: onEnviar,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pieEnvio,
                                textAlign: TextAlign.center,
                                style: CataV2Theme.text(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: CataV5Theme.textoMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: CataV2Theme.fondoCategoria(
                                  categoriaNombre,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: CataV5Theme.borde),
                              ),
                              child: Text(
                                categoriaNombre,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CataV2Theme.text(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: CataV2Theme.textoCategoria(
                                    categoriaNombre,
                                  ),
                                ),
                              ),
                            ),
                            if (mostrarAcciones) ...[
                              const SizedBox(height: 8),
                              _AccionesIcono(
                                onReiniciar: readOnly ? null : onReiniciar,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tituloCorto(String label) {
    final u = label.toUpperCase();
    if (u.contains('GRAN')) return 'Gran Oro';
    if (u.contains('ORO')) return 'Oro';
    if (u.contains('PLATA')) return 'Plata';
    return label;
  }
}

class _EstiloBotonesToggle extends StatelessWidget {
  const _EstiloBotonesToggle({
    required this.estilo,
    required this.onChanged,
  });

  final CataBotonesEstiloV5 estilo;
  final ValueChanged<CataBotonesEstiloV5> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CataV5Theme.tarjeta,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CataV5Theme.borde),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Estilo de botones',
              style: CataV2Theme.text(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: CataV5Theme.textoMuted,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _EstiloChip(
                    label: 'A Pastel',
                    selected: estilo == CataBotonesEstiloV5.pastel,
                    onTap: () => onChanged(CataBotonesEstiloV5.pastel),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _EstiloChip(
                    label: 'B Contorno',
                    selected: estilo == CataBotonesEstiloV5.contorno,
                    onTap: () => onChanged(CataBotonesEstiloV5.contorno),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EstiloChip extends StatelessWidget {
  const _EstiloChip({
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
      color: selected ? CataV2Theme.cabecera : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: CataV2Theme.text(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : CataV5Theme.texto,
            ),
          ),
        ),
      ),
    );
  }
}

/// Escala en una sola fila: PLATA 85 · ORO 89 · GRAN ORO 93 (≥16 px).
class _EscalaPremiosFila extends StatelessWidget {
  const _EscalaPremiosFila({
    required this.total,
    required this.umbrales,
    required this.fmt,
  });

  final double total;
  final MedallaUmbrales umbrales;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CataV5Theme.borde),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _UmbralChip(
                titulo: 'PLATA',
                valor: fmt(umbrales.plata),
                encendida: total >= umbrales.plata,
                color: const Color(0xFF78909C),
              ),
            ),
            _SeparadorPunto(encendido: total >= umbrales.oro),
            Expanded(
              child: _UmbralChip(
                titulo: 'ORO',
                valor: fmt(umbrales.oro),
                encendida: total >= umbrales.oro,
                color: const Color(0xFFF9A825),
              ),
            ),
            _SeparadorPunto(encendido: total >= umbrales.granOro),
            Expanded(
              flex: 2,
              child: _UmbralChip(
                titulo: 'GRAN ORO',
                valor: fmt(umbrales.granOro),
                encendida: total >= umbrales.granOro,
                color: const Color(0xFFFFD54F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeparadorPunto extends StatelessWidget {
  const _SeparadorPunto({required this.encendido});

  final bool encendido;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        '·',
        style: CataV2Theme.text(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: encendido ? CataV5Theme.texto : CataV5Theme.textoMuted,
        ),
      ),
    );
  }
}

class _UmbralChip extends StatelessWidget {
  const _UmbralChip({
    required this.titulo,
    required this.valor,
    required this.encendida,
    required this.color,
  });

  final String titulo;
  final String valor;
  final bool encendida;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: CataV2Theme.animSeleccion,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: encendida ? color.withValues(alpha: 0.32) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CataV2Theme.text(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: encendida ? CataV5Theme.texto : CataV5Theme.textoMuted,
              height: 1.05,
            ),
          ),
          Text(
            valor,
            textAlign: TextAlign.center,
            style: CataV2Theme.text(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: encendida ? CataV5Theme.texto : CataV5Theme.textoMuted,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraProgreso extends StatelessWidget {
  const _BarraProgreso({required this.completos, required this.total});

  final int completos;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total <= 0 ? 0.0 : (completos / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$completos de $total',
          textAlign: TextAlign.center,
          style: CataV2Theme.text(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: CataV5Theme.texto,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            color: ratio >= 1
                ? const Color(0xFF2E7D32)
                : CataV5Theme.rojoTotal,
          ),
        ),
      ],
    );
  }
}

class _BannerEnvio extends StatelessWidget {
  const _BannerEnvio({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final ok = texto.startsWith('Enviada');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFFE8F5E9) : CataV5Theme.rojoAccionFondo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ok ? const Color(0xFF81C784) : CataV5Theme.rojoAccionBorde,
        ),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: CataV2Theme.text(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: ok ? const Color(0xFF2E7D32) : CataV5Theme.rojoAccion,
        ),
      ),
    );
  }
}

class _AccionesIcono extends StatelessWidget {
  const _AccionesIcono({this.onReiniciar});

  final VoidCallback? onReiniciar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onReiniciar != null)
          _AccionIconoBoton(
            icon: Icons.refresh_outlined,
            label: 'Reiniciar puntuación',
            onPressed: onReiniciar,
            foreground: CataV5Theme.rojoAccion,
            background: CataV5Theme.rojoAccionFondo,
            border: CataV5Theme.rojoAccionBorde,
          ),
      ],
    );
  }
}

class _AccionIconoBoton extends StatelessWidget {
  const _AccionIconoBoton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color foreground;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: foreground),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CataV2Theme.text(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: foreground,
            height: 1.1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          side: BorderSide(color: border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
