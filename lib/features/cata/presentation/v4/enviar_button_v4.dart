import 'dart:async';

import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v4/cata_v4_theme.dart';

/// Botón ENVIAR V4: estados + efecto único al completar + aro recordatorio.
///
/// Anima solo scale/opacidad. Un [AnimationController]. Timers cancelados en
/// [dispose]. Sin red, modales, sonido ni vibración.
class EnviarButtonV4 extends StatefulWidget {
  const EnviarButtonV4({
    super.key,
    required this.fichaCompleta,
    required this.faltanCriterios,
    required this.guardando,
    required this.onEnviar,
  });

  final bool fichaCompleta;
  final int faltanCriterios;
  final bool guardando;
  final VoidCallback onEnviar;

  @override
  State<EnviarButtonV4> createState() => _EnviarButtonV4State();
}

class _EnviarButtonV4State extends State<EnviarButtonV4>
    with SingleTickerProviderStateMixin {
  static const _duracionFx = Duration(milliseconds: 900);
  static const _esperaRecordatorio = Duration(seconds: 6);
  static const _periodoRecordatorio = Duration(seconds: 8);

  late final AnimationController _fx;
  Timer? _armReminder;
  Timer? _tickReminder;

  /// true = celebración (aro + destello); false = solo aro.
  bool _conDestello = false;

  @override
  void initState() {
    super.initState();
    _fx = AnimationController(vsync: this, duration: _duracionFx);
    // Ya completa al abrir (sin celebración): solo armar recordatorio.
    if (widget.fichaCompleta && !widget.guardando) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _programarRecordatorio();
      });
    }
  }

  @override
  void didUpdateWidget(covariant EnviarButtonV4 oldWidget) {
    super.didUpdateWidget(oldWidget);

    final pasoACompleta =
        !oldWidget.fichaCompleta && widget.fichaCompleta && !widget.guardando;
    final volvioIncompleta = oldWidget.fichaCompleta && !widget.fichaCompleta;
    final enviando = !oldWidget.guardando && widget.guardando;

    if (pasoACompleta) {
      // Solo en el cambio incompleta → completa (una vez por ciclo).
      _lanzarCelebracion();
      _programarRecordatorio();
    } else if (volvioIncompleta || enviando) {
      _detenerTodo();
    }
  }

  void _lanzarCelebracion() {
    _conDestello = true;
    _fx.forward(from: 0);
  }

  void _lanzarSoloAro() {
    if (!mounted || !widget.fichaCompleta || widget.guardando) return;
    if (_fx.isAnimating && _conDestello) return;
    _conDestello = false;
    _fx.forward(from: 0);
  }

  void _programarRecordatorio() {
    _cancelarTimers();
    if (!widget.fichaCompleta || widget.guardando) return;
    _armReminder = Timer(_esperaRecordatorio, () {
      _armReminder = null;
      if (!mounted || !widget.fichaCompleta || widget.guardando) return;
      _lanzarSoloAro();
      _tickReminder = Timer.periodic(_periodoRecordatorio, (_) {
        _lanzarSoloAro();
      });
    });
  }

  void _cancelarTimers() {
    _armReminder?.cancel();
    _armReminder = null;
    _tickReminder?.cancel();
    _tickReminder = null;
  }

  void _detenerTodo() {
    _cancelarTimers();
    _fx.stop();
    _fx.value = 0;
    _conDestello = false;
  }

  @override
  void dispose() {
    _cancelarTimers();
    _fx.dispose();
    super.dispose();
  }

  void _onPressed() {
    if (!widget.fichaCompleta || widget.guardando) return;
    _cancelarTimers();
    widget.onEnviar();
  }

  @override
  Widget build(BuildContext context) {
    final completa = widget.fichaCompleta;
    final radio = BorderRadius.circular(CataV4Theme.radioBoton);

    return RepaintBoundary(
      child: SizedBox(
        height: 58,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Aro expandible (fuera del clip del botón).
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _fx,
                  builder: (context, _) {
                    if (_fx.value <= 0) return const SizedBox.shrink();
                    final t = Curves.easeOut.transform(_fx.value);
                    return Transform.scale(
                      scale: 1.0 + 0.42 * t,
                      child: Opacity(
                        opacity: (1.0 - t).clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              CataV4Theme.radioBoton + 4,
                            ),
                            border: Border.all(
                              color: const Color(0xFF66BB6A),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: completa && !widget.guardando ? _onPressed : null,
                  borderRadius: radio,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: completa
                          ? CataV2Theme.botonEnviar
                          : CataV2Theme.botonEnviarDisabled,
                      borderRadius: radio,
                    ),
                    child: ClipRRect(
                      borderRadius: radio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(child: _label(completa)),
                          if (_conDestello)
                            IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _fx,
                                builder: (context, _) {
                                  // Destello ~700 ms del total 900 ms.
                                  final s =
                                      (_fx.value / (700 / 900)).clamp(0.0, 1.0);
                                  if (s <= 0 || s >= 1) {
                                    return const SizedBox.shrink();
                                  }
                                  final opacidad = (s < 0.45
                                          ? s / 0.45
                                          : (1.0 - s) / 0.55)
                                      .clamp(0.0, 0.55);
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Transform.scale(
                                      alignment: Alignment.centerLeft,
                                      scaleX: s.clamp(0.08, 1.0),
                                      child: Opacity(
                                        opacity: opacidad,
                                        child: const DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0x00FFFFFF),
                                                Color(0xB3FFFFFF),
                                                Color(0x00FFFFFF),
                                              ],
                                            ),
                                          ),
                                          child: SizedBox.expand(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(bool completa) {
    if (widget.guardando) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
        ),
      );
    }
    if (!completa) {
      final n = widget.faltanCriterios;
      return Text(
        'Faltan $n criterios',
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        style: CataV2Theme.text(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF5F6B5F),
          letterSpacing: 0.1,
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ENVIAR PUNTUACIÓN',
          maxLines: 1,
          softWrap: false,
          style: CataV2Theme.text(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '¡Pulsa aquí!',
          maxLines: 1,
          softWrap: false,
          style: CataV2Theme.text(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
