import 'package:virtus2027/core/models/categoria.dart';
import 'package:virtus2027/core/models/tanda.dart';
import 'package:virtus2027/core/services/supabase_service.dart';
import 'package:virtus2027/features/dashboard/domain/tablet_dashboard.dart';
import 'package:virtus2027/features/home/domain/dispositivo_home_item.dart';

class DashboardRepository {
  DashboardRepository({SupabaseService? service})
      : _service = service ?? SupabaseService();

  final SupabaseService _service;

  Future<TabletDashboard> fetchForDispositivo(DispositivoHomeItem dispositivo) {
    return _service.getDashboardForDispositivo(
      dispositivoId: dispositivo.id,
      catadorId: dispositivo.catadorId,
      mesaNumero: dispositivo.mesaNumero,
      catadorNombreFallback: dispositivo.catadorNombre,
    );
  }

  Future<Categoria?> getCategoriaById(String id) =>
      _service.getCategoriaById(id);

  Future<Tanda?> iniciarSiguienteTanda({
    required String mesaId,
    required String tandaActualId,
  }) {
    return _service.iniciarSiguienteTanda(
      mesaId: mesaId,
      tandaActualId: tandaActualId,
    );
  }

  Future<bool> haySiguienteTanda({
    required String mesaId,
    required String tandaActualId,
  }) {
    return _service.haySiguienteTanda(
      mesaId: mesaId,
      tandaActualId: tandaActualId,
    );
  }
}
