import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v3/cata_v3_theme.dart';

/// Fila V3: criterio (izq) | pastillas de puntos (der), números azul oscuro.
class CriterioBotonesV3 extends StatelessWidget {
  const CriterioBotonesV3({
    super.key,
    required this.label,
    required this.valores,
    required this.valorSeleccionado,
    required this.completado,
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
            ? (maxH - 6).clamp(
                CataV3Theme.alturaBotonMin,
                CataV3Theme.alturaBotonMax,
              )
            : CataV3Theme.alturaBotonMin;

        return AnimatedContainer(
          duration: CataV2Theme.animSeleccion,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: resaltarPendiente
                ? Border.all(color: CataV2Theme.acentoPendiente, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cuadro criterios (nombre + check).
              SizedBox(
                width: CataV3Theme.anchoColumnaCriterios,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: CataV2Theme.text(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: CataV3Theme.numero,
                            height: 1.05,
                          ),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _CheckVerde(completado: completado),
                    ],
                  ),
                ),
              ),
              Container(width: 1, color: CataV3Theme.divisorCriterioPuntos),
              // Cuadro puntos.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildGrid(btnHeight),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!pulsarUnicoPendiente) return row;
    return _PulsoAmbarFila(child: row);
  }

  Widget _buildGrid(double btnHeight) {
    final columnas = totalColumnas ?? CataV3Theme.columnas;
    final slots = List<({int valor, int col})?>.filled(columnas, null);

    for (var i = 0; i < valores.length; i++) {
      final col = valores.length == columnas
          ? i
          : _columnaDistribuida(i, valores.length, columnas);
      slots[col] = (valor: valores[i], col: col);
    }

    return Row(
      children: [
        for (var c = 0; c < columnas; c++) ...[
          if (c > 0) const SizedBox(width: CataV3Theme.huecoBotones),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: slots[c] == null
                  ? const SizedBox.shrink()
                  : _PastillaV3(
                      valor: slots[c]!.valor,
                      columna: slots[c]!.col,
                      selected: valorSeleccionado == slots[c]!.valor,
                      height: btnHeight,
                      onTap: readOnly
                          ? null
                          : () => onSelected?.call(slots[c]!.valor),
                    ),
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CataV2Theme.acentoPendiente
                    .withValues(alpha: 0.35 + 0.55 * t),
                width: 2,
              ),
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

class _PastillaV3 extends StatelessWidget {
  const _PastillaV3({
    required this.valor,
    required this.columna,
    required this.selected,
    required this.height,
    this.onTap,
  });

  final int valor;
  final int columna;
  final bool selected;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fondo = selected
        ? CataV3Theme.seleccionadoColumna(columna)
        : CataV3Theme.fondoColumna(columna);
    // Números: azul oscuro; blanco solo si está seleccionado (contraste).
    final texto = selected ? Colors.white : CataV3Theme.numero;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: CataV2Theme.anchoBotonMax),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CataV3Theme.radioPastilla),
          child: AnimatedContainer(
            duration: CataV2Theme.animSeleccion,
            curve: Curves.easeOut,
            width: double.infinity,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(CataV3Theme.radioPastilla),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.4)
                    : CataV3Theme.bordeColumna(columna).withValues(alpha: 0.55),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: CataV3Theme.seleccionadoColumna(columna)
                            .withValues(alpha: 0.32),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '$valor',
              style: CataV2Theme.text(
                fontSize: 16,
                fontWeight: FontWeight.w900,
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
