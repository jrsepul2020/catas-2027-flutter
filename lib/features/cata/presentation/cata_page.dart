import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/models/catador.dart';
import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/models/tanda.dart';
import 'package:virtus2027/features/cata/data/cata_page_realtime_sync.dart';
import 'package:virtus2027/features/cata/data/cata_repository.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/config/app_mode.dart';
import 'package:virtus2027/core/services/app_wakelock.dart';
import 'package:virtus2027/core/services/realtime_reconnect_bus.dart';
import 'package:virtus2027/features/cata/presentation/widgets/cata_aprobacion_modal.dart';
import 'package:virtus2027/features/cata/presentation/widgets/cata_espera_aprobacion_dialog.dart';
import 'package:virtus2027/features/cata/presentation/widgets/cata_incidencia_dialog.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_grupo_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_form_v2.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_header_v2.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/cata/presentation/v3/cata_form_v3.dart';
import 'package:virtus2027/features/cata/presentation/v3/ficha_version_toggle.dart';
import 'package:virtus2027/features/cata/presentation/v4/cata_form_v4.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/home/data/dispositivos_repository.dart';
import 'package:virtus2027/features/pruebas/presentation/trucos_panel.dart';
import 'package:virtus2027/features/pruebas/trucos_repository.dart';

class CataPage extends StatefulWidget {
  const CataPage({
    super.key,
    required this.muestra,
    required this.tanda,
    required this.categoria,
    required this.catador,
    required this.esPresidente,
    this.mesaId,
    this.colorPrimario,
    this.concursoId,
    this.concursoNombre,
    this.mesaNumero,
    this.tandaNumero,
    this.paisCodigo,
    this.rolLabel,
    this.tabletNumero,
    this.tandaMuestrasTotal,
    this.medallaGranOro,
    this.medallaOro,
    this.medallaPlata,
  });

  final MuestraEnTanda muestra;
  final Tanda tanda;
  final Categoria categoria;
  final Catador catador;
  final bool esPresidente;
  final String? mesaId;
  final String? colorPrimario;
  final String? concursoId;
  final String? concursoNombre;
  final int? mesaNumero;
  final int? tandaNumero;
  final String? paisCodigo;
  final String? rolLabel;
  final int? tabletNumero;
  /// Total de muestras de la tanda (ya cargado en dashboard; sin consulta extra).
  final int? tandaMuestrasTotal;
  /// Umbrales de medalla desde `concursos` (Supabase).
  final double? medallaGranOro;
  final double? medallaOro;
  final double? medallaPlata;

  @override
  State<CataPage> createState() => _CataPageState();
}

class _CataPageState extends State<CataPage> {
  final _repository = CataRepository();

  late final FichaDefinicion _ficha;

  final Map<String, num> _scores = {};
  bool _cargando = true;
  bool _guardando = false;
  bool _soloLectura = false;
  bool _puntuacionEnviada = false;
  /// Criterios a resaltar tras pulsar Enviar con ficha incompleta.
  Set<String> _criteriosResaltados = {};
  Timer? _resalteTimer;
  Timer? _retryEnvioTimer;
  bool _envioEnVuelo = false;
  String? _bannerEnvio;
  String? _error;
  CataPageRealtimeSync? _realtimeSalida;
  /// UI de ficha. En concurso siempre V4; V2/V3 solo con [esModoPruebas].
  FichaUiVersion _fichaUi = FichaUiVersion.v4;
  static const _prefsFichaUi = 'ficha_ui_version';

  bool get _permiteFichaV3 => categoriaPermiteFichaV3(
        nombre: widget.categoria.nombre,
        codigo: widget.categoria.codigo,
      );

