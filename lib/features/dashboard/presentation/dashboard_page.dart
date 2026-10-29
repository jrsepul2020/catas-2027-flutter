import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/models/catador.dart';
import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/models/tanda.dart';
import 'package:virtus2027/features/cata/data/cata_repository.dart';
import 'package:virtus2027/features/cata/presentation/cata_page.dart';
import 'package:virtus2027/features/dashboard/data/dashboard_realtime_sync.dart';
import 'package:virtus2027/features/dashboard/data/tanda_repository.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/domain/tablet_dashboard.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_colors.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestra_hero_card.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestras_filter_tabs.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestras_list.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestras_pendientes_list.dart';
import 'package:virtus2027/config/app_mode.dart';
import 'package:virtus2027/features/home/domain/dispositivo_home_item.dart';
import 'package:virtus2027/features/pruebas/presentation/trucos_panel.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.dispositivo});

  final DispositivoHomeItem dispositivo;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repository = DashboardRepository();

  late Future<TabletDashboard> _dashboardFuture;
  MuestraFiltro? _filtro;
  bool _filtroInicializado = false;
  DashboardRealtimeSync? _realtime;
  String? _realtimeTandaId;

  @override
  void initState() {
    super.initState();
    _load();
    _iniciarRealtimeTrasPrimeraCarga();
  }

  @override
  void dispose() {
    final sync = _realtime;
    _realtime = null;
    sync?.dispose();
    super.dispose();
  }

  Future<void> _iniciarRealtimeTrasPrimeraCarga() async {
    try {
      final dashboard = await _dashboardFuture;
      if (!mounted) return;
      await _ensureRealtimeSubscription(dashboard.tanda?.id);
    } catch (_) {
      // Si falla Realtime, el refresco manual sigue disponible.
    }
  }

  Future<void> _ensureRealtimeSubscription(String? tandaId) async {
    if (tandaId == null || tandaId.isEmpty) return;
    if (_realtimeTandaId == tandaId && _realtime != null) return;

    await _realtime?.dispose();
    _realtimeTandaId = tandaId;
    _realtime = DashboardRealtimeSync(
      tandaId: tandaId,
      onChanged: _onRealtimeUpdate,
    );
    _realtime!.subscribe();
  }

  void _onRealtimeUpdate() {
    if (!mounted) return;
    setState(() => _load(resetFiltro: false));
  }

  void _load({bool resetFiltro = true}) {
    if (resetFiltro) _filtroInicializado = false;
    _dashboardFuture = _repository.fetchForDispositivo(widget.dispositivo);
  }

  Future<void> _reload() async {
    setState(() => _load());
    final dashboard = await _dashboardFuture;
    if (!mounted) return;
    await _ensureRealtimeSubscription(dashboard.tanda?.id);
  }

  Future<void> _reloadTrasAprobar() async {
    setState(() {
      _filtro = MuestraFiltro.catadas;
      _filtroInicializado = true;
      _load(resetFiltro: false);
    });
    await _dashboardFuture;
  }

  Future<void> _abrirCataMesa({
    required MuestraEnTanda muestra,
    required TabletDashboard dashboard,
  }) async {
    if (dashboard.tanda == null || dashboard.catador == null) return;

    try {
      await CataRepository().abrirCataMuestra(
        tandaId: dashboard.tanda!.id,
        muestraId: muestra.muestraId,
      );
      await _reload();
      if (!mounted) return;

      final dash = await _dashboardFuture;
      if (!mounted) return;

      final actualizada = DashboardMuestraUtils.muestraActiva(dash.muestras);

      _abrirCata(
        context,
        muestra: actualizada ?? muestra,
        tanda: dashboard.tanda!,
        catador: dashboard.catador!,
        categoria: dashboard.categoria,
        colorPrimario: dashboard.concursoColorPrimario,
        dashboard: dashboard,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatError(e))),
      );
    }
  }

  bool _esPresidente(TabletDashboard dashboard) {
    return dashboard.esPresidente || widget.dispositivo.esPresidente;
  }

  String _rolLabel(TabletDashboard dashboard) {
    if (_esPresidente(dashboard)) return 'Presidente';
    return widget.dispositivo.rol?.trim().isNotEmpty == true
        ? widget.dispositivo.rol!
        : 'Catador';
  }

  void _abrirTrucos(TabletDashboard dashboard) {
    if (!esModoPruebas || !_esPresidente(dashboard)) return;
    final mesaId = dashboard.mesa?.id ?? dashboard.catador?.mesaId;
    final tandaId = dashboard.tanda?.id;
    final catadorId = dashboard.catador?.id;
    if (mesaId == null ||
        mesaId.isEmpty ||
        tandaId == null ||
        tandaId.isEmpty ||
        catadorId == null ||
        catadorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faltan mesa/tanda/catador para trucos.')),
      );
      return;
    }

    final objetivo = DashboardMuestraUtils.muestraActiva(dashboard.muestras);

    mostrarTrucosPanel(
      context,
      args: TrucosPanelArgs(
        mesaId: mesaId,
        tandaId: tandaId,
        presidenteCatadorId: catadorId,
        muestraObjetivo: objetivo,
        categoria: dashboard.categoria,
        muestrasCache: dashboard.muestras,
        tandaTieneDemo: dashboard.muestras.any((m) => m.esDemo),
        onRecargarDashboard: _reload,
      ),
    );
  }

  void _mostrarEstadisticas(DashboardMuestraStats stats) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estadísticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EstadisticaFila(label: 'Quedan', value: '${stats.quedan}'),
            _EstadisticaFila(label: 'Catadas', value: '${stats.catadas}'),
            _EstadisticaFila(label: 'Pospuestas', value: '${stats.pospuestas}'),
            _EstadisticaFila(
              label: 'Descalificadas',
              value: '${stats.descalificadas}',
            ),
            _EstadisticaFila(
              label: 'Pendientes',
              value: '${stats.pendientes}/${stats.total}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _tapMuestraPendiente(
    MuestraEnTanda muestra,
    TabletDashboard dashboard,
    bool esPresidente,
  ) {
    if (esPresidente &&
        DashboardMuestraUtils.estaPendienteApertura(muestra)) {
      _abrirCataMesa(muestra: muestra, dashboard: dashboard);
      return;
    }
    if (DashboardMuestraUtils.estaActiva(muestra)) {
      _abrirCata(
        context,
        muestra: muestra,
        tanda: dashboard.tanda!,
        catador: dashboard.catador!,
        categoria: dashboard.categoria,
        colorPrimario: dashboard.concursoColorPrimario,
        dashboard: dashboard,
      );
    }
  }

  void _abrirCata(
    BuildContext context, {
    required MuestraEnTanda muestra,
    required Tanda tanda,
    required Catador catador,
    required Categoria? categoria,
    required String? colorPrimario,
    required TabletDashboard dashboard,
  }) {
    final cat = categoria;
    if (cat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay categoría asignada a esta tanda.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<int>(
        builder: (_) => CataPage(
          muestra: muestra,
          tanda: tanda,
          categoria: cat,
          catador: catador,
          esPresidente: _esPresidente(dashboard),
          mesaId: dashboard.mesa?.id ?? catador.mesaId,
          colorPrimario: colorPrimario,
          concursoNombre: dashboard.concurso?.nombre,
          mesaNumero: dashboard.mesaNumero,
          tandaNumero: dashboard.tandaNumero,
          paisCodigo: widget.dispositivo.paisCodigo,
          rolLabel: _rolLabel(dashboard),
          tabletNumero: widget.dispositivo.deviceId,
        ),
      ),
    ).then((ordenAprobada) {
      if (ordenAprobada != null) {
        _reloadTrasAprobar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: FutureBuilder<TabletDashboard>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            );
          }

          if (snapshot.hasError) {
            return Column(
              children: [
                DashboardHeader(
                  concursoNombre: 'Concurso',
                  catadorNombre: widget.dispositivo.catadorNombre,
                  rolLabel: 'Catador',
                  mesaNumero: widget.dispositivo.mesaNumero ?? 0,
                  tandaNumero: null,
                  colorPrimario: null,
                  paisCodigo: widget.dispositivo.paisCodigo,
                  onBack: () => Navigator.of(context).pop(),
                  onRefresh: _reload,
                ),
                Expanded(
                  child: _MessagePanel(
                    title: 'Error al cargar la tanda',
                    message: _formatError(snapshot.error!),
                    action: FilledButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ),
                ),
              ],
            );
          }

          final dashboard = snapshot.data!;
          final stats = DashboardMuestraStats.fromMuestras(dashboard.muestras);
          final muestraActiva =
              DashboardMuestraUtils.muestraActiva(dashboard.muestras);
          final categoriaNombre =
              dashboard.categoria?.nombre ?? 'Sin categoría';
          final tandaAbierta =
              dashboard.tanda?.estado.toLowerCase() == 'abierta';

          if (!_filtroInicializado) {
            _filtro = DashboardMuestraUtils.filtroInicial(dashboard.muestras);
            _filtroInicializado = true;
          }

          final filtro = _filtro == MuestraFiltro.pendientes
              ? MuestraFiltro.catadas
              : (_filtro ?? MuestraFiltro.catadas);
          final muestrasFiltradas = DashboardMuestraUtils.filtrar(
            dashboard.muestras,
            filtro,
          );
          final muestrasPendientes =
              DashboardMuestraUtils.pendientes(dashboard.muestras);

          final esPresidente = _esPresidente(dashboard);
          final puedeAbrirCata = esPresidente &&
              muestraActiva != null &&
              tandaAbierta &&
              dashboard.tanda != null &&
              dashboard.catador != null &&
              DashboardMuestraUtils.estaPendienteApertura(muestraActiva);
          final puedeEntrarCatar = muestraActiva != null &&
              tandaAbierta &&
              dashboard.tanda != null &&
              dashboard.catador != null &&
              DashboardMuestraUtils.estaActiva(muestraActiva);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardHeader(
                concursoNombre: dashboard.concurso?.nombre ?? 'Concurso',
                catadorNombre: dashboard.catadorNombre,
                rolLabel: _rolLabel(dashboard),
                mesaNumero: dashboard.mesaNumero,
                tandaNumero: dashboard.tandaNumero,
                colorPrimario: dashboard.concursoColorPrimario,
                paisCodigo: widget.dispositivo.paisCodigo,
                esPresidente: _esPresidente(dashboard),
                mostrarModoPruebas:
                    esModoPruebas && _esPresidente(dashboard),
                onBack: () => Navigator.of(context).pop(),
                onRefresh: _reload,
                onEstadisticas: () => _mostrarEstadisticas(stats),
                onTrucos: esModoPruebas && _esPresidente(dashboard)
                    ? () => _abrirTrucos(dashboard)
                    : null,
              ),
              Expanded(
                child: Padding(
                  padding: TabletLayout.screenPadding.copyWith(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DashboardInicioTopInfoBar(
                        colorPrimario: dashboard.concursoColorPrimario,
                        tandaNumero: dashboard.tandaNumero,
                        mesaNumero: dashboard.mesaNumero,
                        ordenActual: muestraActiva?.orden ?? 0,
                        ordenTotal: stats.total,
                        categoriaNombre: categoriaNombre,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 4,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      if (dashboard.tanda != null)
                                        MuestraHeroCard(
                                          muestra: muestraActiva,
                                          mesaNumero: dashboard.mesaNumero,
                                          tandaNumero: dashboard.tandaNumero,
                                          categoriaNombre: categoriaNombre,
                                          tandaAbierta: tandaAbierta,
                                          stats: stats,
                                          colorPrimario:
                                              dashboard.concursoColorPrimario,
                                          esPresidente: esPresidente,
                                          showStats: false,
                                          hideSideMeta: true,
                                          flexibleHeight: true,
                                          onAbrirCata: puedeAbrirCata
                                              ? () => _abrirCataMesa(
                                                    muestra: muestraActiva,
                                                    dashboard: dashboard,
                                                  )
                                              : null,
                                          onEntrarCatar: puedeEntrarCatar
                                              ? () => _abrirCata(
                                                    context,
                                                    muestra: muestraActiva,
                                                    tanda: dashboard.tanda!,
                                                    catador:
                                                        dashboard.catador!,
                                                    categoria:
                                                        dashboard.categoria,
                                                    colorPrimario: dashboard
                                                        .concursoColorPrimario,
                                                    dashboard: dashboard,
                                                  )
                                              : null,
                                        )
                                      else
                                        const _SinTandaCard(),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: MuestrasPendientesList(
                                          muestras: muestrasPendientes,
                                          colorPrimario:
                                              dashboard.concursoColorPrimario,
                                          onMuestraTap:
                                              dashboard.tanda != null &&
                                                      dashboard.catador != null
                                                  ? (muestra) =>
                                                      _tapMuestraPendiente(
                                                        muestra,
                                                        dashboard,
                                                        esPresidente,
                                                      )
                                                  : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: VerticalDivider(
                                width: 2,
                                thickness: 2,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _DashboardStatsPanel(
                                        stats: stats,
                                        colorPrimario:
                                            dashboard.concursoColorPrimario,
                                      ),
                                      const SizedBox(height: 8),
                                      MuestrasFilterTabs(
                                        filtroActivo: filtro,
                                        catadasCount: stats.catadas,
                                        descalificadasCount: stats
                                                .descalificadas +
                                            stats.pospuestas,
                                        colorPrimario:
                                            dashboard.concursoColorPrimario,
                                        onChanged: (nuevo) =>
                                            setState(() => _filtro = nuevo),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: dashboard.tanda != null &&
                                                dashboard.catador != null
                                            ? MuestrasList(
                                                muestras: muestrasFiltradas,
                                                filtro: filtro,
                                                colorPrimario: dashboard
                                                    .concursoColorPrimario,
                                                onMuestraTap: (muestra) =>
                                                    _abrirCata(
                                                  context,
                                                  muestra: muestra,
                                                  tanda: dashboard.tanda!,
                                                  catador: dashboard.catador!,
                                                  categoria:
                                                      dashboard.categoria,
                                                  colorPrimario: dashboard
                                                      .concursoColorPrimario,
                                                  dashboard: dashboard,
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  dashboard.tanda == null
                                                      ? 'Asigna una tanda para ver las muestras.'
                                                      : 'No hay catador asignado.',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatError(Object error) {
    if (error is PostgrestException) return error.message;
    return error.toString();
  }
}

class _SinTandaCard extends StatelessWidget {
  const _SinTandaCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MuestraHeroCard.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
        ),
        child: const Center(
          child: Text(
            'No hay tanda asignada a esta mesa.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _DashboardInicioTopInfoBar extends StatelessWidget {
  const _DashboardInicioTopInfoBar({
    required this.colorPrimario,
    required this.tandaNumero,
    required this.mesaNumero,
    required this.ordenActual,
    required this.ordenTotal,
    required this.categoriaNombre,
  });

  final String? colorPrimario;
  final int? tandaNumero;
  final int mesaNumero;
  final int ordenActual;
  final int ordenTotal;
  final String categoriaNombre;

  @override
  Widget build(BuildContext context) {
    final accent = DashboardColors.primario(colorPrimario);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Center(
          child: Text(
            'Tanda ${tandaNumero ?? '—'} · Mesa $mesaNumero · Orden $ordenActual/$ordenTotal · ${categoriaNombre.toUpperCase()}',
            style: VirtusTextStyles.plain(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _DashboardStatsPanel extends StatelessWidget {
  const _DashboardStatsPanel({
    required this.stats,
    required this.colorPrimario,
  });

  final DashboardMuestraStats stats;
  final String? colorPrimario;

  @override
  Widget build(BuildContext context) {
    final accent = DashboardColors.primario(colorPrimario);
    final labelColor = Colors.black.withValues(alpha: 0.55);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: _StatChip(
                label: 'Quedan',
                value: '${stats.quedan}',
                accent: accent,
                labelColor: labelColor,
              ),
            ),
            Expanded(
              child: _StatChip(
                label: 'Catadas',
                value: '${stats.catadas}',
                accent: accent,
                labelColor: labelColor,
              ),
            ),
            Expanded(
              child: _StatChip(
                label: 'Posp.',
                value: '${stats.pospuestas}',
                accent: accent,
                labelColor: labelColor,
              ),
            ),
            Expanded(
              child: _StatChip(
                label: 'Descalif.',
                value: '${stats.descalificadas}',
                accent: accent,
                labelColor: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.accent,
    required this.labelColor,
  });

  final String label;
  final String value;
  final Color accent;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: VirtusTextStyles.plain(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: labelColor,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: VirtusTextStyles.plain(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _EstadisticaFila extends StatelessWidget {
  const _EstadisticaFila({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: VirtusTextStyles.plain(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: VirtusTextStyles.plain(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.title,
    required this.message,
    required this.action,
  });

  final String title;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: TabletLayout.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          action,
        ],
      ),
    );
  }
}
