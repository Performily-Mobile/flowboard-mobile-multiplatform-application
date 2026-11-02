import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';

/// Semantic color pairs used to tint the dashboard indicators.
///
/// [container] is the background of the icon chip and [content] the color of the icon on it.
/// The dark theme uses translucent containers so the chips do not glow over dark cards.
enum DashboardAccent {
  primary,
  amber,
  red,
  green;

  /// Background of the icon chip.
  Color container(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    return switch (this) {
      DashboardAccent.primary => dark ? AppColors.primaryContainerDark : AppColors.primaryContainer,
      DashboardAccent.amber => dark ? const Color(0x33F3C577) : AppColors.pendingContainer,
      DashboardAccent.red => dark ? const Color(0x33FFB4AB) : AppColors.errorContainer,
      DashboardAccent.green => dark ? const Color(0x33B9DBB1) : AppColors.activeContainer,
    };
  }

  /// Color of the icon and text drawn on the chip.
  Color content(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    return switch (this) {
      DashboardAccent.primary => dark ? AppColors.primaryDark : AppColors.onPrimaryContainer,
      DashboardAccent.amber => dark ? const Color(0xFFF3C577) : const Color(0xFF7A4B00),
      DashboardAccent.red => dark ? const Color(0xFFFFB4AB) : AppColors.onErrorContainer,
      DashboardAccent.green => dark ? const Color(0xFFB9DBB1) : const Color(0xFF1B4D1B),
    };
  }
}

/// Bar colors of the attendance rows, from healthy to worrying.
class DashboardColors {
  const DashboardColors._();

  static const Color _healthy = Color(0xFF2E7D32);
  static const Color _warning = Color(0xFFB26A00);

  /// Green from 85, amber from 60 and red below that.
  static Color attendanceBar(int percentage) {
    if (percentage >= 85) return _healthy;
    if (percentage >= 60) return _warning;
    return AppColors.error;
  }
}
