import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';

/// Colors of the attendance screens, equal to the Android app.
class AttendanceColors {
  const AttendanceColors._();

  static const Color onTime = AppColors.activeContainer;
  static const Color late = AppColors.suspendedContainer;
  static const Color absent = AppColors.errorContainer;
  static const Color justified = AppColors.primaryContainer;
  static const Color incomplete = AppColors.surfaceContainerHigh;

  static const Color infoBanner = AppColors.secondaryContainer;
  static const Color onInfoBanner = AppColors.onSecondaryContainer;

  static const Color errorBanner = AppColors.errorContainer;
  static const Color onErrorBanner = AppColors.onErrorContainer;

  static const Color dayClosed = AppColors.activeContainer;

  /// Color of the chip of [status].
  static Color status(AttendanceStatus status) => switch (status) {
        AttendanceStatus.onTime => onTime,
        AttendanceStatus.late => late,
        AttendanceStatus.incomplete => incomplete,
        AttendanceStatus.absent => absent,
        AttendanceStatus.justified => justified,
      };
}
