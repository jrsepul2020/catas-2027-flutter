import 'dart:async';

import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/widgets/nube_badge.dart';
import 'package:virtus2027/core/widgets/servidor_estado_chip.dart';
import 'package:virtus2027/core/widgets/status_bar_spacer.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/diagnostico/diagnostico.dart';
import 'package:virtus2027/features/home/utils/pais_flag.dart';

/// Barra superior única y fina de la ficha de cata.
class CataHeaderV2 extends StatelessWidget {
  const CataHeaderV2({
    super.key,
    required this.concursoNombre,
    required this.mostrarModoPruebas,
    required this.onRefresh,
    required this.rolLabel,
    required this.mesaNumero,
    required this.tandaNumero,
    required this.puesto,
    required this.tabletNumero,
    required this.catadorNombre,
    required this.paisCodigo,
    this.onBack,
    this.onTrucos,
    this.onSalirInicio,
    this.codigoMuestra,
    this.extrasSoloPruebas = false,
    this.esModoPruebasApp = false,
  });

  final String concursoNombre;
  final bool mostrarModoPruebas;
  final VoidCallback? onBack;
  final VoidCallback onRefresh;
  final String rolLabel;
  final int mesaNumero;
  final int? tandaNumero;
  final int? puesto;
  final int? tabletNumero;
  final String catadorNombre;
  final String? paisCodigo;
  final VoidCallback? onTrucos;
  final VoidCallback? onSalirInicio;
  /// Chip destacado "Muestra XXXX" (p. ej. V5, legible de lejos).
  final String? codigoMuestra;
  /// Si true: Tanda/Puesto/Tablet/local/latencia/refresco solo en modo pruebas.
  final bool extrasSoloPruebas;
  /// App en modo pruebas (aunque el chip PRUEBAS solo salga al presidente).
  final bool esModoPruebasApp;

  static const double height = CataV2Theme.altoCabecera;

