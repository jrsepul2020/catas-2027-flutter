import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';

/// Botones numéricos de la ficha V2 (grid de 5 columnas, check verde).
class CriterioBotonesV2 extends StatelessWidget {
  const CriterioBotonesV2({
    super.key,
    required this.label,
    required this.valores,
    required this.valorSeleccionado,
    required this.completado,
    required this.colorSeleccionado,
    required this.onSelected,
    this.readOnly = false,
    this.resaltarPendiente = false,
    this.pulsarUnicoPendiente = false,
    this.totalColumnas,
  });

  final String label;
  final List<int> valores;
  final int? valorSeleccionado;
  final bool completado;
  final Color colorSeleccionado;
  final ValueChanged<int>? onSelected;
  final bool readOnly;
  final bool resaltarPendiente;
  final bool pulsarUnicoPendiente;
  final int? totalColumnas;

  @override
  Widget build(BuildContext context) {
    final row = LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final hasHeight = maxH.isFinite && maxH > 0;
        final btnHeight = hasHeight
            ? (maxH - 4).clamp(CataV2Theme.alturaBoton, 52.0)
            : CataV2Theme.alturaBoton;

        return AnimatedContainer(
          duration: CataV2Theme.animSeleccion,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: resaltarPendiente
                ? Border.all(color: CataV2Theme.acentoPendiente, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: CataV2Theme.anchoEtiquetaCriterio,
                child: Text(
                  label,
                  style: CataV2Theme.text(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: CataV2Theme.texto,
                    height: 1.05,
                  ),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _CheckVerde(completado: completado),
              const SizedBox(width: 8),
              Expanded(child: _buildGrid(btnHeight)),
            ],
          ),
        );
      },
    );

    if (!pulsarUnicoPendiente) return row;
    return _PulsoAmbarFila(child: row);
  }

  Widget _buildGrid(double btnHeight) {
    final columnas = totalColumnas ?? CataV2Theme.columnasBotones;
    final slots = List<Widget?>.filled(columnas, null);

    for (var i = 0; i < valores.length; i++) {
      final col = valores.length == columnas
          ? i
          : _columnaDistribuida(i, valores.length, columnas);
      slots[col] = _ValorButtonV2(
        valor: valores[i],
        selected: valorSeleccionado == valores[i],
        height: btnHeight,
        colorSeleccionado: colorSeleccionado,
        onTap: readOnly ? null : () => onSelected?.call(valores[i]),
      );
    }

    return Row(
      children: [
        for (var c = 0; c < columnas; c++) ...[
          if (c > 0) SizedBox(width: CataV2Theme.huecoBotones),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: slots[c] ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ],
    );
  }

  int _columnaDistribuida(int indice, int totalValores, int totalColumnas) {
    if (totalValores <= 1) return 0;
    return (indice * (totalColumnas - 1) / (totalValores - 1)).round();
  }
}

class _PulsoAmbarFila extends StatefulWidget {
  const _PulsoAmbarFila({required this.child});

  final Widget child;

  @override
  State<_PulsoAmbarFila> createState() => _PulsoAmbarFilaState();
}

class _PulsoAmbarFilaState extends State<_PulsoAmbarFila>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: CataV2Theme.pulsoLento)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_c.value);
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: CataV2Theme.acentoPendiente
                    .withValues(alpha: 0.35 + 0.55 * t),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: CataV2Theme.acentoPendiente
                      .withValues(alpha: 0.12 + 0.18 * t),
                  blurRadius: 4 + 4 * t,
                ),
              ],
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _CheckVerde extends StatelessWidget {
  const _CheckVerde({required this.completado});

  final bool completado;

  @override
  Widget build(BuildContext context) {
    final size = CataV2Theme.anchoCheck;
    return SizedBox(
      width: size,
      height: size,
      child: completado
          ? Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CataV2Theme.checkCompleto,
              ),
              child: Icon(Icons.check, size: size * 0.65, color: Colors.white),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _ValorButtonV2 extends StatelessWidget {
  const _ValorButtonV2({
    required this.valor,
    required this.selected,
    required this.height,
    required this.colorSeleccionado,
    this.onTap,
  });

  final int valor;
  final bool selected;
  final double height;
  final Color colorSeleccionado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fondo = selected
        ? colorSeleccionado
        : CataV2Theme.botonNoSeleccionadoFondo;
    final texto = selected
        ? Colors.white
        : CataV2Theme.botonNoSeleccionadoTexto;
    final borde = selected
        ? Colors.white.withValues(alpha: 0.35)
        : CataV2Theme.botonNoSeleccionadoBorde;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: CataV2Theme.anchoBotonMax),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CataV2Theme.radioBoton),
          child: AnimatedContainer(
            duration: CataV2Theme.animSeleccion,
            curve: Curves.easeOut,
            width: double.infinity,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(CataV2Theme.radioBoton),
              border: borde != null
                  ? Border.all(color: borde, width: selected ? 1.5 : 1)
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colorSeleccionado.withValues(alpha: 0.4),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '$valor',
              style: CataV2Theme.text(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: texto,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
