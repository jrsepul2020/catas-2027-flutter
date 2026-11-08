/// Metadatos de build visibles en la UI.
///
/// Antes de cada APK (o para identificar un build en tablet):
/// `dart run tool/stamp_build.dart`
/// (sube el nº de build y sella fecha/hora Europe/Madrid).
abstract final class AppBuildInfo {
  static const version = '1.0.1';
  static const build = 5;

  /// Fecha/hora del build (Europe/Madrid), sellada por tool/stamp_build.dart.
  static const builtAt = '08/11/2026 17:33';

  /// Texto discreto: versión, build, fecha y hora.
  static String get label => 'v$version+$build · $builtAt';
}
