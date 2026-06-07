import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/widgets/tablet_scaffold.dart';
import 'package:virtus2027/features/home/data/catadores_repository.dart';
import 'package:virtus2027/features/home/domain/catador_slot.dart';
import 'package:virtus2027/features/dashboard/presentation/dashboard_page.dart';
import 'package:virtus2027/features/home/presentation/widgets/catadores_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = CatadoresRepository();

  late Future<List<CatadorSlot>> _slotsFuture;

  @override
  void initState() {
    super.initState();
    _slotsFuture = _repository.fetchSlots();
  }

  Future<void> _reload() async {
    setState(() {
      _slotsFuture = _repository.fetchSlots();
    });
    await _slotsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return TabletScaffold(
      title: 'Virtus 2027',
      actions: [
        IconButton(
          onPressed: _reload,
          iconSize: TabletLayout.headerIconSize,
          icon: const Icon(Icons.refresh),
          tooltip: 'Actualizar',
        ),
      ],
      body: FutureBuilder<List<CatadorSlot>>(
        future: _slotsFuture,
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

          return CatadoresGrid(
            slots: snapshot.data ?? [],
            onSlotTap: _openDashboard,
          );
        },
      ),
    );
  }

  void _openDashboard(CatadorSlot slot) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DashboardPage(slot: slot),
      ),
    );
  }

  String _formatLoadError(Object error) {
    if (error is PostgrestException) {
      if (error.message.contains('posicion')) {
        return '${error.message}\n\nCierra la app (q) y vuelve a ejecutar: flutter run';
      }
      return error.message;
    }
    return error.toString();
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
            'No se pudieron cargar los catadores',
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
