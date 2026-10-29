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
}
