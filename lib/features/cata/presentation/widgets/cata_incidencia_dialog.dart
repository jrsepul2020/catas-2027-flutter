import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';

/// Motivos fijos del modal DESCARTAR / incidencia.
abstract final class IncidenciaMotivos {
  static const abiertaPorError = 'Abierta por error';
  static const muestraDefectuosa = 'Muestra defectuosa';
  static const otroMotivo = 'Otro motivo';

  static const todos = [
    abiertaPorError,
    muestraDefectuosa,
    otroMotivo,
  ];
}

class CataIncidenciaDialog extends StatefulWidget {
  const CataIncidenciaDialog({
    super.key,
    required this.codigoMuestra,
  });

  final String codigoMuestra;

  @override
  State<CataIncidenciaDialog> createState() => _CataIncidenciaDialogState();
}

class _CataIncidenciaDialogState extends State<CataIncidenciaDialog> {
  String? _motivo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Avisar de un problema con la muestra ${widget.codigoMuestra}',
        style: VirtusTextStyles.plain(
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final motivo in IncidenciaMotivos.todos) ...[
              InkWell(
                onTap: () => setState(() => _motivo = motivo),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        _motivo == motivo
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 22,
                        color: _motivo == motivo
                            ? CataColors.acento
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          motivo,
                          style: VirtusTextStyles.plain(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Se avisará al administrador. No se pasará a la siguiente '
              'muestra hasta que él lo indique.',
              style: VirtusTextStyles.plain(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: VirtusTextStyles.plain(fontWeight: FontWeight.w700),
          ),
        ),
        FilledButton(
          onPressed: _motivo == null
              ? null
              : () => Navigator.of(context).pop(_motivo),
          style: FilledButton.styleFrom(
            backgroundColor: CataColors.acento,
          ),
          child: Text(
            'Confirmar incidencia',
            style: VirtusTextStyles.plain(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
