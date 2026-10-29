import 'package:flutter/material.dart';
import 'package:virtus2027/core/theme/virtus_colors.dart';
import 'package:virtus2027/core/theme/virtus_text_styles.dart';

/// Pantalla de espera del catador: sin acciones, solo mensaje y progreso.
class CatadorEsperaPanel extends StatefulWidget {
  const CatadorEsperaPanel({
    super.key,
    required this.catadas,
    required this.total,
  });

  final int catadas;
  final int total;

  @override
  State<CatadorEsperaPanel> createState() => _CatadorEsperaPanelState();
}

class _CatadorEsperaPanelState extends State<CatadorEsperaPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _escala = Tween<double>(begin: 0.92, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _escala,
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 72,
                  color: VirtusColors.secundario,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'ESPERANDO AL PRESIDENTE',
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: VirtusColors.oscuro,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Catadas ${widget.catadas} de ${widget.total}',
                textAlign: TextAlign.center,
                style: VirtusTextStyles.plain(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: VirtusColors.secundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
