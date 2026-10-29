import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_form_layout.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:virtus2027/features/cata/presentation/widgets/criterio_botones.dart';
import 'package:virtus2027/features/cata/presentation/widgets/criterio_slider.dart';

class GrupoCriterios extends StatelessWidget {
  const GrupoCriterios({
    super.key,
    required this.grupo,
    required this.scores,
    required this.readOnly,
    required this.onScoreChanged,
    this.fillHeight = false,
  });

  final FichaGrupo grupo;
  final Map<String, num> scores;
  final bool readOnly;
  final void Function(String criterioId, num value) onScoreChanged;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final estilo = CataGrupoStyle.forGrupo(grupo.nombre);

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: estilo.fondo,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: estilo.borde.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: CataFormLayout.anchoTabGrupo,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: estilo.tab,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(5),
              ),
            ),
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  grupo.nombre.toUpperCase(),
                  style: VirtusTextStyles.plain(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: estilo.etiqueta,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
              child: fillHeight
                  ? Column(
                      children: [
                        for (var i = 0; i < grupo.criterios.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: estilo.borde.withValues(alpha: 0.45),
                            ),
                          Expanded(
                            child: _buildCriterio(grupo.criterios[i]),
                          ),
                        ],
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < grupo.criterios.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: estilo.borde.withValues(alpha: 0.6),
                            ),
                          _buildCriterio(grupo.criterios[i]),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );

    if (fillHeight) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: IntrinsicHeight(child: content),
    );
  }

  Widget _buildCriterio(FichaCriterio criterio) {
    final completado = scores.containsKey(criterio.id);

    if (criterio.usaBotonesEnFila) {
      final selected = scores[criterio.id]?.round();

      return CriterioBotones(
        label: criterio.label,
        valores: criterio.valoresDisponibles,
        valorSeleccionado: selected,
        completado: completado,
        readOnly: readOnly,
        fillWidth: fillHeight,
        totalColumnas: criterio.columnasBotones ??
            (criterio.valoresDisponibles.length == 5 ? 5 : null),
        onSelected: (value) => onScoreChanged(criterio.id, value),
      );
    }

    if (criterio.esSlider) {
      final min = criterio.min!;
      final max = criterio.max!;
      final current = (scores[criterio.id] ?? min).round().clamp(min, max);

      return CriterioSlider(
        label: criterio.label,
        min: min,
        max: max,
        value: current,
        completado: completado,
        readOnly: readOnly,
        onChanged: (value) => onScoreChanged(criterio.id, value),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text('Criterio no configurado: ${criterio.label}'),
    );
  }
}
