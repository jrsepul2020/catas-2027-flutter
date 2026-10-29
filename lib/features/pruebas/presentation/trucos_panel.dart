import 'package:flutter/material.dart';
import 'package:virtus2027/config/app_mode.dart';
import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/pruebas/trucos_repository.dart';

/// Abre el panel TRUCOS (solo si [esModoPruebas] y presidente).
Future<void> mostrarTrucosPanel(
  BuildContext context, {
  required TrucosPanelArgs args,
}) async {
  if (!esModoPruebas) return;
  await showDialog<void>(
    context: context,
    builder: (_) => TrucosPanel(args: args),
  );
}

class TrucosPanelArgs {
  const TrucosPanelArgs({
    required this.mesaId,
    required this.tandaId,
    required this.presidenteCatadorId,
    required this.muestraObjetivo,
    required this.categoria,
    this.muestrasCache,
    this.tandaTieneDemo = false,
    this.onRecargarDashboard,
  });

  final String mesaId;
  final String tandaId;
  final String presidenteCatadorId;
  final MuestraEnTanda? muestraObjetivo;
  final Categoria? categoria;
  final List<MuestraEnTanda>? muestrasCache;
  final bool tandaTieneDemo;
  final Future<void> Function()? onRecargarDashboard;
}

class TrucosPanel extends StatefulWidget {
  const TrucosPanel({super.key, required this.args});

  final TrucosPanelArgs args;

  @override
  State<TrucosPanel> createState() => _TrucosPanelState();
}

class _TrucosPanelState extends State<TrucosPanel> {
  final _repo = TrucosRepository();
  bool _busy = false;

  MuestraEnTanda? get _muestra => widget.args.muestraObjetivo;
  bool get _esDemo => TrucosRepository.esMuestraDemo(_muestra);

  Future<void> _run(
    Future<String> Function() action, {
    bool recargarDashboard = false,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final msg = await action();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      if (recargarDashboard) {
        Navigator.of(context).pop();
        await widget.args.onRecargarDashboard?.call();
        return;
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codigo = _muestra?.codigoDisplay ?? '—';

    return AlertDialog(
      title: Text(
        'TRUCOS · PRUEBAS',
        style: VirtusTextStyles.plain(
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Muestra objetivo: $codigo'
              '${_esDemo ? ' (DEMO)' : ''}',
              style: VirtusTextStyles.plain(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            if (!_esDemo) ...[
              const SizedBox(height: 8),
              Text(
                'Solo muestras DEMO',
                style: VirtusTextStyles.plain(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _TrucoBoton(
              label: 'Rellenar notas de los otros catadores',
              enabled: _esDemo && !_busy && _muestra != null,
              disabledHint: 'Solo muestras DEMO',
              onPressed: () => _run(() {
                return _repo.rellenarNotasOtrosCatadores(
                  mesaId: widget.args.mesaId,
                  tandaId: widget.args.tandaId,
                  muestraId: _muestra!.muestraId,
                  presidenteCatadorId: widget.args.presidenteCatadorId,
                  categoria: widget.args.categoria,
                );
              }),
            ),
            const SizedBox(height: 8),
            _TrucoBoton(
              label: 'Reiniciar esta muestra',
              enabled: _esDemo &&
                  !_busy &&
                  (_muestra?.tandaMuestraId?.isNotEmpty ?? false),
              disabledHint: 'Solo muestras DEMO',
              onPressed: () => _run(
                () {
                  return _repo.reiniciarMuestraDemo(
                    tandaMuestraId: _muestra!.tandaMuestraId!,
                  );
                },
                recargarDashboard: true,
              ),
            ),
            const SizedBox(height: 8),
            _TrucoBoton(
              label: 'Reiniciar toda la tanda demo',
              enabled: !_busy &&
                  (widget.args.tandaTieneDemo ||
                      (widget.args.muestrasCache?.any((m) => m.esDemo) ??
                          false)),
              disabledHint: 'Solo muestras DEMO',
              onPressed: () => _run(
                () {
                  return _repo.reiniciarTandaDemo(
                    tandaId: widget.args.tandaId,
                    muestrasCache: widget.args.muestrasCache,
                  );
                },
                recargarDashboard: true,
              ),
            ),
            if (_busy) ...[
              const SizedBox(height: 16),
              const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cerrar',
            style: VirtusTextStyles.plain(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _TrucoBoton extends StatelessWidget {
  const _TrucoBoton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    required this.disabledHint,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final String disabledHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            backgroundColor: const Color(0xFF455A64),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: VirtusTextStyles.plain(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        if (!enabled)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              disabledHint,
              style: VirtusTextStyles.plain(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }
}
