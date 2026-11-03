import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virtus2027/core/layout/tablet_viewport.dart';
import 'package:virtus2027/core/theme/tablet_theme.dart';
import 'package:virtus2027/core/theme/virtus_system_ui.dart';
import 'package:virtus2027/features/home/presentation/home_page.dart';

class VirtusApp extends StatelessWidget {
  const VirtusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtus 2027',
      debugShowCheckedModeBanner: false,
      theme: TabletTheme.build(),
      builder: (context, child) {
        // Reaplica en cada rebuild: el Theme claro de Material suele forzar iconos negros.
        SystemChrome.setSystemUIOverlayStyle(kVirtusSystemUi);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: kVirtusSystemUi,
          child: Material(
            type: MaterialType.transparency,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const TabletViewport(
        child: HomePage(),
      ),
    );
  }
}
