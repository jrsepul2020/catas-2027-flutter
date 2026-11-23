import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtus2027/features/cata/domain/ficha_definicion.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_form_v51.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/cata_form_v51_movil.dart';
import 'package:virtus2027/features/cata/presentation/v5_1/criterio_botones_v51.dart';

Widget _wrap(Size size, Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Scaffold(body: child),
    ),
  );
}

CataFormV51 _form() {
  final ficha = FichaDefinicion.vinosTranquilos();
  return CataFormV51(
    ficha: ficha,
    scores: const {},
    readOnly: false,
    onScoreChanged: (_, __) {},
    totalActual: 0,
    criteriosCompletos: 0,
    categoriaNombre: 'Vinos tintos',
    guardando: false,
    fichaCompleta: false,
    onEnviar: () {},
    onReiniciar: () {},
  );
}

void main() {
  testWidgets('390x844 usa disposición móvil', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_wrap(const Size(390, 844), _form()));
    await tester.pumpAndSettle();

    expect(find.byType(CataFormV51Movil), findsOneWidget);
    expect(find.byType(CriterioBotonesV51Movil), findsWidgets);
    expect(find.text('Reiniciar puntuación'), findsOneWidget);
    expect(find.textContaining('Falta'), findsOneWidget);
    expect(find.text('Provisional'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('1024x768 usa disposición tablet (no móvil)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_wrap(const Size(1024, 768), _form()));
    await tester.pumpAndSettle();

    expect(find.byType(CataFormV51Movil), findsNothing);
    expect(find.byType(CriterioBotonesV51), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
