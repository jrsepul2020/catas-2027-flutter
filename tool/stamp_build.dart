// Actualiza versión visible y sello horario (Europe/Madrid).
// Uso: dart run tool/stamp_build.dart
//
// Antes de generar APK o tras cambios relevantes para identificar el build en tablet.

import 'dart:io';

void main(List<String> args) {
  final infoFile = File('lib/config/app_build_info.dart');
  final pubspec = File('pubspec.yaml');
  if (!infoFile.existsSync() || !pubspec.existsSync()) {
    stderr.writeln('Ejecutar desde la raíz del proyecto.');
    exit(1);
  }

  var info = infoFile.readAsStringSync();
  final buildMatch = RegExp(r"static const build = (\d+);").firstMatch(info);
  final versionMatch =
      RegExp(r"static const version = '([^']+)';").firstMatch(info);
  if (buildMatch == null || versionMatch == null) {
    stderr.writeln('No se pudo leer version/build en app_build_info.dart');
    exit(1);
  }

  final version = versionMatch.group(1)!;
  final nextBuild = int.parse(buildMatch.group(1)!) + 1;
  final builtAt = _horaEspana();

  info = info.replaceFirst(
    RegExp(r"static const build = \d+;"),
    'static const build = $nextBuild;',
  );
  info = info.replaceFirst(
    RegExp(r"static const builtAt = '[^']*';"),
    "static const builtAt = '$builtAt';",
  );
  infoFile.writeAsStringSync(info);

  var yaml = pubspec.readAsStringSync();
  yaml = yaml.replaceFirst(
    RegExp(r'^version:\s*.+$', multiLine: true),
    'version: $version+$nextBuild',
  );
  pubspec.writeAsStringSync(yaml);

  stdout.writeln('OK → v$version+$nextBuild · $builtAt (Europe/Madrid)');
}

String _horaEspana() {
  try {
    final r = Process.runSync(
      'date',
      ['+%d/%m/%Y %H:%M'],
      environment: {...Platform.environment, 'TZ': 'Europe/Madrid'},
    );
    if (r.exitCode == 0) {
      final out = (r.stdout as String).trim();
      if (out.isNotEmpty) return out;
    }
  } catch (_) {}
  // Fallback: hora local de la máquina que ejecuta el stamp.
  final n = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(n.day)}/${two(n.month)}/${n.year} ${two(n.hour)}:${two(n.minute)}';
}
