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

  static const double height = CataV2Theme.altoCabecera;

  @override
  Widget build(BuildContext context) {
    final titulo = concursoNombre.trim().isEmpty
        ? 'LA RÁBIDA 2027'
        : concursoNombre.toUpperCase();
    final admin = CataV2Theme.mostrarInfoAdministrador;

    return ColoredBox(
      color: CataV2Theme.cabecera,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StatusBarSpacer(color: CataV2Theme.cabecera),
          SizedBox(
            height: height,
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
                  _TituloHold(
                    titulo: titulo,
                    onHoldComplete: onSalirInicio,
                  ),
                  const SizedBox(width: 10),
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
                  const SizedBox(width: 4),
                  const ServidorEstadoChip(compact: true),
                  const NubeBadge(),
                  DiagnosticoBoton(
                    tabletNumero: tabletNumero,
                    rolLabel: rolLabel,
                  ),
                  IconButton(
                    onPressed: onRefresh,
                    iconSize: TabletLayout.headerIconSize - 8,
                    color: Colors.white,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Recargar puntuación del servidor',
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

class _TituloHold extends StatefulWidget {
  const _TituloHold({required this.titulo, this.onHoldComplete});

  final String titulo;
  final VoidCallback? onHoldComplete;

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
      child: Text(
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
  const _Pill({required this.text, this.destacado = false});

  final String text;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: destacado
              ? const Color(0xFFE8F5E9)
              : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: CataV2Theme.text(
            color: destacado ? CataV2Theme.cabecera : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
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


