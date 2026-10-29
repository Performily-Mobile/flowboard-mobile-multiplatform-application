import 'package:flutter/material.dart';

/// Corner radii shared by every component of the app.
///
/// [extraSmall] is for text fields and menus, [pill] is a full pill for chips, [medium] and
/// [large] are for cards and floating buttons, and [extraLarge] is for dialogs and sheets.
class AppShapes {
  const AppShapes._();

  static const double extraSmallRadius = 12;
  static const double mediumRadius = 20;
  static const double largeRadius = 20;
  static const double extraLargeRadius = 28;

  static const BorderRadius extraSmall = BorderRadius.all(Radius.circular(extraSmallRadius));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(mediumRadius));
  static const BorderRadius large = BorderRadius.all(Radius.circular(largeRadius));
  static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(extraLargeRadius));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
