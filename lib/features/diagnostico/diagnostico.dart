import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:virtus2027/config/app_mode.dart';
import 'package:virtus2027/config/supabase_config.dart';
import 'package:virtus2027/config/supabase_environment.dart';

/// Medidor TEMPORAL de latencia (solo pruebas).
///
/// Para quitarlo antes del concurso:
/// 1. Pon [activo] a `false`, o
/// 2. Borra este archivo y los imports/`DiagnosticoBoton` / llamadas mínimas.
abstract final class Diagnostico {
  /// Interruptor único. `false` = no-op total (sin UI ni medidas).
  static const bool activo = true;

  static bool get visible => activo && esModoPruebas;

  static const int _maxMuestras = 20;
  static const Duration _ecoTimeout = Duration(seconds: 10);

  static final ValueNotifier<int> tick = ValueNotifier<int>(0);

  static String? _rol;
  static int? _tablet;
  static bool _hooksRealtime = false;
  static bool _huboCierre = false;

  static int desconexiones = 0;
  static int reconexiones = 0;
  static int sinEco = 0;

  static final List<_Muestra> _escrituras = <_Muestra>[];
  static final List<_Muestra> _vueltasRealtime = <_Muestra>[];
  static final List<_Muestra> _polls = <_Muestra>[];

  static final List<_PendienteEco> _pendientes = <_PendienteEco>[];

  static int? get ultimaVueltaMs {
    if (_vueltasRealtime.isEmpty) return null;
    return _vueltasRealtime.last.ms;
  }

  static void actualizarContexto({int? tablet, String? rol}) {
    if (!visible) return;
    if (tablet != null) _tablet = tablet;
    if (rol != null && rol.trim().isNotEmpty) _rol = rol.trim();
  }

  /// Engancha open/close del socket Realtime (sin tráfico extra).
  static void ensureHooks() {
    if (!visible || _hooksRealtime) return;
    _hooksRealtime = true;
    try {
      final rt = SupabaseConfig.client.realtime;
      rt.onClose((_) {
        desconexiones++;
        _huboCierre = true;
        _notify();
      });
      rt.onOpen(() {
        if (_huboCierre) {
          reconexiones++;
          _notify();
        }
      });
    } catch (_) {
      // Best-effort.
    }
  }

  /// Escritura HTTP de esta tablet + espera de eco Realtime (mismo reloj).
  static Future<T> escritura<T>({
    required String tipo,
    required String tabla,
    Map<String, dynamic>? match,
    required Future<T> Function() run,
  }) async {
    if (!visible) return run();

    ensureHooks();
    final sw = Stopwatch()..start();
    final pendiente = _PendienteEco(
      tipo: tipo,
      tabla: tabla,
      match: match ?? const {},
      sw: sw,
    );
    _pendientes.add(pendiente);

    try {
      final result = await run();
      sw.stop();
      _push(_escrituras, _Muestra(tipo: tipo, ms: sw.elapsedMilliseconds));
      sw.start(); // sigue para la vuelta Realtime
      _scheduleEcoTimeout(pendiente);
      _notify();
      return result;
    } catch (e) {
      _pendientes.remove(pendiente);
      rethrow;
    }
  }

  /// SELECT de un poll que ya existía.
  static Future<T> pollSelect<T>(
    String nombre,
    Future<T> Function() run,
  ) async {
    if (!visible) return run();
    final sw = Stopwatch()..start();
    try {
      return await run();
    } finally {
      sw.stop();
      _push(_polls, _Muestra(tipo: nombre, ms: sw.elapsedMilliseconds));
      _notify();
    }
  }

  /// Llamar desde callbacks Realtime existentes (pasivo).
  static void ecoPostgres(PostgresChangePayload payload) {
    if (!visible || _pendientes.isEmpty) return;
    final tabla = payload.table;
    final record = payload.newRecord;
    if (tabla.isEmpty) return;

    for (var i = 0; i < _pendientes.length; i++) {
      final p = _pendientes[i];
      if (p.resuelto) continue;
      if (p.tabla != tabla) continue;
      if (!_coincide(p.match, record)) continue;
      p.resuelto = true;
      p.sw.stop();
      _pendientes.removeAt(i);
      _push(
        _vueltasRealtime,
        _Muestra(tipo: p.tipo, ms: p.sw.elapsedMilliseconds),
      );
      _notify();
      return;
    }
  }

