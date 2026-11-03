import 'app_restart_io.dart'
    if (dart.library.html) 'app_restart_web.dart' as impl;

/// Reinicia la app por completo (web: reload; resto: exit).
void restartAppCompletely() => impl.restartAppCompletely();
