import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_medalla_widget.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_v51_theme.dart';

/// Check circular verde (mismo aspecto tablet / móvil).
class CheckCriterioV51 extends StatelessWidget {
  const CheckCriterioV51({super.key, required this.completado});

  final bool completado;

  @override
  Widget build(BuildContext context) {
    final size = CataV51Theme.anchoCheck;
    return SizedBox(
      width: size,
      height: size,
      child: completado
          ? Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CataV2Theme.checkCompleto,
              ),
              child: Icon(
                Icons.check,
                size: size * 0.65,
                color: Colors.white,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Botón de puntuación pastel (mismo aspecto tablet / móvil).
class NivelBotonV51 extends StatelessWidget {
  const NivelBotonV51({
    super.key,
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
    final Color bg;
    final Color borderColor;
    final Color fg;
    final FontWeight weight;
    List<BoxShadow>? sombra;

    if (selected) {
      bg = CataV51Theme.oscuro(columna);
      borderColor = CataV51Theme.oscuro(columna);
      fg = Colors.white;
      weight = FontWeight.w800;
      sombra = [
        BoxShadow(
          color: CataV51Theme.oscuro(columna).withValues(alpha: 0.28),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];
    } else {
      bg = CataV51Theme.pastelApagado(columna);
      borderColor = CataV51Theme.bordeApagadoPastel(columna);
      fg = CataV51Theme.numeroApagado;
      weight = FontWeight.w600;
      sombra = null;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CataV51Theme.radioPastilla),
        child: AnimatedContainer(
          duration: CataV2Theme.animSeleccion,
          curve: Curves.easeOut,
          width: double.infinity,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(CataV51Theme.radioPastilla),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: sombra,
          ),
          child: Text(
            '$valor',
            style: CataV2Theme.text(
              fontSize: CataV51Theme.tamanoNumero,
              fontWeight: weight,
              color: fg,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de 5 columnas de valores (misma lógica de slots que tablet).
class BotonesPuntuacionFilaV51 extends StatelessWidget {
  const BotonesPuntuacionFilaV51({
    super.key,
    required this.valores,
    required this.valorSeleccionado,
    required this.height,
    required this.gap,
    this.readOnly = false,
    this.onSelected,
    this.maxAnchoBoton = CataV51Theme.anchoBotonMax,
  });

  final List<int> valores;
  final int? valorSeleccionado;
  final double height;
  final double gap;
  final bool readOnly;
  final ValueChanged<int>? onSelected;
  final double maxAnchoBoton;

  @override
  Widget build(BuildContext context) {
    final slots =
        List<({int valor, int col})?>.filled(CataV51Theme.columnas, null);
    for (var i = 0; i < valores.length; i++) {
      final col = CataV51Theme.columnaParaValor(i, valores.length);
      slots[col] = (valor: valores[i], col: col);
    }

    return Row(
      children: [
        for (var c = 0; c < CataV51Theme.columnas; c++) ...[
          if (c > 0) SizedBox(width: gap),
          Expanded(
            child: Align(
              child: slots[c] == null
                  ? const SizedBox.shrink()
                  : ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxAnchoBoton),
                      child: NivelBotonV51(
                        valor: slots[c]!.valor,
                        columna: slots[c]!.col,
                        selected: valorSeleccionado == slots[c]!.valor,
                        height: height,
                        onTap: readOnly
                            ? null
                            : () => onSelected?.call(slots[c]!.valor),
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

String fmtTotalV51(double v) =>
    v.truncateToDouble() == v ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

String cortoMedallaV51(String label) {
  final u = label.toUpperCase();
  if (u.contains('GRAN')) return 'Gran Oro';
  if (u.contains('ORO')) return 'Oro';
  if (u.contains('PLATA')) return 'Plata';
  return label;
}

/// Total rojo + Provisional + medalla (compartido tablet/móvil).
class TotalMedallaBloqueV51 extends StatelessWidget {
  const TotalMedallaBloqueV51({
    super.key,
    required this.totalActual,
    required this.totalMin,
    required this.totalMax,
    required this.fichaCompleta,
    this.umbrales = MedallaUmbrales.defecto,
    this.compacto = false,
  });

  final double totalActual;
  final double totalMin;
  final double totalMax;
  final bool fichaCompleta;
  final MedallaUmbrales umbrales;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final medalla = CataMedalla.evaluar(
      total: totalActual,
      totalMin: totalMin,
      totalMax: totalMax,
      umbrales: umbrales,
    );
    final provisional = !fichaCompleta;
    final visual = medalla.label.aMedallaVisual;
    final hayPremio = !provisional && visual != CataMedallaVisual.ninguna;
    final nombreMedalla = provisional
        ? (visual == CataMedallaVisual.ninguna ? 'SIN MEDALLA' : medalla.label)
        : (hayPremio ? medalla.label : 'SIN MEDALLA');
    final totalTexto = fmtTotalV51(totalActual);

    final filaMedalla = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CataMedallaWidget(
          variante: visual,
          size: compacto ? 36 : 42,
          mostrarTexto: false,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            nombreMedalla,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            style: CataV2Theme.text(
              fontSize: compacto ? 13 : 14,
              fontWeight: FontWeight.w800,
              color: provisional
                  ? CataV51Theme.textoMuted
                  : (hayPremio
                      ? const Color(0xFF5D4037)
                      : CataV51Theme.textoMuted),
            ),
          ),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PUNTUACIÓN TOTAL',
          textAlign: TextAlign.center,
          style: CataV2Theme.text(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: CataV51Theme.textoMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          totalTexto,
          textAlign: TextAlign.center,
          style: CataV2Theme.text(
            fontSize: compacto ? 40 : 52,
            fontWeight: FontWeight.w900,
            color: CataV51Theme.rojoTotal,
            height: 1,
          ),
        ),
        if (provisional) ...[
          const SizedBox(height: 2),
          Text(
            'Provisional',
            textAlign: TextAlign.center,
            style: CataV2Theme.text(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CataV51Theme.textoMuted,
              letterSpacing: 0.3,
            ),
          ),
        ],
        const SizedBox(height: 4),
        if (!provisional)
          filaMedalla
        else
          Opacity(
            opacity: 0.4,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: filaMedalla,
            ),
          ),
      ],
    );
  }
}

/// Escala PLATA · ORO · GRAN ORO (compartida).
class EscalaPremiosV51 extends StatelessWidget {
  const EscalaPremiosV51({
    super.key,
    required this.total,
    required this.umbrales,
    required this.provisional,
  });

  final double total;
  final MedallaUmbrales umbrales;
  final bool provisional;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CataV51Theme.bordeTarjeta),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _Umbral(
                titulo: 'PLATA',
                valor: fmtTotalV51(umbrales.plata),
                encendida: !provisional && total >= umbrales.plata,
                color: const Color(0xFF78909C),
              ),
            ),
            Expanded(
              child: _Umbral(
                titulo: 'ORO',
                valor: fmtTotalV51(umbrales.oro),
                encendida: !provisional && total >= umbrales.oro,
                color: const Color(0xFFF9A825),
              ),
            ),
            Expanded(
              child: _Umbral(
                titulo: 'GRAN ORO',
                valor: fmtTotalV51(umbrales.granOro),
                encendida: !provisional && total >= umbrales.granOro,
                color: const Color(0xFFFFD54F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Umbral extends StatelessWidget {
  const _Umbral({
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
    final texto = encendida ? CataV51Theme.texto : CataV51Theme.textoMuted;
    return AnimatedContainer(
      duration: CataV2Theme.animSeleccion,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: encendida ? color.withValues(alpha: 0.35) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              titulo,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: CataV2Theme.text(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: texto,
                height: 1.05,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Text(
            valor,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: CataV2Theme.text(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: texto,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra «x de N» en verde.
class BarraCriteriosV51 extends StatelessWidget {
  const BarraCriteriosV51({
    super.key,
    required this.completos,
    required this.total,
  });

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
            color: CataV51Theme.texto,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            color: const Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }
}

class ReiniciarSecundarioV51 extends StatelessWidget {
  const ReiniciarSecundarioV51({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.refresh_outlined,
        size: 16,
        color: CataV51Theme.rojoAccion.withValues(alpha: 0.85),
      ),
      label: Text(
        'Reiniciar puntuación',
        style: CataV2Theme.text(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: CataV51Theme.rojoAccion.withValues(alpha: 0.9),
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