  static void borrar() {
    if (!visible) return;
    _escrituras.clear();
    _vueltasRealtime.clear();
    _polls.clear();
    sinEco = 0;
    // No reseteamos desconexiones/reconexiones de sesión a propósito:
    // el usuario puede querer verlas; "Borrar" limpia muestras de latencia.
    for (final p in _pendientes) {
      p.resuelto = true;
    }
    _pendientes.clear();
    _notify();
  }

  static String resumenTexto() {
    final buf = StringBuffer();
    buf.writeln('Virtus diagnóstico latencia');
    buf.writeln('Entorno: ${_entornoLabel()}');
    buf.writeln('Tablet: ${_tablet?.toString() ?? '-'}');
    buf.writeln('Rol: ${_rol ?? '-'}');
    buf.writeln('Desconexiones RT: $desconexiones');
    buf.writeln('Reconexiones RT: $reconexiones');
    buf.writeln('Sin eco: $sinEco');
    buf.writeln();
    buf.writeln(_bloqueTexto('Escritura', _escrituras));
    buf.writeln(_bloqueTexto('Vuelta Realtime', _vueltasRealtime));
    buf.writeln(_bloqueTexto('Poll SELECT', _polls));
    return buf.toString();
  }

  /// Solo bajo demanda (botón «Probar red»).
  static Future<({int min, int max, int media})?> probarRed() async {
    if (!visible) return null;
    final muestras = <int>[];
    for (var i = 0; i < 10; i++) {
      final sw = Stopwatch()..start();
      try {
        await SupabaseConfig.client.from('tandas').select('id').limit(1);
      } catch (_) {
        sw.stop();
        muestras.add(sw.elapsedMilliseconds);
        break;
      }
      sw.stop();
      muestras.add(sw.elapsedMilliseconds);
    }
    if (muestras.isEmpty) return null;
    final s = _Stats.from(muestras);
    return (min: s.min, max: s.max, media: s.media);
  }

  static void _scheduleEcoTimeout(_PendienteEco p) {
    Future<void>.delayed(_ecoTimeout, () {
      if (p.resuelto) return;
      p.resuelto = true;
      _pendientes.remove(p);
      sinEco++;
      _notify();
    });
  }

  static bool _coincide(Map<String, dynamic> match, Map<String, dynamic> row) {
    if (match.isEmpty) return true;
    for (final e in match.entries) {
      if (!_mismoId(row[e.key], e.value)) return false;
    }
    return true;
  }

  static bool _mismoId(dynamic a, dynamic b) {
    if (a == null || b == null) return false;
    final sa = a.toString().trim();
    final sb = b.toString().trim();
    if (sa.isEmpty || sb.isEmpty) return false;
    if (sa == sb) return true;
    final ia = int.tryParse(sa);
    final ib = int.tryParse(sb);
    return ia != null && ib != null && ia == ib;
  }

  static void _push(List<_Muestra> list, _Muestra m) {
    list.add(m);
    while (list.length > _maxMuestras) {
      list.removeAt(0);
    }
  }

  static void _notify() {
    tick.value = tick.value + 1;
  }

  static String _entornoLabel() {
    if (SupabaseConfig.pointsToCloud ||
        SupabaseEnvironment.active.value == SupabaseEntorno.cloud) {
      return 'NUBE';
    }
    return 'LOCAL';
  }

  static String _bloqueTexto(String titulo, List<_Muestra> list) {
    if (list.isEmpty) return '$titulo: (sin datos)';
    final byTipo = <String, List<int>>{};
    for (final m in list) {
      byTipo.putIfAbsent(m.tipo, () => <int>[]).add(m.ms);
    }
    final buf = StringBuffer('$titulo:');
    for (final e in byTipo.entries) {
      final s = _Stats.from(e.value);
      buf.writeln(
        '  ${e.key}: n=${e.value.length} último=${e.value.last} '
        'mín=${s.min} media=${s.media} máx=${s.max}',
      );
    }
    return buf.toString();
  }
}

class _Muestra {
  _Muestra({required this.tipo, required this.ms});
  final String tipo;
  final int ms;
}

