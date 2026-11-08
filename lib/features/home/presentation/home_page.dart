import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/services/app_wakelock.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/core/layout/tablet_viewport.dart';
import 'package:virtus2027/core/widgets/app_version_label.dart';
import 'package:virtus2027/core/widgets/nube_badge.dart';
import 'package:virtus2027/core/widgets/tablet_scaffold.dart';
import 'package:virtus2027/features/dashboard/presentation/dashboard_page.dart';
import 'package:virtus2027/features/home/data/dispositivos_repository.dart';
import 'package:virtus2027/features/home/domain/dispositivo_home_item.dart';
import 'package:virtus2027/features/home/presentation/widgets/dispositivos_grid.dart';
import 'package:virtus2027/features/home/presentation/widgets/entorno_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = DispositivosRepository();

  late Future<List<DispositivoHomeItem>> _dispositivosFuture;
  bool _entrando = false;

  @override
  void initState() {
    super.initState();
    AppWakelock.disable();
    _dispositivosFuture = _repository.fetchDispositivos();
  }

  Future<void> _reload() async {
    setState(() {
      _dispositivosFuture = _repository.fetchDispositivos();
    });
    await _dispositivosFuture;
  }

  @override
  Widget build(BuildContext context) {
    return TabletScaffold(
      title: 'Virtus 2027',
      actions: [
        const EntornoSelector(),
        const NubeBadge(),
        const AppVersionLabel(),
        IconButton(
          onPressed: _reload,
          iconSize: TabletLayout.headerIconSize,
          icon: const Icon(Icons.refresh),
          tooltip: 'Actualizar',
        ),
      ],
      body: FutureBuilder<List<DispositivoHomeItem>>(
        future: _dispositivosFuture,
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
            return _ErrorView(
              message: _formatLoadError(snapshot.error!),
              onRetry: _reload,
            );
          }

          return Stack(
            children: [
              DispositivosGrid(
                dispositivos: snapshot.data ?? [],
                onDispositivoTap: _onDispositivoTap,
              ),
              if (_entrando)
                const ColoredBox(
                  color: Color(0x33000000),
                  child: Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onDispositivoTap(DispositivoHomeItem item) async {
    if (_entrando) return;

    final catadorId = item.catadorId;
    if (catadorId == null || catadorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta tablet no tiene catador asignado.')),
      );
      return;
    }

    setState(() => _entrando = true);
    try {
      final claimed = await _repository.tryClaimCatador(catadorId);
      if (!mounted) return;

      if (claimed) {
        await _openDashboard(item);
        return;
      }

      final forzar = await _mostrarDialogoEnUso();
      if (!mounted) return;
      if (forzar != true) return;

      await _repository.forceClaimCatador(catadorId);
      if (!mounted) return;
      await _openDashboard(item);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatLoadError(e))),
      );
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  Future<bool?> _mostrarDialogoEnUso() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Tablet en uso',
            style: VirtusTextStyles.plain(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Esta tablet figura en uso. ¿Entrar igualmente?',
            style: VirtusTextStyles.plain(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121),
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Cancelar',
                style: VirtusTextStyles.plain(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Entrar',
                style: VirtusTextStyles.plain(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDashboard(DispositivoHomeItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          final page = DashboardPage(dispositivo: item);
          // Presidente: canvas 1003×627 (Chrome = tablet).
          if (item.esPresidente) {
            return TabletViewport(child: page);
          }
          return page;
        },
      ),
    );
    if (!mounted) return;
    await _reload();
  }

  String _formatLoadError(Object error) {
    if (error is PostgrestException) return error.message;
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('Failed host lookup') ||
        text.contains('failed host lookup')) {
      return 'Sin conexión a internet o no se puede contactar con Supabase. '
          'Comprueba la red Wi‑Fi de la tablet e inténtalo de nuevo.';
    }
    return text;
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: TabletLayout.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: TabletLayout.iconSize * 1.6,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'No se pudieron cargar los dispositivos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: TabletLayout.errorTitleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: TabletLayout.iconSize),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
