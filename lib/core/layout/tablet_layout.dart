import 'package:flutter/material.dart';

/// Canvas de diseño para tablet Virtus (resolución objetivo 1003×627).
abstract final class TabletLayout {
  static const double width = 1003;
  static const double height = 627;
  static const Size size = Size(width, height);

  static const double headerHeight = 52;
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(12, 8, 12, 10);

  static const int gridColumns = 5;
  static const int gridRows = 5;
  static const double gridSpacing = 8;
  static const double slotRadius = 10;

  static const double titleFontSize = 22;
  static const double slotNumberFontSize = 15;
  static const double slotNameFontSize = 17;
  static const double errorTitleFontSize = 20;
  static const double errorBodyFontSize = 14;
  static const double iconSize = 26;
  static const double headerIconSize = 28;

  static double get contentWidth =>
      width - screenPadding.left - screenPadding.right;

  static double get contentHeight =>
      height - headerHeight - screenPadding.top - screenPadding.bottom;
}