class _PendienteEco {
  _PendienteEco({
    required this.tipo,
    required this.tabla,
    required this.match,
    required this.sw,
  });

  final String tipo;
  final String tabla;
  final Map<String, dynamic> match;
  final Stopwatch sw;
  bool resuelto = false;
}

class _Stats {
  _Stats({required this.min, required this.max, required this.media});

  final int min;
  final int max;
  final int media;

  factory _Stats.from(List<int> values) {
    var mn = values.first;
    var mx = values.first;
    var sum = 0;
    for (final v in values) {
      mn = math.min(mn, v);
      mx = math.max(mx, v);
      sum += v;
    }
    return _Stats(min: mn, max: mx, media: (sum / values.length).round());
  }
}

/// Botón compacto de la barra + panel.
class DiagnosticoBoton extends StatelessWidget {
  const DiagnosticoBoton({
    super.key,
    this.tabletNumero,
    this.rolLabel,
  });

  final int? tabletNumero;
  final String? rolLabel;

  @override
  Widget build(BuildContext context) {
    if (!Diagnostico.visible) return const SizedBox.shrink();
    Diagnostico.ensureHooks();
    Diagnostico.actualizarContexto(tablet: tabletNumero, rol: rolLabel);

    return ValueListenableBuilder<int>(
      valueListenable: Diagnostico.tick,
      builder: (context, _, __) {
        final ms = Diagnostico.ultimaVueltaMs;
        final label = ms == null ? '⏱' : '⏱ $ms ms';
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: TextButton(
            onPressed: () => _abrirPanel(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black.withValues(alpha: 0.22),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  void _abrirPanel(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => const _DiagnosticoPanel(),
    );
  }
}

class _DiagnosticoPanel extends StatefulWidget {
  const _DiagnosticoPanel();

  @override
  State<_DiagnosticoPanel> createState() => _DiagnosticoPanelState();
}

class _DiagnosticoPanelState extends State<_DiagnosticoPanel> {
  ({int min, int max, int media})? _pruebaRed;
  bool _probando = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Diagnostico.tick,
      builder: (context, _, __) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diagnóstico latencia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${Diagnostico._entornoLabel()} · '
                'Tablet ${Diagnostico._tablet ?? '-'} · '
                '${Diagnostico._rol ?? '-'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Desconexiones RT: ${Diagnostico.desconexiones} · '
                    'Reconexiones: ${Diagnostico.reconexiones} · '
                    'Sin eco: ${Diagnostico.sinEco}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _seccion('Escritura (HTTP)', Diagnostico._escrituras),
                  _seccion('Vuelta Realtime', Diagnostico._vueltasRealtime),
                  _seccion('Poll SELECT', Diagnostico._polls),
                  if (_pruebaRed != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Probar red (10×): mín=${_pruebaRed?.min} '
                      'media=${_pruebaRed?.media} máx=${_pruebaRed?.max} ms',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _probando
                  ? null
                  : () async {
                      setState(() => _probando = true);
                      final s = await Diagnostico.probarRed();
                      if (!mounted) return;
                      setState(() {
                        _pruebaRed = s;
                        _probando = false;
                      });
                    },
              child: Text(_probando ? 'Probando…' : 'Probar red'),
            ),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: Diagnostico.resumenTexto()),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resumen copiado')),
                );
              },
              child: const Text('Copiar resumen'),
            ),
            TextButton(
              onPressed: () {
                Diagnostico.borrar();
                setState(() => _pruebaRed = null);
              },
              child: const Text('Borrar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _seccion(String titulo, List<_Muestra> list) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          '$titulo: sin datos',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      );
    }
    final byTipo = <String, List<int>>{};
    for (final m in list) {
      byTipo.putIfAbsent(m.tipo, () => <int>[]).add(m.ms);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          ...byTipo.entries.map((e) {
            final s = _Stats.from(e.value);
            return Text(
              '  ${e.key}: último=${e.value.last} · mín=${s.min} · '
              'media=${s.media} · máx=${s.max} ms (n=${e.value.length})',
              style: const TextStyle(fontSize: 11, height: 1.35),
            );
          }),
        ],
      ),
    );
  }
}