  @override
  Widget build(BuildContext context) {
    final titulo = concursoNombre.trim().isEmpty
        ? 'LA RÁBIDA 2027'
        : concursoNombre.toUpperCase();
    final admin = CataV2Theme.mostrarInfoAdministrador;
    final mostrarExtras =
        !extrasSoloPruebas || esModoPruebasApp || mostrarModoPruebas;
    final muestra = codigoMuestra?.trim();
    // Misma regla que ficha V5.1 móvil: lado corto < 600.
    final movil = MediaQuery.sizeOf(context).shortestSide < 600;

    return ColoredBox(
      color: CataV2Theme.cabecera,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StatusBarSpacer(color: CataV2Theme.cabecera),
          SizedBox(
            height: movil ? height + 6 : height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  if (onBack != null) ...[
                    Material(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: onBack,
                        iconSize: TabletLayout.headerIconSize - 8,
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Volver',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (!movil) ...[
                    _TituloHold(
                      titulo: titulo,
                      onHoldComplete: onSalirInicio,
                    ),
                    const SizedBox(width: 10),
                  ] else
                    // Hold oculto para truco «salir a inicio»; sin título ni flechas de muestra.
                    _TituloHold(
                      titulo: '',
                      onHoldComplete: onSalirInicio,
                      child: const SizedBox(width: 4, height: 24),
                    ),
                  if (admin)
                    Expanded(
                      child: movil
                          ? _FilaIdentidadMovil(
                              catadorNombre: catadorNombre,
                              paisCodigo: paisCodigo,
                              rolLabel: rolLabel,
                              mesaNumero: mesaNumero,
                              codigoMuestra: muestra,
                              onRefresh: onRefresh,
                            )
                          : Row(
                              children: [
                                Text(
                                  PaisFlag.emoji(paisCodigo),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    catadorNombre,
                                    style: CataV2Theme.text(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _Pill(
                                  text: rolLabel.toUpperCase(),
                                  destacado: true,
                                ),
                                _Pill(text: 'Mesa $mesaNumero'),
                                if (muestra != null && muestra.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  _MuestraChip(codigo: muestra),
                                ],
                                const Spacer(flex: 1),
                                if (mostrarExtras)
                                  Flexible(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (tandaNumero != null)
                                              _Pill(
                                                text: 'Tanda $tandaNumero',
                                                tecnico: extrasSoloPruebas,
                                              ),
                                            if (puesto != null)
                                              _Pill(
                                                text: 'Puesto $puesto',
                                                tecnico: extrasSoloPruebas,
                                              ),
                                            if (tabletNumero != null)
                                              _Pill(
                                                text: 'Tablet $tabletNumero',
                                                tecnico: extrasSoloPruebas,
                                              ),
                                            if (mostrarModoPruebas) ...[
                                              const SizedBox(width: 4),
                                              const _Chip(
                                                label: 'PRUEBAS',
                                                background: Color(0xFFC62828),
                                              ),
                                              if (onTrucos != null) ...[
                                                const SizedBox(width: 4),
                                                _ActionChip(
                                                  label: 'TRUCOS',
                                                  onPressed: onTrucos!,
                                                ),
                                              ],
                                            ],
                                            const SizedBox(width: 4),
                                            ServidorEstadoChip(
                                              compact: true,
                                              tecnicoMuted: extrasSoloPruebas,
                                            ),
                                            const NubeBadge(),
                                            DiagnosticoBoton(
                                              tabletNumero: tabletNumero,
                                              rolLabel: rolLabel,
                                            ),
                                            IconButton(
                                              onPressed: onRefresh,
                                              iconSize: TabletLayout
                                                      .headerIconSize -
                                                  8,
                                              color: extrasSoloPruebas
                                                  ? Colors.white.withValues(
                                                      alpha: 0.72)
                                                  : Colors.white,
                                              icon: const Icon(Icons.refresh),
                                              tooltip:
                                                  'Recargar puntuación del servidor',
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(
                                                minWidth: 34,
                                                minHeight: 34,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    )
                  else
                    const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera móvil: nombre, rol, mesa y chip de muestra (sin flechas).
class _FilaIdentidadMovil extends StatelessWidget {
  const _FilaIdentidadMovil({
    required this.catadorNombre,
    required this.paisCodigo,
    required this.rolLabel,
    required this.mesaNumero,
    required this.onRefresh,
    this.codigoMuestra,
  });

  final String catadorNombre;
  final String? paisCodigo;
  final String rolLabel;
  final int mesaNumero;
  final String? codigoMuestra;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final muestra = codigoMuestra?.trim();
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            PaisFlag.emoji(paisCodigo),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              catadorNombre,
              style: CataV2Theme.text(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          _Pill(text: rolLabel.toUpperCase(), destacado: true),
          _Pill(text: 'Mesa $mesaNumero'),
          if (muestra != null && muestra.isNotEmpty)
            _MuestraChip(codigo: muestra, compacto: true),
          IconButton(
            onPressed: onRefresh,
            iconSize: 18,
            color: Colors.white.withValues(alpha: 0.85),
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar puntuación del servidor',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _TituloHold extends StatefulWidget {
  const _TituloHold({
    required this.titulo,
    this.onHoldComplete,
    this.child,
  });

  final String titulo;
  final VoidCallback? onHoldComplete;
  final Widget? child;

  @override
  State<_TituloHold> createState() => _TituloHoldState();
}

class _TituloHoldState extends State<_TituloHold> {
  Timer? _timer;

  void _start() {
    if (widget.onHoldComplete == null) return;
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      widget.onHoldComplete?.call();
    });
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _start(),
      onPointerUp: (_) => _cancel(),
      onPointerCancel: (_) => _cancel(),
      child: widget.child ??
          Text(
            widget.titulo,
            style: CataV2Theme.text(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    this.destacado = false,
    this.tecnico = false,
  });

  final String text;
  final bool destacado;
  final bool tecnico;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final double size;
    if (destacado) {
      bg = const Color(0xFFE8F5E9);
      fg = CataV2Theme.cabecera;
      size = 11;
    } else if (tecnico) {
      bg = Colors.white.withValues(alpha: 0.10);
      fg = Colors.white.withValues(alpha: 0.62);
      size = 12;
    } else {
      bg = Colors.white.withValues(alpha: 0.16);
      fg = Colors.white;
      size = 11;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tecnico ? 7 : 9,
          vertical: tecnico ? 4 : 5,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: CataV2Theme.text(
            color: fg,
            fontSize: size,
            fontWeight: tecnico ? FontWeight.w600 : FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Chip de muestra grande para lectura a distancia en mesa.
class _MuestraChip extends StatelessWidget {
  const _MuestraChip({required this.codigo, this.compacto = false});

  final String codigo;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: compacto ? 2 : 6),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compacto ? 8 : 12,
          vertical: compacto ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(compacto ? 8 : 10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        ),
        child: Text(
          'Muestra $codigo',
          style: CataV2Theme.text(
            color: CataV2Theme.cabecera,
            fontSize: compacto ? 13 : 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: CataV2Theme.text(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.16),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: CataV2Theme.text(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}


