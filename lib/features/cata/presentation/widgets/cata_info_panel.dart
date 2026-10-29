import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';
import 'package:virtus2027/features/home/utils/pais_flag.dart';

class CataInfoPanel extends StatelessWidget {
  const CataInfoPanel({
    super.key,
    required this.concursoNombre,
    required this.catadorNombre,
    required this.paisCodigo,
    required this.puesto,
    required this.categoriaNombre,
    required this.codigoMuestra,
    required this.readOnly,
    required this.onReiniciar,
    required this.onDescartar,
  });

  final String concursoNombre;
  final String catadorNombre;
  final String? paisCodigo;
  final int? puesto;
  final String categoriaNombre;
  final String codigoMuestra;
  final bool readOnly;
  final VoidCallback? onReiniciar;
  final VoidCallback? onDescartar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
          child: Text(
            _logoTexto(concursoNombre),
            textAlign: TextAlign.center,
            style: VirtusTextStyles.plain(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: CataColors.logo,
              height: 1.15,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const Spacer(flex: 2),
        _Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                PaisFlag.emoji(paisCodigo),
                style: const TextStyle(fontSize: 42, height: 1.1),
              ),
              const SizedBox(height: 10),
              Text(
                catadorNombre.toUpperCase(),
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF212121),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (puesto != null) ...[
                const SizedBox(height: 6),
                Text(
                  'PUESTO $puesto',
                  textAlign: TextAlign.center,
                  style: VirtusTextStyles.plain(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Spacer(flex: 2),
        _Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'CATEGORÍA',
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                categoriaNombre.toUpperCase(),
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: CataColors.acento,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),
        _Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Nº MUESTRA',
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                codigoMuestra,
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: CataColors.muestraNumero,
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 3),
        if (!readOnly) ...[
          _ActionButton(
            label: 'REINICIAR',
            icon: Icons.restart_alt,
            onPressed: onReiniciar,
          ),
          const SizedBox(height: 8),
          _ActionButton(
            label: 'DESCARTAR',
            icon: Icons.close,
            onPressed: onDescartar,
          ),
        ],
      ],
    );
  }

  String _logoTexto(String nombre) {
    final partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes.first.toUpperCase()}\n${partes.sublist(1).join(' ').toUpperCase()}';
    }
    return nombre.toUpperCase();
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: child,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: CataColors.acento,
        side: BorderSide(color: CataColors.acento.withValues(alpha: 0.85)),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: VirtusTextStyles.plain(
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: CataColors.acento,
        ),
      ),
    );
  }
}
