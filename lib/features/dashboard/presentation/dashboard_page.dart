import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/widgets/tablet_scaffold.dart';
import 'package:virtus2027/features/dashboard/data/tanda_repository.dart';
import 'package:virtus2027/features/dashboard/domain/tablet_dashboard.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/muestras_tanda_list.dart';
import 'package:virtus2027/features/dashboard/presentation/widgets/tanda_summary_card.dart';
import 'package:virtus2027/features/home/domain/catador_slot.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.slot});

  final CatadorSlot slot;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repository = TandaRepository();

  late Future<TabletDashboard> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _dashboardFuture = _repository.fetchForTablet(
      tabletNumero: widget.slot.posicion,
      catadorNombre: widget.slot.nombreCatador,
    );
  }

  Future<void> _reload() async {
    setState(_load);
    await _dashboardFuture;
  }

  @override
  Widget build(BuildContext context) {
    final catador = widget.slot.tieneCatador
        ? widget.slot.nombreCatador
        : 'Sin catador asignado';

    return TabletScaffold(
      title: 'Tablet ${widget.slot.posicion}',
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          iconSize: TabletLayout.headerIconSize,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
        ),
        IconButton(
          onPressed: _reload,
          iconSize: TabletLayout.headerIconSize,
          icon: const Icon(Icons.refresh),
          tooltip: 'Actualizar',
        ),
      ],
      body: FutureBuilder<TabletDashboard>(
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
            return _MessagePanel(
              title: 'Error al cargar la tanda',
              message: snapshot.error.toString(),
              action: FilledButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            );
          }

          final dashboard = snapshot.data!;

          return Padding(
            padding: TabletLayout.screenPadding.copyWith(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  catador,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (dashboard.tanda != null)
                  TandaSummaryCard(tanda: dashboard.tanda!)
                else
                  const _SinTandaCard(),
                const SizedBox(height: 8),
                Text(
                  'Muestras de la tanda',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: MuestrasTandaList(muestras: dashboard.muestras),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SinTandaCard extends StatelessWidget {
  const _SinTandaCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TabletLayout.slotRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text('No hay tanda asignada a esta tablet.'),
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
