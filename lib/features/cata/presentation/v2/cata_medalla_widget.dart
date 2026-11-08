import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:virtus2027/features/cata/presentation/v2/cata_v2_theme.dart';

/// Medalla dibujada en Flutter (sin assets externos).
class CataMedallaWidget extends StatelessWidget {
  const CataMedallaWidget({
    super.key,
    required this.variante,
    this.size = CataV2Theme.tamanoMedalla,
    this.mostrarTexto = true,
  });

  final CataMedallaVisual variante;
  final double size;
  /// Si false, solo dibuja la medalla (p. ej. V4 controla el texto debajo).
  final bool mostrarTexto;

  @override
  Widget build(BuildContext context) {
    final label = switch (variante) {
      CataMedallaVisual.granOro => 'GRAN ORO',
      CataMedallaVisual.oro => 'ORO',
      CataMedallaVisual.plata => 'PLATA',
      CataMedallaVisual.ninguna => '',
    };
    final conPremio = variante != CataMedallaVisual.ninguna;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _MedallaPainter(variante: variante),
          ),
        ),
        if (mostrarTexto &&
            CataV2Theme.mostrarTextoMedalla &&
            label.isNotEmpty) ...[
          Transform.translate(
            offset: const Offset(0, -4),
            child: conPremio
                ? _TextoMedallaParpadeo(label: label)
                : Text(
                    label,
                    style: CataV2Theme.text(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: CataV2Theme.textoSecundario,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}

class _TextoMedallaParpadeo extends StatefulWidget {
  const _TextoMedallaParpadeo({required this.label});

  final String label;

  @override
  State<_TextoMedallaParpadeo> createState() => _TextoMedallaParpadeoState();
}

class _TextoMedallaParpadeoState extends State<_TextoMedallaParpadeo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: CataV2Theme.pulsoLento)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_c.value);
          return Opacity(
            opacity: 0.55 + 0.45 * t,
            child: child,
          );
        },
        child: Text(
          widget.label,
          style: CataV2Theme.text(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF5D4037),
            letterSpacing: 1.0,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _MedallaPainter extends CustomPainter {
  _MedallaPainter({required this.variante});

  final CataMedallaVisual variante;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;
    final r = size.width * 0.32;

    switch (variante) {
      case CataMedallaVisual.ninguna:
        _paintVacia(canvas, cx, cy, r);
      case CataMedallaVisual.plata:
        _paintCinta(canvas, size, cx, cy + r * 0.85, ancho: 0.28, metal: _plata);
        _paintDisco(canvas, cx, cy, r, metal: _plata, dobleAro: false);
      case CataMedallaVisual.oro:
        _paintCinta(canvas, size, cx, cy + r * 0.85, ancho: 0.30, metal: _oro);
        _paintDisco(canvas, cx, cy, r, metal: _oro, dobleAro: false);
        _paintEstrella(canvas, Offset(cx, cy), r * 0.38, _oroBrillo);
      case CataMedallaVisual.granOro:
        _paintCinta(
          canvas,
          size,
          cx,
          cy + r * 0.82,
          ancho: 0.42,
          metal: _oroBrillo,
        );
        _paintDisco(canvas, cx, cy, r, metal: _oroBrillo, dobleAro: true);
        _paintEstrella(canvas, Offset(cx, cy - r * 0.02), r * 0.34, Colors.white);
        _paintEstrella(
          canvas,
          Offset(cx - r * 0.42, cy + r * 0.18),
          r * 0.18,
          Colors.white.withValues(alpha: 0.95),
        );
        _paintEstrella(
          canvas,
          Offset(cx + r * 0.42, cy + r * 0.18),
          r * 0.18,
          Colors.white.withValues(alpha: 0.95),
        );
    }
  }

  static const _plata = Color(0xFF90A4AE);
  static const _plataClara = Color(0xFFCFD8DC);
  static const _oro = Color(0xFFF9A825);
  static const _oroBrillo = Color(0xFFFFD54F);
  static const _oroOscuro = Color(0xFFF57F17);

  void _paintVacia(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    _dashCircle(canvas, Offset(cx, cy), r, paint);
    final cinta = Path()
      ..moveTo(cx - r * 0.35, cy + r * 0.75)
      ..lineTo(cx - r * 0.55, cy + r * 1.55)
      ..lineTo(cx - r * 0.1, cy + r * 1.25)
      ..lineTo(cx + r * 0.1, cy + r * 1.25)
      ..lineTo(cx + r * 0.55, cy + r * 1.55)
      ..lineTo(cx + r * 0.35, cy + r * 0.75)
      ..close();
    canvas.drawPath(
      cinta,
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _paintCinta(
    Canvas canvas,
    Size size,
    double cx,
    double top, {
    required double ancho,
    required Color metal,
  }) {
    final w = size.width * ancho;
    final path = Path()
      ..moveTo(cx - w * 0.55, top)
      ..lineTo(cx - w * 0.85, top + size.height * 0.28)
      ..lineTo(cx - w * 0.15, top + size.height * 0.18)
      ..lineTo(cx + w * 0.15, top + size.height * 0.18)
      ..lineTo(cx + w * 0.85, top + size.height * 0.28)
      ..lineTo(cx + w * 0.55, top)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [metal, metal.withValues(alpha: 0.75)],
        ).createShader(path.getBounds()),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintDisco(
    Canvas canvas,
    double cx,
    double cy,
    double r, {
    required Color metal,
    required bool dobleAro,
  }) {
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(metal, Colors.white, 0.45)!,
            metal,
            Color.lerp(metal, Colors.black, 0.15)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Color.lerp(metal, Colors.black, 0.25)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = dobleAro ? 3.5 : 2.5,
    );
    if (dobleAro) {
      canvas.drawCircle(
        Offset(cx, cy),
        r * 0.82,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
      canvas.drawCircle(
        Offset(cx, cy),
        r * 0.68,
        Paint()
          ..color = _oroOscuro.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    } else if (metal == _plata) {
      canvas.drawCircle(
        Offset(cx, cy),
        r * 0.78,
        Paint()
          ..color = _plataClara.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _paintEstrella(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final b = a + math.pi / 5;
      final ox = c.dx + math.cos(a) * r;
      final oy = c.dy + math.sin(a) * r;
      final ix = c.dx + math.cos(b) * r * 0.4;
      final iy = c.dy + math.sin(b) * r * 0.4;
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _dashCircle(Canvas canvas, Offset c, double r, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;
    final circ = 2 * math.pi * r;
    var drawn = 0.0;
    while (drawn < circ) {
      final a0 = drawn / r;
      final a1 = math.min(drawn + dash, circ) / r;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        a0 - math.pi / 2,
        a1 - a0,
        false,
        paint,
      );
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _MedallaPainter oldDelegate) =>
      oldDelegate.variante != variante;
}
