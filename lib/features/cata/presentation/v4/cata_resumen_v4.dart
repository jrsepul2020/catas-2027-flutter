import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_medalla_widget.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/cata_v4_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/enviar_button_v4.dart';

/// Panel derecho V4: dos tarjetas (cata en directo + datos secundarios).
class CataResumenV4 extends StatelessWidget {
  const CataResumenV4({
    super.key,
    required this.totalActual,
    required this.totalMin,
    required this.totalMax,
    required this.criteriosCompletos,
    required this.criteriosTotal,
    required this.codigoMuestra,
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
  });

  final double totalActual;
  final double totalMin;
  final double totalMax;
  final int criteriosCompletos;
  final int criteriosTotal;
  final String codigoMuestra;
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

  static const _margenPanel = 12.0;
  static const _gapTarjetas = 12.0;

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
    final visual = fichaCompleta
        ? medalla.label.aMedallaVisual
        : CataMedallaVisual.ninguna;
    final nombreMedalla = fichaCompleta
        ? medalla.label
        : 'se mostrará al completar los $criteriosTotal';
    final totalTexto = fichaCompleta ? _fmt(totalActual) : '--';
    final mostrarAcciones =
        (!readOnly && onReiniciar != null) || onIncidencia != null;

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
            const SizedBox(height: 8),
          ],
          Expanded(
            child: _TarjetaA(
              totalTexto: totalTexto,
              visual: visual,
              nombreMedalla: nombreMedalla,
              fichaCompleta: fichaCompleta,
              totalActual: totalActual,
              umbrales: umbrales,
              fmt: _fmt,
              criteriosCompletos: criteriosCompletos,
              criteriosTotal: criteriosTotal,
              bannerEnvio: bannerEnvio,
              readOnly: readOnly,
              guardando: guardando,
              onEnviar: onEnviar,
            ),
          ),
          const SizedBox(height: _gapTarjetas),
          _TarjetaB(
            codigoMuestra: codigoMuestra,
            categoriaNombre: categoriaNombre,
            onReiniciar: readOnly ? null : onReiniciar,
            onIncidencia: onIncidencia,
            mostrarAcciones: mostrarAcciones,
          ),
        ],
      ),
    );
  }
}

/// Tarjeta protagonista: total + medalla + escala + progreso + enviar.
class _TarjetaA extends StatelessWidget {
  const _TarjetaA({
    required this.totalTexto,
    required this.visual,
    required this.nombreMedalla,
    required this.fichaCompleta,
    required this.totalActual,
    required this.umbrales,
    required this.fmt,
    required this.criteriosCompletos,
    required this.criteriosTotal,
    required this.readOnly,
    required this.guardando,
    required this.onEnviar,
    this.bannerEnvio,
  });

  final String totalTexto;
  final CataMedallaVisual visual;
  final String nombreMedalla;
  final bool fichaCompleta;
  final double totalActual;
  final MedallaUmbrales umbrales;
  final String Function(double) fmt;
  final int criteriosCompletos;
  final int criteriosTotal;
  final bool readOnly;
  final bool guardando;
  final VoidCallback onEnviar;
  final String? bannerEnvio;

