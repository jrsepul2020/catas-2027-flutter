import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virtus2027/app/app.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/layout/tablet_viewport.dart';
import 'package:virtus2027/core/theme/tablet_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    runApp(_BootstrapErrorApp(message: e.toString()));
    return;
  }

  runApp(const VirtusApp());
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: TabletTheme.build(),
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
                      'Error al iniciar',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Configura .env con las credenciales de Supabase.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
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
