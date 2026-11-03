import 'package:flutter/material.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/config/supabase_environment.dart';
import 'package:virtus2027/core/services/servidor_estado.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';

/// Chip Local/Nube con color según si el servidor responde.
class ServidorEstadoChip extends StatelessWidget {
  const ServidorEstadoChip({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final esNube = SupabaseConfig.pointsToCloud ||
        SupabaseEnvironment.active.value == SupabaseEntorno.cloud;

    return ListenableBuilder(
      listenable: ServidorEstado.instance,
      builder: (context, _) {
        final estado = ServidorEstado.instance;
        final ok = estado.alcanzable;
        final label = !ok
            ? (esNube ? 'Sin nube' : 'Sin red')
            : (esNube ? 'Nube' : 'Local');
        final icon = !ok
            ? Icons.cloud_off_outlined
            : (esNube ? Icons.cloud_outlined : Icons.wifi);
        final color = ok
            ? const Color(0xFF81C784)
            : const Color(0xFFFF8A80);

        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Tooltip(
            message: ok
                ? (esNube
                    ? 'Servidor en la nube alcanzable'
                    : 'Servidor local (Geekom) alcanzable')
                : (esNube
                    ? 'No hay respuesta del servidor en la nube'
                    : 'No hay respuesta del servidor local (Geekom / red)'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: compact ? 13 : 14, color: color),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: CataV2Theme.text(
                    color: color,
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
