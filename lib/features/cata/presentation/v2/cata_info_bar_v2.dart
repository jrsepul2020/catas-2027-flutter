import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';
import 'package:virtus2027/features/home/utils/pais_flag.dart';

/// Bloque de identificación bajo el top bar (ficha V2).
///
/// Se oculta entero con [CataV2Theme.mostrarInfoAdministrador] = false.
class CataInfoBarV2 extends StatelessWidget {
  const CataInfoBarV2({
    super.key,
    required this.codigoMuestra,
    required this.categoriaNombre,
    required this.catadorNombre,
    required this.paisCodigo,
    required this.mesaNumero,
    required this.tandaNumero,
    required this.puesto,
    required this.tabletNumero,
    required this.criteriosCompletos,
    required this.criteriosTotal,
    required this.progresoPct,
  });

  final String codigoMuestra;
  final String categoriaNombre;
  final String catadorNombre;
  final String? paisCodigo;
  final int mesaNumero;
  final int? tandaNumero;
  final int? puesto;
  final int? tabletNumero;
  final int criteriosCompletos;
  final int criteriosTotal;
  final int progresoPct;

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    if (!CataV2Theme.mostrarInfoAdministrador) {
      return const SizedBox.shrink();
    }

    final meta = <String>[
      'Mesa $mesaNumero',
      if (tandaNumero != null) 'Tanda $tandaNumero',
      if (puesto != null) 'Puesto $puesto',
      if (tabletNumero != null) 'Tablet $tabletNumero',
    ].join(' · ');

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: CataV2Theme.superficie,
        border: Border(
          bottom: BorderSide(color: CataV2Theme.borde),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(
            'Muestra',
            style: CataV2Theme.text(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: CataV2Theme.textoMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            codigoMuestra,
            style: CataV2Theme.text(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: CataV2Theme.texto,
              height: 1,
            ),
          ),
          _sep(),
          Flexible(
            child: Text(
              categoriaNombre,
              style: CataV2Theme.text(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CataV2Theme.textoSecundario,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _sep(),
          Text(
            PaisFlag.emoji(paisCodigo),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              catadorNombre,
              style: CataV2Theme.text(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CataV2Theme.textoSecundario,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _sep(),
          Flexible(
            child: Text(
              meta,
              style: CataV2Theme.text(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: CataV2Theme.textoMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Text(
            '$criteriosCompletos/$criteriosTotal',
            style: CataV2Theme.text(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: CataV2Theme.textoSecundario,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 88,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (progresoPct / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: CataV2Theme.borde,
                color: const Color(0xFF43A047),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 1,
        height: 18,
        color: CataV2Theme.borde,
      ),
    );
  }
}
