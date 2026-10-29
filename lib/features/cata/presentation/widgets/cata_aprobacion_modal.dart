import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/data/cata_aprobacion_realtime_sync.dart';
import 'package:virtus2027/features/cata/data/cata_repository.dart';
import 'package:virtus2027/features/cata/domain/puntuacion_mesa_catador.dart';
import 'package:virtus2027/features/cata/presentation/widgets/cata_aprobacion_dialog.dart';

class CataAprobacionModal extends StatefulWidget {
  const CataAprobacionModal({
    super.key,
    required this.mesaId,
    required this.tandaId,
    required this.muestraId,
    required this.codigoMuestra,
    required this.onVolver,
    required this.onRevisar,
    required this.onAprobar,
    this.repository,
  });

  final String mesaId;
  final String tandaId;
  final String muestraId;
  final String codigoMuestra;
  final VoidCallback onVolver;
  final VoidCallback onRevisar;
  final Future<void> Function() onAprobar;
  final CataRepository? repository;

  @override
  State<CataAprobacionModal> createState() => _CataAprobacionModalState();
}

class _CataAprobacionModalState extends State<CataAprobacionModal> {
  late final CataRepository _repository;
  CataAprobacionRealtimeSync? _realtime;

  ResumenAprobacionMesa? _resumen;
  String? _error;
  bool _cargandoInicial = true;
  bool _actualizando = false;
  bool _aprobando = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? CataRepository();
    _cargarResumen(inicial: true);
    _realtime = CataAprobacionRealtimeSync(
      tandaId: widget.tandaId,
      muestraId: widget.muestraId,
      onChanged: () => _cargarResumen(inicial: false),
    );
    _realtime!.subscribe();
  }

  @override
  void dispose() {
    _realtime?.dispose();
    super.dispose();
  }

  Future<void> _cargarResumen({required bool inicial}) async {
    if (!mounted) return;
    setState(() {
      if (inicial) {
        _cargandoInicial = true;
        _error = null;
      } else {
        _actualizando = true;
      }
    });

    try {
      final resumen = await _repository.getResumenMesa(
        mesaId: widget.mesaId,
        tandaId: widget.tandaId,
        muestraId: widget.muestraId,
        codigoMuestra: widget.codigoMuestra,
      );
      if (!mounted) return;
      setState(() {
        _resumen = resumen;
        _cargandoInicial = false;
        _actualizando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargandoInicial = false;
        _actualizando = false;
      });
    }
  }

  Future<void> _aprobar() async {
    setState(() => _aprobando = true);
    try {
      await widget.onAprobar();
    } catch (_) {
      // El callback ya muestra el error al usuario.
    } finally {
      if (mounted) setState(() => _aprobando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoInicial && _resumen == null) {
      return const Dialog(
        child: SizedBox(
          width: 120,
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null && _resumen == null) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(_error!),
        actions: [
          TextButton(onPressed: widget.onVolver, child: const Text('Cerrar')),
        ],
      );
    }

    final resumen = _resumen;
    if (resumen == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        CataAprobacionDialog(
          resumen: resumen,
          aprobando: _aprobando,
          onVolver: widget.onVolver,
          onRevisar: widget.onRevisar,
          onAprobar: _aprobar,
          onAprobarAdmin: _aprobar,
        ),
        if (_actualizando)
          Positioned(
            top: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Actualizando…',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
