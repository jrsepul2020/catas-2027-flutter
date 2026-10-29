import 'package:virtus2027/core/models/catador.dart';
import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/models/concurso.dart';
import 'package:virtus2027/core/models/dispositivo.dart';
import 'package:virtus2027/core/models/mesa.dart';
import 'package:virtus2027/core/models/tanda.dart';
import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';

class TabletDashboard {
  const TabletDashboard({
    required this.dispositivoNumero,
    required this.catadorNombre,
    this.concurso,
    this.concursoLogoUrl,
    this.concursoColorPrimario,
    this.dispositivo,
    this.mesa,
    this.catador,
    this.tanda,
    this.tandaNumero,
    this.categoria,
    this.muestras = const [],
  });

  final int dispositivoNumero;
  final String catadorNombre;
  final Concurso? concurso;
  final String? concursoLogoUrl;
  final String? concursoColorPrimario;
  final Dispositivo? dispositivo;
  final Mesa? mesa;
  final Catador? catador;
  final Tanda? tanda;
  final int? tandaNumero;
  final Categoria? categoria;
  final List<MuestraEnTanda> muestras;

  int get mesaNumero => mesa?.numero ?? dispositivoNumero;

  String get mesaTitulo => 'Mesa $mesaNumero · $catadorNombre';

  bool get esPresidente =>
      catador?.rol?.toLowerCase() == 'presidente';
}
