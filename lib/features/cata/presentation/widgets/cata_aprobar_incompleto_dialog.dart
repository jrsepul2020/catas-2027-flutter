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

  static const _naranja = Color(0xFFE65100);
  static const _texto = Color(0xFF212121);
  static const _textoSec = Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      title: Text(
        'Aprobar con los que hay (${widget.recibidas} de ${widget.total})',
        style: VirtusTextStyles.plain(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: _texto,
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
                color: _textoSec,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final c in widget.faltan)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '· ${c.nombre.toUpperCase()}'
                          '${c.esPresidente ? ' (PRESIDENTE)' : ''}',
                          style: VirtusTextStyles.plain(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _texto,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: _naranja,
              value: _noVolverAAvisar,
              onChanged: (v) =>
                  setState(() => _noVolverAAvisar = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'No volver a avisar en este concurso',
                style: VirtusTextStyles.plain(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _texto,
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
            style: VirtusTextStyles.plain(
              fontWeight: FontWeight.w700,
              color: _textoSec,
            ),
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
            backgroundColor: _naranja,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    builder: (ctx) => CataAprobarIncompletoDialog(
      faltan: faltan,
      recibidas: resumen.puntuacionesRecibidas,
      total: resumen.totalCatadores,
      concursoId: concursoId,
    ),
  );
  return ok == true;
}
