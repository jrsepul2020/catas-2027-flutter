import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestra_hero_card.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestras_list.dart';

/// Pantalla del catador: espera animada + listado de catadas (solo lectura).
class CatadorEsperaPanel extends StatelessWidget {
  const CatadorEsperaPanel({
    super.key,
    required this.catadas,
    required this.total,
    required this.muestrasCatadas,
    this.proximaOrden,
    this.categoriaFallback,
    this.enIncidencia = false,
    this.incidenciaMotivo,
  });

  final int catadas;
  final int total;
  final List<MuestraEnTanda> muestrasCatadas;
  final int? proximaOrden;
  final String? categoriaFallback;
  final bool enIncidencia;
  final String? incidenciaMotivo;

  @override
  Widget build(BuildContext context) {
    final progreso = total <= 0 ? 0.0 : (catadas / total).clamp(0.0, 1.0);
    final motivo = (incidenciaMotivo ?? '').trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CataV2Theme.superficie,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: enIncidencia
                      ? const Color(0xFFE65100)
                      : CataV2Theme.borde,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _IconoEsperaAnimado(incidencia: enIncidencia),
                      const SizedBox(height: 18),
                      _TituloEsperaAnimado(incidencia: enIncidencia),
                      const SizedBox(height: 14),
                      Text(
                        enIncidencia
                            ? 'PAUSA · INCIDENCIA'
                            : 'MUESTRAS PENDIENTES DE CATAR',
                        textAlign: TextAlign.center,
                        style: CataV2Theme.text(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: enIncidencia
                              ? const Color(0xFFE65100)
                              : CataV2Theme.cabecera,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (enIncidencia) ...[
                        const SizedBox(height: 8),
                        Text(
                          motivo.isEmpty
                              ? 'Espera al administrador'
                              : motivo,
                          textAlign: TextAlign.center,
                          style: DashboardType.body(
                            color: CataV2Theme.textoSecundario,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Espera al administrador',
                          textAlign: TextAlign.center,
                          style: DashboardType.label(
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ] else if (proximaOrden != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Muestra $proximaOrden de $total'
                          '  ·  Quedan ${ (total - catadas).clamp(0, total) }',
                          textAlign: TextAlign.center,
                          style: DashboardType.body(
                            color: CataV2Theme.textoSecundario,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progreso,
                            minHeight: 6,
                            backgroundColor: CataV2Theme.borde,
                            color: enIncidencia
                                ? const Color(0xFFE65100)
                                : CataV2Theme.cabecera,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Catadas $catadas de $total',
                        textAlign: TextAlign.center,
                        style: DashboardType.label(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: MuestrasList.verde,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: MuestrasList.verdeClaro,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CATADAS (${muestrasCatadas.length})',
                      style: DashboardType.body(color: Colors.white)
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: MuestrasList(
                        muestras: muestrasCatadas,
                        filtro: MuestraFiltro.catadas,
                        colorPrimario: null,
                        categoriaFallback: categoriaFallback,
                        readOnly: true,
                        onMuestraTap: null,
                        compactCodigoCategoria: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reloj de arena grande: pulso + volteo suave.
class _IconoEsperaAnimado extends StatefulWidget {
  const _IconoEsperaAnimado({this.incidencia = false});

  final bool incidencia;

  @override
  State<_IconoEsperaAnimado> createState() => _IconoEsperaAnimadoState();
}

class _IconoEsperaAnimadoState extends State<_IconoEsperaAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        final scale = 0.9 + t * 0.14;
        final opacity = 0.5 + t * 0.5;
        final arriba = t < 0.5;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              widget.incidencia
                  ? Icons.report_gmailerrorred_rounded
                  : (arriba
                      ? Icons.hourglass_top_rounded
                      : Icons.hourglass_bottom_rounded),
              size: 80,
              color: const Color(0xFFC62828),
            ),
          ),
        );
      },
    );
  }
}

/// Título grande con respiración de opacidad (señal de espera).
class _TituloEsperaAnimado extends StatefulWidget {
  const _TituloEsperaAnimado({this.incidencia = false});

  final bool incidencia;

  @override
  State<_TituloEsperaAnimado> createState() => _TituloEsperaAnimadoState();
}

class _TituloEsperaAnimadoState extends State<_TituloEsperaAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Text(
        widget.incidencia
            ? 'PAUSA · INCIDENCIA · ESPERA AL ADMINISTRADOR'
            : 'ESPERANDO AL PRESIDENTE',
        textAlign: TextAlign.center,
        style: CataV2Theme.text(
          fontSize: widget.incidencia ? 22 : 26,
          fontWeight: FontWeight.w800,
          color: widget.incidencia
              ? const Color(0xFFC62828)
              : CataV2Theme.texto,
          letterSpacing: 0.6,
          height: 1.15,
        ),
      ),
    );
  }
}
