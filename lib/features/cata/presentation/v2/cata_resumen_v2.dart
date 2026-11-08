import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_medalla_widget.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';

/// Panel derecho V2: rangos → total → medalla → muestra → enviar → resto.
class CataResumenV2 extends StatelessWidget {
  const CataResumenV2({
    super.key,
    required this.totalActual,
    required this.totalMin,
    required this.totalMax,
    required this.faltanCriterios,
    required this.criteriosCompletos,
    required this.criteriosTotal,
    required this.codigoMuestra,
    required this.categoriaNombre,
    required this.nombreCriterioUnicoPendiente,
    required this.readOnly,
    required this.guardando,
    required this.fichaCompleta,
    required this.onEnviar,
    this.umbrales = MedallaUmbrales.defecto,
    this.onReiniciar,
    this.onDescartar,
    this.bannerEnvio,
  });

  final double totalActual;
  final double totalMin;
  final double totalMax;
  final int faltanCriterios;
  final int criteriosCompletos;
  final int criteriosTotal;
  final String codigoMuestra;
  final String categoriaNombre;
  final String? nombreCriterioUnicoPendiente;
  final bool readOnly;
  final bool guardando;
  final bool fichaCompleta;
  final VoidCallback onEnviar;
  final MedallaUmbrales umbrales;
  final VoidCallback? onReiniciar;
  final VoidCallback? onDescartar;
  final String? bannerEnvio;

  static const _rojoPastel = Color(0xFFFFEBEE);
  static const _rojoPastelBorde = Color(0xFFEF9A9A);
  static const _rojoPastelTexto = Color(0xFFC62828);
  static const _rojoPuntos = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    final totalTexto = totalActual.toStringAsFixed(
      totalActual.truncateToDouble() == totalActual ? 0 : 1,
    );
    final medalla = CataMedalla.evaluar(
      total: totalActual,
      totalMin: totalMin,
      totalMax: totalMax,
      umbrales: umbrales,
    );
    final visual = medalla.label.aMedallaVisual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: CataV2Theme.superficie,
              borderRadius: BorderRadius.circular(CataV2Theme.radio),
              border: Border.all(color: CataV2Theme.borde),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Rangos de medalla (negrita, bien visible).
                  _RangosMedalla(umbrales: umbrales),
                  const SizedBox(height: 12),

