import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';

/// Scaffold acotado al canvas 1003×627 (sin AppBar variable de Material).
class TabletScaffold extends StatelessWidget {
  const TabletScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final String title;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          SizedBox(
            height: TabletLayout.headerHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  ...actions,
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
