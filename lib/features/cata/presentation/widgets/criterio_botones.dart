import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_form_layout.dart';

class CriterioBotones extends StatelessWidget {
  const CriterioBotones({
    super.key,
    required this.label,
    required this.valores,
    required this.valorSeleccionado,
    required this.completado,
    required this.onSelected,
    this.readOnly = false,
    this.fillWidth = false,
    this.totalColumnas,
  });

  final String label;
  final List<int> valores;
  final int? valorSeleccionado;
  final bool completado;
  final ValueChanged<int>? onSelected;
  final bool readOnly;
  final bool fillWidth;
  final int? totalColumnas;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final hasHeight = maxH.isFinite && maxH > 0;
        final btnHeight = hasHeight
            ? (maxH - 4).clamp(
                CataFormLayout.alturaBotonMin,
                CataFormLayout.alturaBotonMax,
              )
            : CataFormLayout.alturaBotonMin;
        final fontSize = btnHeight >= 42 ? 14.0 : 13.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: CataFormLayout.anchoEtiqueta,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: VirtusTextStyles.plain(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      color: const Color(0xFF37474F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: _CheckIcon(
                  completado: completado,
                  size: btnHeight >= 40 ? 22 : 20,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: fillWidth
                    ? _buildExpandedButtonRow(btnHeight, fontSize)
                    : _buildFixedButtons(btnHeight, fontSize),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpandedButtonRow(double btnHeight, double fontSize) {
    final columnas = totalColumnas ?? valores.length;
    final slots = List<Widget?>.filled(columnas, null);

    for (var i = 0; i < valores.length; i++) {
      final col = valores.length == columnas
          ? i
          : _columnaDistribuida(i, valores.length, columnas);
      slots[col] = _ValorButton(
        valor: valores[i],
        selected: valorSeleccionado == valores[i],
        height: btnHeight,
        fontSize: fontSize,
        onTap: readOnly ? null : () => onSelected?.call(valores[i]),
      );
    }

    return Row(
      children: [
        for (var c = 0; c < columnas; c++) ...[
          if (c > 0) const SizedBox(width: CataFormLayout.separacionBotones),
          Expanded(child: slots[c] ?? const SizedBox.shrink()),
        ],
      ],
    );
  }

  int _columnaDistribuida(int indice, int totalValores, int totalColumnas) {
    if (totalValores <= 1) return 0;
    return (indice * (totalColumnas - 1) / (totalValores - 1)).round();
  }

  Widget _buildFixedButtons(double btnHeight, double fontSize) {
    return Row(
      children: [
        for (var i = 0; i < valores.length; i++) ...[
          if (i > 0) const SizedBox(width: CataFormLayout.separacionBotones),
          _ValorButton(
            valor: valores[i],
            selected: valorSeleccionado == valores[i],
            height: btnHeight,
            width: 44,
            fontSize: fontSize,
            onTap: readOnly ? null : () => onSelected?.call(valores[i]),
          ),
        ],
      ],
    );
  }
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon({required this.completado, required this.size});

  final bool completado;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completado ? CataColors.checkCompleto : Colors.transparent,
        border: Border.all(
          color: completado ? CataColors.checkCompleto : CataColors.checkBorde,
          width: 1.5,
        ),
      ),
      child: completado
          ? Icon(Icons.check, size: size * 0.65, color: Colors.white)
          : null,
    );
  }
}

class _ValorButton extends StatelessWidget {
  const _ValorButton({
    required this.valor,
    required this.selected,
    required this.height,
    required this.fontSize,
    this.width,
    this.onTap,
  });

  final int valor;
  final bool selected;
  final double height;
  final double fontSize;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? CataColors.botonSeleccionado
        : CataColors.botonNeutro;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(CataFormLayout.radioBoton),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CataFormLayout.radioBoton),
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: Text(
              '$valor',
              style: VirtusTextStyles.plain(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
