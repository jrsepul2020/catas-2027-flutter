import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virtus2027/app/app.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/layout/tablet_viewport.dart';
import 'package:virtus2027/core/services/conexion_local_probe.dart';
import 'package:virtus2027/core/services/realtime_reconnect_bus.dart';
import 'package:virtus2027/core/services/servidor_estado.dart';
import 'package:virtus2027/core/theme/tablet_theme.dart';
import 'package:virtus2027/core/theme/virtus_system_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(kVirtusSystemUi);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await SupabaseConfig.initialize();
    await ConexionLocalProbe.assertReachableIfLocal();
  } catch (e) {
    final message = e is StateError ? (e.message) : e.toString();
    runApp(_BootstrapErrorApp(message: message));
    return;
  }

  ServidorEstado.instance.start();
  RealtimeReconnectBus.ensureHooks();
  runApp(const VirtusApp());
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: TabletTheme.build(),
      builder: (context, child) {
        return Material(
          type: MaterialType.transparency,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: TabletViewport(
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return ColoredBox(
              color: theme.colorScheme.surface,
              child: Padding(
                padding: TabletLayout.screenPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: TabletLayout.iconSize * 2,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudo arrancar',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: SingleChildScrollView(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Corrige el problema y reinicia la app (hot restart / R).',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
