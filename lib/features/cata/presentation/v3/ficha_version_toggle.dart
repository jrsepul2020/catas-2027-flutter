import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';

/// Versión visual de la ficha (V4 es la de concurso).
enum FichaUiVersion { v2, v3, v4 }

/// Selector compacto V2 / V3 / V4 (solo [esModoPruebas]).
class FichaVersionToggle extends StatelessWidget {
  const FichaVersionToggle({
    super.key,
    required this.version,
    required this.onChanged,
    this.permiteV3 = true,
  });

  final FichaUiVersion version;
  final ValueChanged<FichaUiVersion> onChanged;
  final bool permiteV3;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CataV2Theme.fondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CataV2Theme.borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chip(
            label: 'V2',
            selected: version == FichaUiVersion.v2,
            onTap: () => onChanged(FichaUiVersion.v2),
          ),
          if (permiteV3)
            _Chip(
              label: 'V3',
              selected: version == FichaUiVersion.v3,
              onTap: () => onChanged(FichaUiVersion.v3),
            ),
          _Chip(
            label: 'V4',
            selected: version == FichaUiVersion.v4,
            onTap: () => onChanged(FichaUiVersion.v4),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? CataV2Theme.cabecera : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: CataV2Theme.text(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: selected ? Colors.white : CataV2Theme.textoSecundario,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

/// True si la categoría admite ficha V3 (vinos tranquilos).
bool categoriaPermiteFichaV3({String? nombre, String? codigo}) {
  final cod = (codigo ?? '').toLowerCase().trim();
  final nom = (nombre ?? '').toLowerCase();
  if (cod == 'ao' ||
      nom.contains('aove') ||
      nom.contains('aceite') ||
      nom.contains('oliva')) {
    return false;
  }
  if (cod == 've' || nom.contains('espumos') || nom.contains('cava')) {
    return false;
  }
  if (cod == 'vg' ||
      nom.contains('generos') ||
      nom.contains('espirituos') ||
      nom.contains('licor')) {
    return false;
  }
  return true;
}
