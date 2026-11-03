import 'dart:async';

import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/widgets/app_version_label.dart';
import 'package:virtus2027/core/widgets/nube_badge.dart';
import 'package:virtus2027/core/widgets/servidor_estado_chip.dart';
import 'package:virtus2027/core/widgets/status_bar_spacer.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/diagnostico/diagnostico.dart';
import 'package:virtus2027/features/home/utils/pais_flag.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.concursoNombre,
    required this.catadorNombre,
    required this.rolLabel,
    required this.paisCodigo,
    required this.mesaNumero,
    required this.tandaNumero,
    required this.colorPrimario,
    this.esPresidente = false,
    this.mostrarModoPruebas = false,
    this.puesto,
    this.tabletNumero,
    this.onBack,
    this.salirConHold = false,
    this.onRefresh,
    this.onEstadisticas,
    this.onTrucos,
  });

  final String concursoNombre;
  final String catadorNombre;
  final String rolLabel;
  final String? paisCodigo;
  final int mesaNumero;
  final int? tandaNumero;
  // Conservado por compatibilidad con llamadas existentes (tema V2 fijo).
  // ignore: unused_field
  final String? colorPrimario;
  final bool esPresidente;
  final bool mostrarModoPruebas;
  final int? puesto;
  final int? tabletNumero;
  final VoidCallback? onBack;
  /// Si true, SALIR requiere mantener 3 s (producción). Si false, un toque (pruebas).
  final bool salirConHold;
  final VoidCallback? onRefresh;
  final VoidCallback? onEstadisticas;
  final VoidCallback? onTrucos;

  static const double height = CataV2Theme.altoCabecera;

  @override
  Widget build(BuildContext context) {
    final admin = CataV2Theme.mostrarInfoAdministrador;
    final titulo = concursoNombre.trim().isEmpty
        ? 'LA RÁBIDA 2027'
        : concursoNombre.toUpperCase();
    final barColor =
        esPresidente ? CataV2Theme.cabeceraPresidente : CataV2Theme.cabecera;

    return ColoredBox(
      color: barColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBarSpacer(color: barColor),
          SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // Izquierda: marca
                  Text(
                    titulo,
                    style: CataV2Theme.text(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  // Centro: identidad + mesa/tanda
                  if (admin)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            barColor: barColor,
                          ),
                          _Pill(text: 'Mesa $mesaNumero'),
                          if (tandaNumero != null)
                            _Pill(text: 'Tanda $tandaNumero'),
                          if (puesto != null) _Pill(text: 'Puesto $puesto'),
                          if (tabletNumero != null)
                            _Pill(text: 'Tablet $tabletNumero'),
                        ],
                      ),
                    )
                  else
                    const Spacer(),
                  // Derecha: salir / pruebas / ajustes + conexión + refresh
                  if (onBack != null) ...[
                    const SizedBox(width: 6),
                    _SalirControl(
                      onSalir: onBack!,
                      requireHold: salirConHold,
                    ),
                  ],
                  if (mostrarModoPruebas) ...[
                    const SizedBox(width: 6),
                    const _Chip(
                      label: 'PRUEBAS',
                      background: Color(0xFFC62828),
                    ),
                    if (onTrucos != null) ...[
                      const SizedBox(width: 4),
                      _ActionChip(label: 'TRUCOS', onPressed: onTrucos!),
                    ],
                  ],
                  if (onEstadisticas != null) ...[
                    const SizedBox(width: 2),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.settings,
                        size: TabletLayout.headerIconSize - 8,
                        color: Colors.white,
                      ),
                      tooltip: 'Ajustes',
                      padding: EdgeInsets.zero,
                      offset: const Offset(0, 40),
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == 'estadisticas') onEstadisticas!();
                        if (value == 'salir') onBack?.call();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'estadisticas',
                          child: Text(
                            'Estadísticas',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (onBack != null)
                          const PopupMenuItem<String>(
                            value: 'salir',
                            child: Text(
                              'Salir a tablets',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const NubeBadge(),
                  const ServidorEstadoChip(compact: true),
                  DiagnosticoBoton(
                    tabletNumero: tabletNumero,
                    rolLabel: rolLabel,
                  ),
                  if (admin) const AppVersionLabel(onDark: true),
                  if (onRefresh != null)
                    IconButton(
                      onPressed: onRefresh,
                      iconSize: TabletLayout.headerIconSize - 8,
                      color: Colors.white,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Recargar datos del servidor',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalirControl extends StatefulWidget {
  const _SalirControl({
    required this.onSalir,
    required this.requireHold,
  });

  final VoidCallback onSalir;
  final bool requireHold;

  @override
  State<_SalirControl> createState() => _SalirControlState();
}

class _SalirControlState extends State<_SalirControl> {
  Timer? _timer;
  bool _holding = false;

  void _startHold() {
    if (!widget.requireHold) return;
    _timer?.cancel();
    setState(() => _holding = true);
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() => _holding = false);
      widget.onSalir();
    });
  }

  void _cancelHold() {
    _timer?.cancel();
    _timer = null;
    if (_holding && mounted) setState(() => _holding = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _holding
            ? Colors.white.withValues(alpha: 0.28)
            : Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.requireHold ? 'SALIR · 3s' : 'SALIR',
        style: CataV2Theme.text(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );

    if (!widget.requireHold) {
      return GestureDetector(
        onTap: widget.onSalir,
        child: child,
      );
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _startHold(),
      onPointerUp: (_) => _cancelHold(),
      onPointerCancel: (_) => _cancelHold(),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    this.destacado = false,
    this.barColor = CataV2Theme.cabecera,
  });

  final String text;
  final bool destacado;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: destacado
              ? CataV2Theme.checkCompleto.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: CataV2Theme.text(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: destacado ? barColor : Colors.white,
            letterSpacing: 0.2,
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
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
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
    return Material(
      color: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Text(
            label,
            style: CataV2Theme.text(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
