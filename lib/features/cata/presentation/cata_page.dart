import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/models/catador.dart';
import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/models/tanda.dart';
import 'package:virtus2027/features/cata/data/cata_page_realtime_sync.dart';
import 'package:virtus2027/features/cata/data/cata_repository.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_form_layout.dart';
import 'package:virtus2027/config/app_mode.dart';
import 'package:virtus2027/features/cata/presentation/widgets/cata_aprobacion_modal.dart';
import 'package:virtus2027/features/cata/presentation/widgets/cata_espera_aprobacion_dialog.dart';
import 'package:virtus2027/features/cata/presentation/widgets/cata_header_bar.dart';
import 'package:virtus2027/features/cata/presentation/widgets/cata_info_panel.dart';
import 'package:virtus2027/features/cata/presentation/widgets/cata_resumen_panel.dart';
import 'package:virtus2027/features/cata/presentation/widgets/grupo_criterios.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
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
    this.concursoNombre,
    this.mesaNumero,
    this.tandaNumero,
    this.paisCodigo,
    this.rolLabel,
    this.tabletNumero,
  });

  final MuestraEnTanda muestra;
  final Tanda tanda;
  final Categoria categoria;
  final Catador catador;
  final bool esPresidente;
  final String? mesaId;
  final String? colorPrimario;
  final String? concursoNombre;
  final int? mesaNumero;
  final int? tandaNumero;
  final String? paisCodigo;
  final String? rolLabel;
  final int? tabletNumero;

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
  String? _error;
  CataPageRealtimeSync? _realtimeSalida;

  @override
  void initState() {
    super.initState();
    _ficha = FichaDefinicion.vinosTranquilos();
    _scores.addAll(_ficha.valoresPorDefecto());
    _cargarPuntuacion();
    if (!widget.esPresidente) {
      _realtimeSalida = CataPageRealtimeSync(
        tandaId: widget.tanda.id,
        muestraId: widget.muestra.muestraId,
        catadorId: widget.catador.id,
        onAprobada: _salirAlDashboardTrasAprobacion,
      );
      _realtimeSalida!.subscribe();
    }
  }

  @override
  void dispose() {
    _realtimeSalida?.dispose();
    super.dispose();
  }

  void _salirAlDashboardTrasAprobacion() {
    if (!mounted || widget.esPresidente) return;
    final nav = Navigator.of(context);
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      nav.pop();
    }
    if (!mounted) return;
    if (nav.canPop()) {
      nav.pop(widget.muestra.orden);
    }
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
      final guardada = await _repository.getPuntuacion(
        catadorId: widget.catador.id,
        muestraId: widget.muestra.muestraId,
        tandaId: widget.tanda.id,
      );

      if (!mounted) return;

      setState(() {
        if (guardada != null) {
          _scores.addAll(
            _ficha.remapScores(
              guardada.scores,
              fichaDb: widget.categoria.ficha,
            ),
          );
          _soloLectura = guardada.soloLectura;
          _puntuacionEnviada =
              guardada.estado.toLowerCase() == 'enviada' && !guardada.soloLectura;
        }
        _cargando = false;
      });

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

  int get _progresoPct {
    final total = _ficha.todosLosCriterios.length;
    if (total == 0) return 100;
    return (((total - _faltanCriterios) / total) * 100).round();
  }

  bool get _todosCompletos =>
      _ficha.todosLosCriterios.isNotEmpty && _faltanCriterios == 0;

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
    setState(() => _puntuacionEnviada = false);
  }

  void _onScoreChanged(String criterioId, num value) {
    if (!_formularioEditable) return;
    setState(() => _scores[criterioId] = value);
  }

  void _reiniciar() {
    if (!_formularioEditable) return;
    setState(() {
      _scores
        ..clear()
        ..addAll(_ficha.valoresPorDefecto());
      _puntuacionEnviada = false;
    });
  }

  Future<void> _guardar(String estado) async {
    if (!_formularioEditable || _guardando) return;

    setState(() => _guardando = true);

    try {
      await _repository.savePuntuacion(
        catadorId: widget.catador.id,
        muestraId: widget.muestra.muestraId,
        tandaId: widget.tanda.id,
        scores: Map<String, num>.from(_scores),
        total: _totalActual,
        estado: estado,
      );

      if (!mounted) return;

      if (estado == 'enviada') {
        setState(() => _puntuacionEnviada = true);
        if (widget.esPresidente) {
          await _mostrarModalPresidente();
        } else {
          await _mostrarModalCatador();
        }
        return;
      }
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
      backgroundColor: CataColors.fondoPagina,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CataHeaderBar(
            catadorNombre: widget.catador.nombre,
            rolLabel: _rolDisplay,
            mesaNumero: widget.mesaNumero ?? 0,
            tandaNumero: widget.tandaNumero,
            puesto: widget.catador.codigoCatador,
            tabletNumero: widget.tabletNumero,
            progresoPct: _progresoPct,
            mostrarModoPruebas: esModoPruebas && widget.esPresidente,
            onBack: () => Navigator.of(context).pop(),
            onRefresh: _cargarPuntuacion,
            onTrucos: esModoPruebas && widget.esPresidente ? _abrirTrucos : null,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 168,
            height: CataFormLayout.alturaObjetivo,
            child: CataInfoPanel(
              concursoNombre:
                  widget.concursoNombre ?? widget.categoria.nombre,
              catadorNombre: widget.catador.nombre,
              paisCodigo: widget.paisCodigo ?? widget.catador.pais,
              puesto: widget.catador.codigoCatador,
              categoriaNombre: widget.categoria.nombre,
              codigoMuestra: widget.muestra.codigoDisplay,
              readOnly: !_formularioEditable,
              onReiniciar: _reiniciar,
              onDescartar: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: CataFormLayout.alturaObjetivo,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        for (final grupo in _ficha.grupos)
                          Expanded(
                            flex: grupo.criterios.length,
                            child: GrupoCriterios(
                              grupo: grupo,
                              scores: _scores,
                              readOnly: !_formularioEditable,
                              fillHeight: true,
                              onScoreChanged: _onScoreChanged,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 158,
            height: CataFormLayout.alturaObjetivo,
            child: CataResumenPanel(
              totalActual: _totalActual,
              totalMin: _ficha.totalMin,
              totalMax: _ficha.totalMax,
              faltanCriterios: _faltanCriterios,
              readOnly: _soloLectura,
              guardando: _guardando,
              puedeEnviar: _todosCompletos && _formularioEditable,
              onEnviar: () => _guardar('enviada'),
            ),
          ),
        ],
      ),
    );
  }
}
