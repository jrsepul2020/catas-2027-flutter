import 'package:virtus2027/features/dashboard/domain/muestra_en_tanda.dart';
import 'package:virtus2027/features/dashboard/domain/tanda_info.dart';

class TabletDashboard {
  const TabletDashboard({
    required this.tabletNumero,
    required this.catadorNombre,
    this.tanda,
    this.muestras = const [],
  });

  final int tabletNumero;
  final String catadorNombre;
  final TandaInfo? tanda;
  final List<MuestraEnTanda> muestras;
}