  static const _gap = 10.0;
  /// Margen entre bloque medalla y bloque criterios/escala.
  static const _gapMedallaCriterios = 14.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CataV4Theme.tarjeta,
        borderRadius: BorderRadius.circular(CataV4Theme.radioTarjeta),
        border: Border.all(color: CataV4Theme.borde),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
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
                      color: CataV2Theme.textoMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    totalTexto,
                    textAlign: TextAlign.center,
                    style: CataV2Theme.text(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: CataV4Theme.rojoTotal,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: CataMedallaWidget(
                      variante: visual,
                      size: 64,
                      mostrarTexto: false,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nombreMedalla,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CataV2Theme.text(
                      fontSize: fichaCompleta ? 13 : 10,
                      fontWeight: FontWeight.w800,
                      color: fichaCompleta &&
                              visual != CataMedallaVisual.ninguna
                          ? const Color(0xFF5D4037)
                          : CataV2Theme.textoSecundario,
                      letterSpacing: 0.3,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: _gapMedallaCriterios),
                  _EscalaPremios(
                    total: totalActual,
                    umbrales: umbrales,
                    fmt: fmt,
                  ),
                  const SizedBox(height: _gap),
                  _BarraProgreso(
                    completos: criteriosCompletos,
                    total: criteriosTotal,
                  ),
                  if (bannerEnvio != null && bannerEnvio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _BannerEnvio(texto: bannerEnvio!),
                  ],
                  const SizedBox(height: _gap),
                  if (readOnly)
                    Text(
                      'Puntuación aprobada\n(solo lectura)',
                      textAlign: TextAlign.center,
                      style: CataV2Theme.text(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: CataV2Theme.textoMuted,
                      ),
                    )
                  else
                    EnviarButtonV4(
                      fichaCompleta: fichaCompleta,
                      faltanCriterios:
                          (criteriosTotal - criteriosCompletos).clamp(0, 99),
                      guardando: guardando,
                      onEnviar: onEnviar,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta secundaria: muestra + categoría + acciones (fondo blanco).
class _TarjetaB extends StatelessWidget {
  const _TarjetaB({
    required this.codigoMuestra,
    required this.categoriaNombre,
    required this.mostrarAcciones,
    this.onReiniciar,
    this.onIncidencia,
  });

  final String codigoMuestra;
  final String categoriaNombre;
  final bool mostrarAcciones;
  final VoidCallback? onReiniciar;
  final VoidCallback? onIncidencia;

  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CataV4Theme.tarjeta,
        borderRadius: BorderRadius.circular(CataV4Theme.radioTarjeta),
        border: Border.all(color: CataV4Theme.borde),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'NÚMERO DE MUESTRA',
              textAlign: TextAlign.center,
              style: CataV2Theme.text(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: CataV2Theme.textoMuted,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              codigoMuestra,
              textAlign: TextAlign.center,
              style: CataV2Theme.text(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: CataV4Theme.texto,
                height: 1.05,
              ),
            ),
            const SizedBox(height: _gap),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: CataV2Theme.fondoCategoria(categoriaNombre),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                categoriaNombre,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CataV2Theme.text(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CataV2Theme.textoCategoria(categoriaNombre),
                ),
              ),
            ),
            if (mostrarAcciones) ...[
              const SizedBox(height: 12),
              _AccionesColumna(
                onReiniciar: onReiniciar,
                onIncidencia: onIncidencia,
              ),
            ],
          ],
        ),
      ),
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
        color: ok ? const Color(0xFFE8F5E9) : CataV4Theme.rojoAccionFondo,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: ok ? const Color(0xFF81C784) : CataV4Theme.rojoAccionBorde,
        ),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: CataV2Theme.text(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: ok ? const Color(0xFF2E7D32) : CataV4Theme.rojoAccion,
        ),
      ),
    );
  }
}

class _EscalaPremios extends StatelessWidget {
  const _EscalaPremios({
    required this.total,
    required this.umbrales,
    required this.fmt,
  });

  final double total;
  final MedallaUmbrales umbrales;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    final nivel = total >= umbrales.granOro
        ? 3
        : total >= umbrales.oro
            ? 2
            : total >= umbrales.plata
                ? 1
                : 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _CasillaPremio(
            titulo: 'PLATA',
            valor: fmt(umbrales.plata),
            encendida: nivel == 1,
            color: const Color(0xFF78909C),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: _CasillaPremio(
            titulo: 'ORO',
            valor: fmt(umbrales.oro),
            encendida: nivel == 2,
            color: const Color(0xFFF9A825),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: _CasillaPremio(
            titulo: 'GRAN ORO',
            valor: fmt(umbrales.granOro),
            encendida: nivel == 3,
            color: const Color(0xFFFFD54F),
          ),
        ),
      ],
    );
  }
}

class _CasillaPremio extends StatelessWidget {
  const _CasillaPremio({
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
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      decoration: BoxDecoration(
        color: encendida ? color.withValues(alpha: 0.35) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: encendida ? color : CataV4Theme.borde,
          width: encendida ? 1.5 : 1,
        ),
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
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: encendida ? CataV4Theme.texto : CataV2Theme.textoMuted,
              height: 1.1,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            textAlign: TextAlign.center,
            style: CataV2Theme.text(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: encendida ? CataV4Theme.texto : CataV2Theme.textoSecundario,
              height: 1.0,
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
          '$completos de $total criterios',
          textAlign: TextAlign.center,
          style: CataV2Theme.text(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: CataV4Theme.texto,
          ),
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: const Color(0xFFE0E0E0),
            color: ratio >= 1
                ? const Color(0xFF2E7D32)
                : CataV4Theme.rojoTotal,
          ),
        ),
      ],
    );
  }
}

class _AccionesColumna extends StatelessWidget {
  const _AccionesColumna({this.onReiniciar, this.onIncidencia});

  final VoidCallback? onReiniciar;
  final VoidCallback? onIncidencia;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onReiniciar != null)
          _AccionBoton(
            label: 'Reiniciar puntuación',
            onPressed: onReiniciar,
            foreground: CataV4Theme.rojoAccion,
            background: CataV4Theme.rojoAccionFondo,
            border: CataV4Theme.rojoAccionBorde,
          ),
        if (onReiniciar != null && onIncidencia != null)
          const SizedBox(height: 8),
        if (onIncidencia != null)
          _AccionBoton(
            label: 'Incidencia',
            onPressed: onIncidencia,
            foreground: CataV4Theme.naranjaAccion,
            background: CataV4Theme.naranjaAccionFondo,
            border: CataV4Theme.naranjaAccionBorde,
          ),
      ],
    );
  }
}

class _AccionBoton extends StatelessWidget {
  const _AccionBoton({
    required this.label,
    required this.onPressed,
    required this.foreground,
    required this.background,
    required this.border,
  });

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
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          side: BorderSide(color: border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CataV2Theme.text(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: foreground,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
