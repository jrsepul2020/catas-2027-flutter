import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/layout/tablet_viewport.dart';
import 'package:virtus2027/core/models/catador.dart';
import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/models/tanda.dart';
import 'package:virtus2027/features/cata/data/cata_repository.dart';
import 'package:virtus2027/features/cata/presentation/cata_page.dart';
import 'package:virtus2027/features/dashboard/data/catador_auto_cata_sync.dart';
import 'package:virtus2027/features/dashboard/data/dashboard_realtime_sync.dart';
import 'package:virtus2027/features/dashboard/data/tanda_repository.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/domain/tablet_dashboard.dart';
import 'package:virtus2027/features/dashboard/presentation/utils/dashboard_muestra_utils.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/catador_espera_panel.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestra_hero_card.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestras_filter_tabs.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestras_list.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestras_pendientes_list.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/tanda_completada_panel.dart';
import 'package:virtus2027/config/app_mode.dart';
import 'package:virtus2027/core/services/app_wakelock.dart';
import 'package:virtus2027/core/services/realtime_reconnect_bus.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/home/data/dispositivos_repository.dart';
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
  final _dispositivosRepository = DispositivosRepository();

  late Future<TabletDashboard> _dashboardFuture;
  TabletDashboard? _ultimoDashboard;
  MuestraFiltro? _filtro;
  bool _filtroInicializado = false;
  DashboardRealtimeSync? _realtime;
  String? _realtimeTandaId;
  CatadorAutoCataSync? _autoCata;
  String? _autoCataTandaId;
  String? _cataAbiertaMuestraId;
  bool _abriendoCata = false;
  bool _saliendo = false;
  bool _iniciandoSiguienteTanda = false;
  bool? _haySiguienteTanda;
  String? _haySiguienteParaTandaId;

  @override
  void initState() {
    super.initState();
    unawaited(AppWakelock.enableForSession());
    RealtimeReconnectBus.addListener(_onRealtimeReconnect);
    _load();
    _iniciarRealtimeTrasPrimeraCarga();
  }

  @override
  void dispose() {
    RealtimeReconnectBus.removeListener(_onRealtimeReconnect);
    unawaited(AppWakelock.disable());
    final sync = _realtime;
    _realtime = null;
    sync?.dispose();
    final auto = _autoCata;
    _autoCata = null;
    auto?.dispose();
    super.dispose();
  }

  void _onRealtimeReconnect() {
    if (!mounted || _abriendoCata) return;
    unawaited(_manejarRealtimeDashboard());
  }

  Future<void> _iniciarRealtimeTrasPrimeraCarga() async {
    try {
      final dashboard = await _dashboardFuture;
      if (!mounted) return;
      await _ensureRealtimeSubscription(dashboard.tanda?.id);
      _ensureCatadorAutoSync(dashboard);
      await _sincronizarEstadoTandaCompletada(dashboard);
    } catch (_) {
      // Si falla Realtime, el refresco manual sigue disponible.
    }
  }

  void _ensureCatadorAutoSync(TabletDashboard dashboard) {
    if (_esPresidente(dashboard)) {
      _autoCata?.dispose();
      _autoCata = null;
      _autoCataTandaId = null;
      return;
    }

    final tandaId = dashboard.tanda?.id;
    if (tandaId == null || tandaId.isEmpty) return;
    if (_autoCataTandaId == tandaId && _autoCata != null) {
      if (_cataAbiertaMuestraId == null) _autoCata!.resumePoll();
      return;
    }

    _autoCata?.dispose();
    _autoCataTandaId = tandaId;
    _autoCata = CatadorAutoCataSync(
      tandaId: tandaId,
      onMuestraActiva: (muestraId) {
        unawaited(_abrirCataAutomaticaCatador(muestraId));
      },
    );
    _autoCata!.start();
  }

  bool _mismoId(String a, String b) {
    if (a == b) return true;
    final ia = int.tryParse(a);
    final ib = int.tryParse(b);
    return ia != null && ib != null && ia == ib;
  }

  Future<void> _abrirCataAutomaticaCatador(String muestraId) async {
    if (!mounted || _abriendoCata) return;
    if (_cataAbiertaMuestraId != null &&
        _mismoId(_cataAbiertaMuestraId!, muestraId)) {
      return;
    }

    // Siempre datos frescos de Supabase (no el FutureBuilder cacheado).
    TabletDashboard dashboard;
    try {
      dashboard = await _repository.fetchForDispositivo(widget.dispositivo);
    } catch (_) {
      return;
    }
    if (!mounted || _esPresidente(dashboard)) return;
    if (dashboard.tanda == null || dashboard.catador == null) return;
    if (dashboard.categoria == null) return;

    MuestraEnTanda? muestra;
    for (final m in dashboard.muestras) {
      if (_mismoId(m.muestraId, muestraId) &&
          !DashboardMuestraUtils.estaCatada(m)) {
        muestra = m;
        break;
      }
    }
    // Fallback: cualquier muestra activa de la tanda.
    muestra ??= DashboardMuestraUtils.muestraActiva(dashboard.muestras);
    if (muestra == null ||
        DashboardMuestraUtils.estaCatada(muestra) ||
        !DashboardMuestraUtils.estaActiva(muestra)) {
      return;
    }
    if (!mounted) return;

    _abriendoCata = true;
    _cataAbiertaMuestraId = muestra.muestraId;
    _autoCata?.pausePoll();

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
    unawaited(_manejarRealtimeDashboard());
  }

  Future<void> _manejarRealtimeDashboard() async {
    setState(() => _load(resetFiltro: false));
    try {
      final dashboard = await _dashboardFuture;
      if (!mounted) return;
      await _ensureRealtimeSubscription(dashboard.tanda?.id);
      _ensureCatadorAutoSync(dashboard);
      await _sincronizarEstadoTandaCompletada(dashboard);
      if (_esPresidente(dashboard) || _abriendoCata) return;
      if (DashboardMuestraUtils.tandaCompletada(dashboard.muestras)) return;
      // Si el presidente acaba de abrir, no esperar solo al poll.
      MuestraEnTanda? activa;
      for (final m in dashboard.muestras) {
        if (DashboardMuestraUtils.estaActiva(m) &&
            !DashboardMuestraUtils.estaCatada(m)) {
          activa = m;
          break;
        }
      }
      if (activa != null) {
        await _abrirCataAutomaticaCatador(activa.muestraId);
      }
    } catch (_) {
      // Best-effort.
    }
  }

  /// Si la tanda está completa: cierra ficha abierta y consulta si hay siguiente.
  Future<void> _sincronizarEstadoTandaCompletada(
    TabletDashboard dashboard,
  ) async {
    final completa =
        DashboardMuestraUtils.tandaCompletada(dashboard.muestras);
    if (!completa) {
      if (_haySiguienteTanda != null || _haySiguienteParaTandaId != null) {
        setState(() {
          _haySiguienteTanda = null;
          _haySiguienteParaTandaId = null;
        });
      }
      return;
    }

    _cerrarFichaSiAbierta();

    final tandaId = dashboard.tanda?.id;
    final mesaId = dashboard.mesa?.id ?? dashboard.catador?.mesaId;
    if (tandaId == null || mesaId == null || mesaId.isEmpty) {
      setState(() {
        _haySiguienteTanda = false;
        _haySiguienteParaTandaId = tandaId;
      });
      return;
    }
    if (_haySiguienteParaTandaId == tandaId && _haySiguienteTanda != null) {
      return;
    }
    final hay = await _repository.haySiguienteTanda(
      mesaId: mesaId,
      tandaActualId: tandaId,
    );
    if (!mounted) return;
    setState(() {
      _haySiguienteTanda = hay;
      _haySiguienteParaTandaId = tandaId;
    });
  }

  void _cerrarFichaSiAbierta() {
    final habiaFicha = _cataAbiertaMuestraId != null || _abriendoCata;
    if (!habiaFicha) return;
    _cataAbiertaMuestraId = null;
    _abriendoCata = false;
    _autoCata?.resumePoll();
    if (!mounted) return;
    // Solo cerrar la ficha (ruta encima); no salir al home.
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _iniciarSiguienteTanda(TabletDashboard dashboard) async {
    if (_iniciandoSiguienteTanda) return;
    final tandaId = dashboard.tanda?.id;
    final mesaId = dashboard.mesa?.id ?? dashboard.catador?.mesaId;
    if (tandaId == null || mesaId == null || mesaId.isEmpty) return;

    setState(() => _iniciandoSiguienteTanda = true);
    try {
      await _repository.iniciarSiguienteTanda(
        mesaId: mesaId,
        tandaActualId: tandaId,
      );
      if (!mounted) return;
      setState(() {
        _haySiguienteTanda = null;
        _haySiguienteParaTandaId = null;
        _iniciandoSiguienteTanda = false;
      });
      await _reload();
    } catch (e) {
      if (!mounted) return;
      setState(() => _iniciandoSiguienteTanda = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatError(e))),
      );
    }
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
    _ensureCatadorAutoSync(dashboard);
  }

  Future<void> _reloadTrasAprobar() async {
    setState(() {
      _filtro = MuestraFiltro.catadas;
      _filtroInicializado = true;
      _load(resetFiltro: false);
    });
    final dashboard = await _dashboardFuture;
    if (!mounted) return;
    _ensureCatadorAutoSync(dashboard);
    await _sincronizarEstadoTandaCompletada(dashboard);
  }

  Future<void> _confirmarSalir() async {
    if (_saliendo) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salir'),
        content: const Text(
          '¿Volver a la selección de tablets?\n\n'
          '(Salida temporal para pruebas; en producción se bloqueará.)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    _saliendo = true;
    final catadorId = widget.dispositivo.catadorId;
    try {
      if (catadorId != null && catadorId.isNotEmpty) {
        await _dispositivosRepository.releaseCatador(catadorId);
      }
    } catch (_) {
      // Liberar es best-effort; siempre volvemos a la cuadrícula.
    }
    if (!mounted) return;
    Navigator.of(context).pop();
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
    if (DashboardMuestraUtils.estaIncidencia(muestra) ||
        DashboardMuestraUtils.muestraEnIncidencia(dashboard.muestras) !=
            null) {
      return;
    }
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

  void _tapMuestraLista(
    MuestraEnTanda muestra,
    TabletDashboard dashboard,
    bool esPresidente,
  ) {
    if (DashboardMuestraUtils.estaCatada(muestra)) {
      if (esPresidente) {
        unawaited(_mostrarDialogoMuestraCerrada(muestra, dashboard));
      }
      return;
    }
    if (DashboardMuestraUtils.estaIncidencia(muestra) ||
        DashboardMuestraUtils.muestraEnIncidencia(dashboard.muestras) !=
            null) {
      return;
    }
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

  Future<void> _mostrarDialogoMuestraCerrada(
    MuestraEnTanda muestra,
    TabletDashboard dashboard,
  ) async {
    final tanda = dashboard.tanda;
    if (tanda == null) return;

    final pedir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Muestra ${muestra.codigoDisplay}'),
        content: const Text(
          'Muestra cerrada. Para recatar, pide permiso al administrador',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Pedir recata al admin'),
          ),
        ],
      ),
    );

    if (pedir != true || !mounted) return;

    try {
      await CataRepository().marcarIncidencia(
        tandaId: tanda.id,
        muestraId: muestra.muestraId,
        motivo: 'RECATA solicitada',
      );
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is PostgrestException ? e.message : e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _abrirCata(
    BuildContext context, {
    required MuestraEnTanda muestra,
    required Tanda tanda,
    required Catador catador,
    required Categoria? categoria,
    required String? colorPrimario,
    required TabletDashboard dashboard,
  }) async {
    Categoria? cat = categoria;
    final muestraCatId = muestra.categoriaId;
    if (muestraCatId != null &&
        muestraCatId.isNotEmpty &&
        muestraCatId != cat?.id) {
      cat = await _repository.getCategoriaById(muestraCatId) ?? cat;
    }
    if (!mounted) return;
    if (cat == null) {
      _abriendoCata = false;
      _cataAbiertaMuestraId = null;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('No hay categoría asignada a esta tanda.')),
      );
      return;
    }

    _abriendoCata = true;
    _cataAbiertaMuestraId = muestra.muestraId;
    _autoCata?.pausePoll();

    final esPresidente = _esPresidente(dashboard);
    Navigator.of(this.context)
        .push(
      MaterialPageRoute<Object?>(
        builder: (_) {
          final page = CataPage(
            muestra: muestra,
            tanda: tanda,
            categoria: cat!,
            catador: catador,
            esPresidente: esPresidente,
            mesaId: dashboard.mesa?.id ?? catador.mesaId,
            colorPrimario: colorPrimario,
            concursoId: dashboard.concurso?.id,
            concursoNombre: dashboard.concurso?.nombre,
            mesaNumero: dashboard.mesaNumero,
            tandaNumero: dashboard.tandaNumero,
            paisCodigo: widget.dispositivo.paisCodigo,
            rolLabel: _rolLabel(dashboard),
            tabletNumero: widget.dispositivo.deviceId,
            tandaMuestrasTotal: dashboard.muestras.length,
            medallaGranOro: dashboard.concurso?.granOro,
            medallaOro: dashboard.concurso?.oro,
            medallaPlata: dashboard.concurso?.plata,
          );
          return TabletViewport(child: page);
        },
      ),
    )
        .then((result) async {
      _abriendoCata = false;
      _cataAbiertaMuestraId = null;
      if (!mounted) return;
      if (result != null) {
        await _reloadTrasAprobar();
      } else {
        await _reload();
      }
      _autoCata?.resumePoll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: FutureBuilder<TabletDashboard>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _ultimoDashboard = snapshot.data;
          }
          final dashboard = snapshot.data ?? _ultimoDashboard;

          if (dashboard == null) {
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
                    onBack: esModoPruebas ? _confirmarSalir : null,
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
            return const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            );
          }
          final stats = DashboardMuestraStats.fromMuestras(dashboard.muestras);
          final muestraIncidencia =
              DashboardMuestraUtils.muestraEnIncidencia(dashboard.muestras);
          final muestraActiva =
              DashboardMuestraUtils.muestraEnFoco(dashboard.muestras);
          final categoriaNombre =
              dashboard.categoria?.nombre ?? 'Sin categoría';
          final tandaAbierta =
              dashboard.tanda?.estado.toLowerCase() == 'abierta';
          final mesaEnIncidencia = muestraIncidencia != null;

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
              !mesaEnIncidencia &&
              muestraActiva != null &&
              tandaAbierta &&
              dashboard.tanda != null &&
              dashboard.catador != null &&
              DashboardMuestraUtils.estaPendienteApertura(muestraActiva);
          // Presidente: entrar a ficha si la muestra ya está activa.
          final puedeContinuarCata = esPresidente &&
              !mesaEnIncidencia &&
              muestraActiva != null &&
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
                esPresidente: esPresidente,
                mostrarModoPruebas: esModoPruebas && esPresidente,
                puesto: dashboard.catador?.codigoCatador,
                tabletNumero: widget.dispositivo.deviceId,
                onBack: _confirmarSalir,
                salirConHold: !esModoPruebas,
                onRefresh: _reload,
                onEstadisticas: esPresidente
                    ? () => _mostrarEstadisticas(stats)
                    : null,
                onTrucos: esModoPruebas && esPresidente
                    ? () => _abrirTrucos(dashboard)
                    : null,
              ),
              Expanded(
                child: DashboardMuestraUtils.tandaCompletada(
                        dashboard.muestras)
                    ? TandaCompletadaPanel(
                        esPresidente: esPresidente,
                        haySiguienteTanda: _haySiguienteTanda ?? false,
                        tandaNumero: dashboard.tandaNumero,
                        iniciando: _iniciandoSiguienteTanda,
                        onIniciarSiguiente: esPresidente
                            ? () => _iniciarSiguienteTanda(dashboard)
                            : null,
                      )
                    : !esPresidente
                    ? CatadorEsperaPanel(
                        catadas: stats.catadas,
                        total: stats.total,
                        proximaOrden: mesaEnIncidencia
                            ? null
                            : muestraActiva?.orden,
                        muestrasCatadas: DashboardMuestraUtils.filtrar(
                          dashboard.muestras,
                          MuestraFiltro.catadas,
                        ),
                        categoriaFallback: categoriaNombre,
                        enIncidencia: mesaEnIncidencia,
                        incidenciaMotivo:
                            muestraIncidencia?.incidenciaMotivo,
                      )
                    : Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mitad izquierda: hero + pendientes (mismo ancho).
                      Expanded(
                        child: Column(
                          children: [
                            dashboard.tanda != null
                                ? MuestraHeroCard(
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
                                    onEntrarCatar: puedeContinuarCata
                                        ? () => _abrirCata(
                                              context,
                                              muestra: muestraActiva,
                                              tanda: dashboard.tanda!,
                                              catador: dashboard.catador!,
                                              categoria:
                                                  dashboard.categoria,
                                              colorPrimario: dashboard
                                                  .concursoColorPrimario,
                                              dashboard: dashboard,
                                            )
                                        : null,
                                  )
                                : const _SinTandaCard(),
                            const SizedBox(height: 6),
                            Expanded(
                              child: MuestrasPendientesList(
                                muestras: muestrasPendientes,
                                colorPrimario:
                                    dashboard.concursoColorPrimario,
                                categoriaNombre: categoriaNombre,
                                muestraDestacadaId:
                                    muestraActiva?.muestraId,
                                destacadaEnCurso: muestraActiva != null &&
                                    DashboardMuestraUtils.estaActiva(
                                      muestraActiva,
                                    ),
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
                      const SizedBox(width: 8),
                      // Mitad derecha: catadas / descalificadas.
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
                            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                MuestrasFilterTabs(
                                  filtroActivo: filtro,
                                  catadasCount: stats.catadas,
                                  descalificadasCount:
                                      stats.descalificadas +
                                          stats.pospuestas,
                                  colorPrimario:
                                      dashboard.concursoColorPrimario,
                                  onChanged: (nuevo) =>
                                      setState(() => _filtro = nuevo),
                                ),
                                const SizedBox(height: 3),
                                Expanded(
                                  child: dashboard.tanda != null &&
                                          dashboard.catador != null
                                      ? MuestrasList(
                                          muestras: muestrasFiltradas,
                                          filtro: filtro,
                                          colorPrimario: dashboard
                                              .concursoColorPrimario,
                                          categoriaFallback:
                                              categoriaNombre,
                                          onMuestraTap: (muestra) =>
                                              _tapMuestraLista(
                                            muestra,
                                            dashboard,
                                            esPresidente,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            dashboard.tanda == null
                                                ? 'Asigna una tanda para ver las muestras.'
                                                : 'No hay catador asignado.',
                                            style: DashboardType.body(
                                              color: Colors.white70,
                                            ),
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
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CataV2Theme.superficie,
          borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
          border: Border.all(color: CataV2Theme.borde),
        ),
        child: Center(
          child: Text(
            'No hay tanda asignada a esta mesa.',
            style: DashboardType.body(
              color: CataV2Theme.textoSecundario,
            ),
          ),
        ),
      ),
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
