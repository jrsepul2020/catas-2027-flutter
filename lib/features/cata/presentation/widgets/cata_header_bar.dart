import 'package:flutter/material.dart';
import 'package:virtus2027/core/layout/tablet_layout.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';
import 'package:virtus2027/core/widgets/status_bar_spacer.dart';
import 'package:virtus2027/features/cata/presentation/utils/cata_colors.dart';

class CataHeaderBar extends StatelessWidget {
  const CataHeaderBar({
    super.key,
    required this.catadorNombre,
    required this.rolLabel,
    required this.mesaNumero,
    required this.tandaNumero,
    required this.progresoPct,
    this.puesto,
    this.tabletNumero,
    this.mostrarModoPruebas = false,
    this.onBack,
    this.onRefresh,
    this.onTrucos,
  });

  final String catadorNombre;
  final String rolLabel;
  final int mesaNumero;
  final int? tandaNumero;
  final int progresoPct;
  final int? puesto;
  final int? tabletNumero;
  final bool mostrarModoPruebas;
  final VoidCallback? onBack;
  final VoidCallback? onRefresh;
  final VoidCallback? onTrucos;

  static const double height = 46;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CataColors.cabecera,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StatusBarSpacer(color: CataColors.cabecera),
          SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
              Material(
                color: Colors.white.withValues(alpha: 0.15),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: onBack,
                  iconSize: TabletLayout.headerIconSize - 4,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Volver',
                  visualDensity: VisualDensity.compact,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Pill(text: catadorNombre.toUpperCase()),
                      _Pill(text: rolLabel.toUpperCase()),
                      _Pill(text: 'Mesa $mesaNumero'),
                      if (puesto != null) _Pill(text: 'Puesto $puesto'),
                      if (tabletNumero != null)
                        _Pill(text: 'Tablet $tabletNumero'),
                      if (tandaNumero != null)
                        _Pill(text: 'Tanda $tandaNumero'),
                      if (mostrarModoPruebas) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'MODO PRUEBAS',
                            style: VirtusTextStyles.plain(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (onTrucos != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: TextButton(
                              onPressed: onTrucos,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.25),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'TRUCOS',
                                style: VirtusTextStyles.plain(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 72,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (progresoPct / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        color: CataColors.progresoBarra,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$progresoPct%',
                      style: VirtusTextStyles.plain(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  onPressed: onRefresh,
                  iconSize: TabletLayout.headerIconSize - 4,
                  color: Colors.white,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Text(
          text,
          style: VirtusTextStyles.plain(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
