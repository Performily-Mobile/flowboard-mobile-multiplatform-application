import 'package:flutter/material.dart';

/// Text styles of the app. Styles not listed here keep the Material 3 defaults.
class AppTypography {
  const AppTypography._();

  static const TextTheme textTheme = TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 22, height: 28 / 22),
    titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, height: 24 / 18),
    bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, height: 22 / 16),
    bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, height: 20 / 14),
    bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 16 / 12),
    labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 20 / 14),
    labelMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, height: 16 / 12),
  );
}
