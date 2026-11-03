// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// Reinicio completo en web: recarga la página.
void restartAppCompletely() {
  html.window.location.reload();
}
