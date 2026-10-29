/// Spacing scale of the app.
///
/// Screens use [screenHorizontal] as side margin, [sectionGap] between blocks and [itemGap]
/// between the items of a list.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Left and right margin of every screen.
  static const double screenHorizontal = 20;

  /// Gap between independent blocks of a screen.
  static const double sectionGap = 24;

  /// Gap between the cards or rows of a list.
  static const double itemGap = 12;

  /// Bottom space of a list so its last item is not covered by a floating button.
  static const double fabClearance = 96;
}