                  // 2. Título puntuación total.
                  Text(
                    'PUNTUACIÓN TOTAL',
                    textAlign: TextAlign.center,
                    style: CataV2Theme.text(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: CataV2Theme.textoMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 3. Puntos (rojo).
                  Text(
                    totalTexto,
                    textAlign: TextAlign.center,
                    style: CataV2Theme.text(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: _rojoPuntos,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 4. Medalla.
                  if (visual != CataMedallaVisual.ninguna)
                    CataMedallaWidget(variante: visual, size: 64)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'SIN MEDALLA',
                        textAlign: TextAlign.center,
                        style: CataV2Theme.text(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: CataV2Theme.textoSecundario,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),
                  const Divider(height: 1, color: CataV2Theme.borde),
                  const SizedBox(height: 10),

                  // 5. Número de muestra + código + categoría.
                  Text(
                    'NÚMERO DE MUESTRA',
                    textAlign: TextAlign.center,
                    style: CataV2Theme.text(
                      fontSize: 10,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: CataV2Theme.texto,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: CataV2Theme.textoCategoria(categoriaNombre),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1, color: CataV2Theme.borde),
                  const SizedBox(height: 10),

                  if (bannerEnvio != null && bannerEnvio!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bannerEnvio!.startsWith('Enviada')
                            ? const Color(0xFFE8F5E9)
                            : _rojoPastel,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: bannerEnvio!.startsWith('Enviada')
                              ? const Color(0xFF81C784)
                              : _rojoPastelBorde,
                        ),
                      ),
                      child: Text(
                        bannerEnvio!,
                        textAlign: TextAlign.center,
                        style: CataV2Theme.text(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: bannerEnvio!.startsWith('Enviada')
                              ? const Color(0xFF2E7D32)
                              : _rojoPastelTexto,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 6. Enviar (más alto).
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
                    _EnviarButton(
                      fichaCompleta: fichaCompleta,
                      guardando: guardando,
                      onEnviar: onEnviar,
                    ),

                  const Spacer(),

                  // Resto (secundario).
                  Text(
                    '$criteriosCompletos de $criteriosTotal criterios',
                    textAlign: TextAlign.center,
                    style: CataV2Theme.text(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CataV2Theme.textoSecundario,
                    ),
                  ),
                  if (!fichaCompleta) ...[
                    const SizedBox(height: 4),
                    Text(
                      faltanCriterios == 1 &&
                              nombreCriterioUnicoPendiente != null
                          ? 'Falta 1 criterio: $nombreCriterioUnicoPendiente'
                          : 'Faltan $faltanCriterios criterios',
                      textAlign: TextAlign.center,
                      style: CataV2Theme.text(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _rojoPastelTexto,
                      ),
                    ),
                  ],
                  if (!readOnly && onReiniciar != null) ...[
                    const SizedBox(height: 8),
                    _SecondaryButton(
                      label: 'REINICIAR',
                      icon: Icons.restart_alt,
                      onPressed: onReiniciar,
                    ),
                  ],
                  if (onDescartar != null) ...[
                    const SizedBox(height: 6),
                    _SecondaryButton(
                      label: 'DESCARTAR',
                      icon: Icons.close,
                      onPressed: onDescartar,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rangos en horizontal, negrita y bien visibles (desde Supabase).
class _RangosMedalla extends StatelessWidget {
  const _RangosMedalla({required this.umbrales});

  final MedallaUmbrales umbrales;

  String _fmt(double v) =>
      v.truncateToDouble() == v ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F1B),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'GRAN ORO ≥${_fmt(umbrales.granOro)}  ·  '
        'ORO ≥${_fmt(umbrales.oro)}  ·  '
        'PLATA ≥${_fmt(umbrales.plata)}',
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: CataV2Theme.text(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1.3,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

class _EnviarButton extends StatefulWidget {
  const _EnviarButton({
    required this.fichaCompleta,
    required this.guardando,
    required this.onEnviar,
  });

  final bool fichaCompleta;
  final bool guardando;
  final VoidCallback onEnviar;

  @override
  State<_EnviarButton> createState() => _EnviarButtonState();
}

class _EnviarButtonState extends State<_EnviarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: CataV2Theme.pulsoLento,
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _EnviarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final activo = widget.fichaCompleta && !widget.guardando && mounted;
    if (activo) {
      if (!_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      }
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completa = widget.fichaCompleta;
    final boton = SizedBox(
      height: 64,
      width: double.infinity,
      child: FilledButton(
        onPressed: widget.guardando ? null : widget.onEnviar,
        style: FilledButton.styleFrom(
          backgroundColor: completa
              ? CataV2Theme.botonEnviar
              : CataV2Theme.botonEnviarDisabled,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              CataV2Theme.botonEnviar.withValues(alpha: 0.4),
          elevation: completa ? 3 : 0,
          shadowColor: CataV2Theme.botonEnviar.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CataV2Theme.radio),
          ),
        ),
        child: widget.guardando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'ENVIAR PUNTUACIÓN',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: CataV2Theme.text(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );

    if (!completa) return boton;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_pulse.value);
          final scale = 1.0 + 0.04 * t;
          final glow = 0.18 + 0.22 * t;
          return Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CataV2Theme.radio + 2),
                boxShadow: [
                  BoxShadow(
                    color: CataV2Theme.botonEnviar.withValues(alpha: glow),
                    blurRadius: 10 + 6 * t,
                    spreadRadius: 1 + t,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: boton,
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          style: CataV2Theme.text(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: CataResumenV2._rojoPastelTexto,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: CataResumenV2._rojoPastelTexto,
          backgroundColor: CataResumenV2._rojoPastel,
          side: const BorderSide(
            color: CataResumenV2._rojoPastelBorde,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
