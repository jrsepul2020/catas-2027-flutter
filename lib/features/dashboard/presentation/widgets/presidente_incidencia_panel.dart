import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';

/// Pantalla del presidente mientras hay una incidencia pendiente de admin.
class PresidenteIncidenciaPanel extends StatelessWidget {
  const PresidenteIncidenciaPanel({
    super.key,
    required this.codigoMuestra,
    required this.motivo,
  });

  final String codigoMuestra;
  final String motivo;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.report_gmailerrorred_rounded,
                size: 72,
                color: Color(0xFFE65100),
              ),
              const SizedBox(height: 18),
              Text(
                'INCIDENCIA ENVIADA',
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: VirtusColors.oscuro,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Avisa al administrador. Esperando instrucciones.',
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: VirtusColors.secundario,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Muestra $codigoMuestra',
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE65100),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                motivo,
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