  @override
  void initState() {
    super.initState();
    unawaited(AppWakelock.enableForSession());
    RealtimeReconnectBus.addListener(_onRealtimeReconnect);
    _ficha = FichaDefinicion.deCategoria(
      widget.categoria.ficha,
      nombre: widget.categoria.nombre,
      codigo: widget.categoria.codigo,
    );
    if (esModoPruebas) unawaited(_cargarPreferenciaFichaUi());
    // Sin valores por defecto: total empieza en 0 y suma al marcar.
    _cargarPuntuacion();
    if (!widget.esPresidente) {
      _realtimeSalida = CataPageRealtimeSync(
        tandaId: widget.tanda.id,
        muestraId: widget.muestra.muestraId,
        catadorId: widget.catador.id,
        onForzarSalida: _forzarSalidaAlDashboard,
      );
      _realtimeSalida!.subscribe();
    }
  }

  Future<void> _cargarPreferenciaFichaUi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsFichaUi);
      if (!mounted || raw == null) return;
      final parsed = switch (raw) {
        'v2' => FichaUiVersion.v2,
        'v3' => FichaUiVersion.v3,
        'v4' => FichaUiVersion.v4,
        _ => null,
      };
      if (parsed == null) return;
      if (parsed == FichaUiVersion.v3 && !_permiteFichaV3) return;
      setState(() => _fichaUi = parsed);
    } catch (_) {}
  }

  Future<void> _setFichaUi(FichaUiVersion value) async {
    setState(() => _fichaUi = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsFichaUi,
        switch (value) {
          FichaUiVersion.v2 => 'v2',
          FichaUiVersion.v3 => 'v3',
          FichaUiVersion.v4 => 'v4',
        },
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _resalteTimer?.cancel();
    _retryEnvioTimer?.cancel();
    RealtimeReconnectBus.removeListener(_onRealtimeReconnect);
    _realtimeSalida?.dispose();
    super.dispose();
  }

  void _onRealtimeReconnect() {
    if (!mounted) return;
    unawaited(_cargarPuntuacion());
  }

  /// Cierra diálogos (p. ej. «Revisar mi puntuación») y vuelve al dashboard.
  /// Se dispara al aprobar o al cambiar el presidente de muestra.
  void _forzarSalidaAlDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cerrarOverlaysYSalir();
    });
  }

  void _cerrarOverlaysYSalir() {
    if (!mounted || widget.esPresidente) return;
    final nav = Navigator.of(context);
    // Cierra diálogos encima (espera aprobación, etc.) y luego la ficha.
    var guard = 0;
    while (mounted && guard < 5) {
      guard++;
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        nav.pop();
        continue;
      }
      break;
    }
    if (!mounted) return;
    if (nav.canPop()) {
      nav.pop(widget.muestra.orden);
    }
  }

  /// Truco: hold 3 s en el título del concurso → pantalla de catadores.
  Future<void> _salirAInicioTruco() async {
    final catadorId = widget.catador.id;
    try {
      if (catadorId.isNotEmpty) {
        await DispositivosRepository().releaseCatador(catadorId);
      }
    } catch (_) {
      // Liberar es best-effort.
    }
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _abrirTrucos() async {
    if (!esModoPruebas || !widget.esPresidente) return;
    final mesaId = widget.mesaId ?? widget.catador.mesaId;
    if (mesaId == null || mesaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay mesa para trucos.')),
      );
      return;
    }

    var tandaTieneDemo = widget.muestra.esDemo;
    if (!tandaTieneDemo) {
      try {
        tandaTieneDemo =
            await TrucosRepository().tandaTieneDemo(widget.tanda.id);
      } catch (_) {
        // El botón de tanda se deshabilitará si no hay DEMO.
      }
    }

    if (!mounted) return;
    await mostrarTrucosPanel(
      context,
      args: TrucosPanelArgs(
        mesaId: mesaId,
        tandaId: widget.tanda.id,
        presidenteCatadorId: widget.catador.id,
        muestraObjetivo: widget.muestra,
        categoria: widget.categoria,
        muestrasCache: [widget.muestra],
        tandaTieneDemo: tandaTieneDemo,
        onRecargarDashboard: () async {
          if (!mounted) return;
          Navigator.of(context).pop('trucos');
        },
      ),
    );
  }

  Future<void> _ejecutarAprobacion(BuildContext dialogContext) async {
    try {
      await _repository.aprobarMuestra(
        tandaId: widget.tanda.id,
        muestraId: widget.muestra.muestraId,
      );
      if (!dialogContext.mounted) return;
      Navigator.of(dialogContext).pop();
      if (!mounted) return;
      Navigator.of(context).pop(widget.muestra.orden);
    } catch (e) {
      if (!dialogContext.mounted) return;
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(content: Text(_formatError(e))),
      );
    }
  }

  Future<void> _cargarPuntuacion() async {
    try {
      var guardada = await _repository.getPuntuacion(
        catadorId: widget.catador.id,
        muestraId: widget.muestra.muestraId,
        tandaId: widget.tanda.id,
      );

      // Recata: si la nota sigue 'aprobada' pero la muestra está abierta,
      // intentamos desbloquear en BD; si el trigger lo impide, editamos en UI.
      var forzarEditable = false;
      if (guardada != null && guardada.soloLectura) {
        final ok = await _repository.desbloquearPuntuacionesSiRecata(
          tandaId: widget.tanda.id,
          muestraId: widget.muestra.muestraId,
        );
        if (ok) {
          guardada = await _repository.getPuntuacion(
            catadorId: widget.catador.id,
            muestraId: widget.muestra.muestraId,
            tandaId: widget.tanda.id,
          );
        } else {
          final admite = await _repository.muestraAdmiteEdicion(
            tandaId: widget.tanda.id,
            muestraId: widget.muestra.muestraId,
          );
          forzarEditable = admite;
        }
      }

      if (!mounted) return;

      setState(() {
        if (guardada != null) {
          _scores
            ..clear()
            ..addAll(
              _ficha.remapScores(
                guardada.scores,
                fichaDb: widget.categoria.ficha,
              ),
            );
          _soloLectura = forzarEditable ? false : guardada.soloLectura;
          _puntuacionEnviada = forzarEditable
              ? false
              : (guardada.estado.toLowerCase() == 'enviada' &&
                  !guardada.soloLectura);
        }
        _cargando = false;
        _error = null;
      });

      if (_puntuacionEnviada) {
        _realtimeSalida?.setPollRespaldoActivo(true);
      }
      if (_puntuacionEnviada && !widget.esPresidente) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mostrarModalCatador();
        });
      } else if (_puntuacionEnviada && widget.esPresidente) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mostrarModalPresidente();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _formatError(e);
        _cargando = false;
      });
    }
  }

  double get _totalActual =>
      _scores.values.fold<double>(0, (sum, v) => sum + v.toDouble());

  int get _faltanCriterios {
    var faltan = 0;
    for (final criterio in _ficha.todosLosCriterios) {
      if (!_scores.containsKey(criterio.id)) faltan++;
    }
    return faltan;
  }

  bool get _todosCompletos =>
      _ficha.todosLosCriterios.isNotEmpty && _faltanCriterios == 0;

  /// Solo cuando falta exactamente un criterio (UI V2).
  FichaCriterio? get _criterioUnicoPendiente {
    if (_faltanCriterios != 1) return null;
    for (final c in _ficha.todosLosCriterios) {
      if (!_scores.containsKey(c.id)) return c;
    }
    return null;
  }

  String get _rolDisplay {
    if (widget.rolLabel?.trim().isNotEmpty == true) {
      return widget.rolLabel!;
    }
    final rol = widget.catador.rol?.trim();
    if (rol != null && rol.isNotEmpty) return rol;
    return 'Catador';
  }

  bool get _formularioEditable => !_soloLectura && !_puntuacionEnviada;

  void _habilitarRevision() {
    _pararReintentoEnvio();
    setState(() {
      _puntuacionEnviada = false;
      _guardando = false;
      _bannerEnvio = null;
    });
    _realtimeSalida?.setPollRespaldoActivo(false);
  }

  void _onScoreChanged(String criterioId, num value) {
    if (!_formularioEditable) return;
    setState(() {
      _scores[criterioId] = value;
      if (_criteriosResaltados.isNotEmpty) {
        _criteriosResaltados = Set<String>.from(_criteriosResaltados)
          ..remove(criterioId);
      }
    });
  }

  void _reiniciar() {
    if (!_formularioEditable) return;
    setState(() {
      _scores.clear();
      _puntuacionEnviada = false;
      _criteriosResaltados = {};
    });
    _realtimeSalida?.setPollRespaldoActivo(false);
  }

  Future<void> _confirmarReiniciar() async {
    if (!_formularioEditable) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar'),
        content: Text(
          '¿Borrar los ${_ficha.todosLosCriterios.length} criterios?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _reiniciar();
  }

  MedallaUmbrales get _umbralesMedalla => MedallaUmbrales(
        granOro: widget.medallaGranOro ?? 92,
        oro: widget.medallaOro ?? 85,
        plata: widget.medallaPlata ?? 82,
      );

  /// TEMPORAL (modo pruebas): rellena criterios con total aleatorio 82–100.
  void _rellenarPruebaAlto() {
    if (!esModoPruebas || !_formularioEditable) return;
    setState(() {
      _scores
        ..clear()
        ..addAll(_ficha.scoresPruebaSobre87());
      _criteriosResaltados = {};
    });
  }

  /// Si faltan criterios, no envía y los resalta ~2 s.
  void _onEnviar() {
    if (!_formularioEditable || _guardando) return;
    if (!_todosCompletos) {
      _resalteTimer?.cancel();
      setState(() {
        _criteriosResaltados = _ficha.todosLosCriterios
            .where((c) => !_scores.containsKey(c.id))
            .map((c) => c.id)
            .toSet();
      });
      _resalteTimer = Timer(CataV2Theme.resaltePendientes, () {
        if (!mounted) return;
        setState(() => _criteriosResaltados = {});
      });
      return;
    }
    _iniciarEnvioConReintento();
  }

  void _iniciarEnvioConReintento() {
    if (!_formularioEditable || _guardando) return;
    setState(() {
      _guardando = true;
      _bannerEnvio = null;
    });
    unawaited(_intentarEnviarPuntuacion(esReintento: false));
  }

  bool _esErrorMuestraCerrada(Object error) {
    final msg = _formatError(error).toUpperCase();
    return msg.contains('MUESTRA_APROBADA') ||
        msg.contains('MUESTRA YA') ||
        msg.contains('YA FUE CERRADA');
  }

  Future<bool> _muestraSigueActiva() async {
    try {
      final estado = await _repository.getEstadoMuestra(
        tandaId: widget.tanda.id,
        muestraId: widget.muestra.muestraId,
      );
      if (estado == null) return true;
      return estado == 'activa' || estado == 'en_curso';
    } catch (_) {
      return true;
    }
  }

  Future<void> _intentarEnviarPuntuacion({required bool esReintento}) async {
    if (!mounted || _envioEnVuelo || _puntuacionEnviada) return;
    _envioEnVuelo = true;

    try {
      if (esReintento) {
        final activa = await _muestraSigueActiva();
        if (!activa) {
          _pararReintentoEnvio();
          if (!mounted) return;
          setState(() {
            _guardando = false;
            _bannerEnvio = widget.esPresidente
                ? 'La muestra ya fue cerrada'
                : 'La muestra ya está cerrada por el presidente';
          });
          return;
        }
      }

      await _repository.savePuntuacion(
        catadorId: widget.catador.id,
        muestraId: widget.muestra.muestraId,
        tandaId: widget.tanda.id,
        scores: Map<String, num>.from(_scores),
        total: _totalActual,
        estado: 'enviada',
      );

      if (!mounted) return;
      _pararReintentoEnvio();
      setState(() {
        _guardando = false;
        _puntuacionEnviada = true;
        _bannerEnvio = 'Enviada ✔';
      });
      _realtimeSalida?.setPollRespaldoActivo(true);
      if (widget.esPresidente) {
        await _mostrarModalPresidente();
      } else {
        await _mostrarModalCatador();
      }
    } catch (e) {
      if (!mounted) return;
      if (_esErrorMuestraCerrada(e)) {
        _pararReintentoEnvio();
        setState(() {
          _guardando = false;
          _bannerEnvio = widget.esPresidente
              ? 'La muestra ya fue cerrada'
              : 'La muestra ya está cerrada por el presidente';
        });
        return;
      }
      setState(() {
        _bannerEnvio = 'NOTA NO ENVIADA · reintentando...';
      });
      _retryEnvioTimer ??= Timer.periodic(
        const Duration(seconds: 3),
        (_) => unawaited(_intentarEnviarPuntuacion(esReintento: true)),
      );
    } finally {
      _envioEnVuelo = false;
    }
  }

  void _pararReintentoEnvio() {
    _retryEnvioTimer?.cancel();
    _retryEnvioTimer = null;
  }

  Future<void> _onDescartarIncidencia() async {
    if (!widget.esPresidente || _guardando) return;
    final motivo = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CataIncidenciaDialog(
        codigoMuestra: widget.muestra.codigoDisplay,
      ),
    );
    if (motivo == null || !mounted) return;

    setState(() => _guardando = true);
    try {
      await _repository.marcarIncidencia(
        tandaId: widget.tanda.id,
        muestraId: widget.muestra.muestraId,
        motivo: motivo,
      );
      if (!mounted) return;
      Navigator.of(context).pop(widget.muestra.orden);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatError(e))),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _mostrarModalCatador() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CataEsperaAprobacionDialog(
        ficha: _ficha,
        scores: _scores,
        total: _totalActual,
        codigoMuestra: widget.muestra.codigoDisplay,
        muestraOrden: widget.muestra.orden,
        tandaMuestrasTotal: widget.tandaMuestrasTotal,
        onRevisar: () {
          Navigator.of(context).pop();
          _habilitarRevision();
        },
      ),
    );
  }

  Future<void> _mostrarModalPresidente() async {
    final mesaId = widget.mesaId ?? widget.catador.mesaId;
    if (mesaId == null || mesaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la mesa de cata.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CataAprobacionModal(
          mesaId: mesaId,
          tandaId: widget.tanda.id,
          muestraId: widget.muestra.muestraId,
          codigoMuestra: widget.muestra.codigoDisplay,
          repository: _repository,
          concursoId: widget.concursoId ?? '',
          onVolver: () => Navigator.of(dialogContext).pop(),
          onRevisar: () {
            Navigator.of(dialogContext).pop();
            _habilitarRevision();
          },
          onAprobar: () => _ejecutarAprobacion(dialogContext),
        );
      },
    );
  }

  String _formatError(Object error) {
    if (error is PostgrestException) return error.message;
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CataV2Theme.fondo,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CataHeaderV2(
            concursoNombre: widget.concursoNombre ?? widget.categoria.nombre,
            mostrarModoPruebas: esModoPruebas && widget.esPresidente,
            onBack: widget.esPresidente
                ? () => Navigator.of(context).pop()
                : null,
            onRefresh: _cargarPuntuacion,
            onTrucos:
                esModoPruebas && widget.esPresidente ? _abrirTrucos : null,
            onSalirInicio: _salirAInicioTruco,
            rolLabel: _rolDisplay,
            mesaNumero: widget.mesaNumero ?? 0,
            tandaNumero: widget.tandaNumero,
            puesto: widget.catador.codigoCatador,
            tabletNumero: widget.tabletNumero,
            catadorNombre: widget.catador.nombre,
            paisCodigo: widget.paisCodigo ?? widget.catador.pais,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: TabletLayout.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error al cargar la puntuación',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _cargarPuntuacion,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ficha.grupos.isEmpty) {
      return const Center(
        child: Text('Esta categoría no tiene ficha configurada.'),
      );
    }

    final unico = _criterioUnicoPendiente;
    final criteriosCompletos =
        _ficha.todosLosCriterios.length - _faltanCriterios;
    final versionActiva =
        esModoPruebas ? _fichaUi : FichaUiVersion.v4;
    final selector = esModoPruebas
        ? FichaVersionToggle(
            version: versionActiva == FichaUiVersion.v3 && !_permiteFichaV3
                ? FichaUiVersion.v4
                : versionActiva,
            permiteV3: _permiteFichaV3,
            onChanged: (v) => unawaited(_setFichaUi(v)),
          )
        : null;

    final Widget form = switch (versionActiva) {
      FichaUiVersion.v3 when _permiteFichaV3 => CataFormV3(
          ficha: _ficha,
          scores: _scores,
          readOnly: !_formularioEditable,
          onScoreChanged: _onScoreChanged,
          totalActual: _totalActual,
          umbrales: _umbralesMedalla,
          faltanCriterios: _faltanCriterios,
          criteriosCompletos: criteriosCompletos,
          codigoMuestra: widget.muestra.codigoDisplay,
          categoriaNombre: widget.categoria.nombre,
          guardando: _guardando,
          fichaCompleta: _todosCompletos,
          criteriosResaltados: _criteriosResaltados,
          idCriterioUnicoPendiente: unico?.id,
          nombreCriterioUnicoPendiente: unico?.label,
          onEnviar: _onEnviar,
          onReiniciar: _formularioEditable ? _confirmarReiniciar : null,
          onDescartar:
              widget.esPresidente ? _onDescartarIncidencia : null,
          bannerEnvio: _bannerEnvio,
          selectorVersion: selector,
        ),
      FichaUiVersion.v2 => CataFormV2(
          ficha: _ficha,
          scores: _scores,
          readOnly: !_formularioEditable,
          onScoreChanged: _onScoreChanged,
          totalActual: _totalActual,
          umbrales: _umbralesMedalla,
          faltanCriterios: _faltanCriterios,
          criteriosCompletos: criteriosCompletos,
          codigoMuestra: widget.muestra.codigoDisplay,
          categoriaNombre: widget.categoria.nombre,
          guardando: _guardando,
          fichaCompleta: _todosCompletos,
          criteriosResaltados: _criteriosResaltados,
          idCriterioUnicoPendiente: unico?.id,
          nombreCriterioUnicoPendiente: unico?.label,
          onEnviar: _onEnviar,
          onReiniciar: _formularioEditable ? _confirmarReiniciar : null,
          onDescartar:
              widget.esPresidente ? _onDescartarIncidencia : null,
          bannerEnvio: _bannerEnvio,
          selectorVersion: selector,
        ),
      _ => CataFormV4(
          ficha: _ficha,
          scores: _scores,
          readOnly: !_formularioEditable,
          onScoreChanged: _onScoreChanged,
          totalActual: _totalActual,
          umbrales: _umbralesMedalla,
          criteriosCompletos: criteriosCompletos,
          codigoMuestra: widget.muestra.codigoDisplay,
          categoriaNombre: widget.categoria.nombre,
          guardando: _guardando,
          fichaCompleta: _todosCompletos,
          criteriosResaltados: _criteriosResaltados,
          onEnviar: _onEnviar,
          onReiniciar: _formularioEditable ? _confirmarReiniciar : null,
          onIncidencia:
              widget.esPresidente ? _onDescartarIncidencia : null,
          bannerEnvio: _bannerEnvio,
          selectorVersion: selector,
        ),
    };

    // TEMPORAL: botón relleno >87 (solo esModoPruebas). Quitar en producción.
    if (!esModoPruebas || !_formularioEditable) return form;

    // Rayito: esquina inferior derecha del panel de criterios (no tapa
    // banda de grupo ni etiquetas; el panel lateral queda a la derecha).
    return Stack(
      children: [
        form,
        Positioned(
          right: 248,
          bottom: 10,
          child: Material(
            color: const Color(0xFFE65100),
            elevation: 6,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _rellenarPruebaAlto,
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.bolt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
