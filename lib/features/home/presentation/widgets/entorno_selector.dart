import 'package:flutter/material.dart';
import 'package:virtus2027/config/app_mode.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/config/supabase_environment.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';

/// Selector Cloud/Local. Solo visible con [esModoPruebas].
/// Al cambiar, guarda y reinicia la app (no cambia el cliente en caliente).
class EntornoSelector extends StatefulWidget {
  const EntornoSelector({super.key});

  @override
  State<EntornoSelector> createState() => _EntornoSelectorState();
}

class _EntornoSelectorState extends State<EntornoSelector> {
  bool _busy = false;

  Future<void> _select(SupabaseEntorno entorno) async {
    if (_busy || SupabaseEnvironment.active.value == entorno) return;
    setState(() => _busy = true);
    try {
      await SupabaseConfig.saveEntornoAndRestart(entorno);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cambiar de entorno: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!esModoPruebas) return const SizedBox.shrink();

    return ValueListenableBuilder<SupabaseEntorno>(
      valueListenable: SupabaseEnvironment.active,
      builder: (context, activo, _) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ENTORNO',
                style: VirtusTextStyles.plain(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withValues(alpha: 0.45),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              SegmentedButton<SupabaseEntorno>(
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 8),
                  ),
                  textStyle: WidgetStatePropertyAll(
                    VirtusTextStyles.plain(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: SupabaseEntorno.local,
                    label: Text('LOCAL'),
                  ),
                  ButtonSegment(
                    value: SupabaseEntorno.cloud,
                    label: Text('CLOUD'),
                  ),
                ],
                selected: {activo},
                onSelectionChanged: _busy
                    ? null
                    : (s) {
                        if (s.isEmpty) return;
                        _select(s.first);
                      },
              ),
              if (_busy) ...[
                const SizedBox(width: 6),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
