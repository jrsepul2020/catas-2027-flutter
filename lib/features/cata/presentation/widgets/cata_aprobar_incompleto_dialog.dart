import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/cata/data/aprobacion_prefs.dart';
import 'package:virtus2027/features/cata/domain/puntuacion_mesa_catador.dart';

/// Confirma aprobación parcial: lista quién falta + «No volver a avisar».
class CataAprobarIncompletoDialog extends StatefulWidget {
  const CataAprobarIncompletoDialog({
    super.key,
    required this.faltan,
    required this.recibidas,
    required this.total,
    required this.concursoId,
  });

  final List<PuntuacionMesaCatador> faltan;
  final int recibidas;
  final int total;
  final String concursoId;

  @override
  State<CataAprobarIncompletoDialog> createState() =>
      _CataAprobarIncompletoDialogState();
}

class _CataAprobarIncompletoDialogState
    extends State<CataAprobarIncompletoDialog> {
  bool _noVolverAAvisar = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Aprobar con los que hay (${widget.recibidas} de ${widget.total})',
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
            Text(
              'Faltan por puntuar:',
              style: VirtusTextStyles.plain(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            for (final c in widget.faltan)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '· ${c.nombre.toUpperCase()}'
                  '${c.esPresidente ? ' (PRESIDENTE)' : ''}',
                  style: VirtusTextStyles.plain(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _noVolverAAvisar,
              onChanged: (v) =>
                  setState(() => _noVolverAAvisar = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'No volver a avisar en este concurso',
                style: VirtusTextStyles.plain(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: VirtusTextStyles.plain(fontWeight: FontWeight.w700),
          ),
        ),
        FilledButton(
          onPressed: () async {
            if (_noVolverAAvisar && widget.concursoId.isNotEmpty) {
              await AprobacionPrefs.setOmitirAvisoIncompleto(
                widget.concursoId,
                value: true,
              );
            }
            if (!context.mounted) return;
            Navigator.of(context).pop(true);
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE65100),
          ),
          child: Text(
            'Aprobar con los que hay',
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

/// Si hay que avisar, muestra el diálogo; si no, confirma directamente.
Future<bool> confirmarAprobarIncompleto({
  required BuildContext context,
  required ResumenAprobacionMesa resumen,
  required String concursoId,
}) async {
  final faltan = resumen.catadores.where((c) => !c.recibida).toList();
  if (faltan.isEmpty) return true;

  final omitir = await AprobacionPrefs.omitirAvisoIncompleto(concursoId);
  if (omitir) return true;
  if (!context.mounted) return false;

  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => CataAprobarIncompletoDialog(
      faltan: faltan,
      recibidas: resumen.puntuacionesRecibidas,
      total: resumen.totalCatadores,
      concursoId: concursoId,
    ),
  );
  return ok == true;
}
