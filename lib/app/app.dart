import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_viewport.dart';
import 'package:virtus2027/core/theme/tablet_theme.dart';
import 'package:virtus2027/features/home/presentation/home_page.dart';

class VirtusApp extends StatelessWidget {
  const VirtusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtus 2027',
      debugShowCheckedModeBanner: false,
      theme: TabletTheme.build(),
      home: const TabletViewport(
        child: HomePage(),
      ),
    );
  }
}
