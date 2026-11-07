import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';

/// Colors of the chips and banners of Benefits; they reuse the theme colors when they exist.
class BenefitsColors {
  const BenefitsColors._();

  static const Color assigned = AppColors.secondaryContainer;
  static const Color delivered = AppColors.activeContainer;
  static const Color cancelled = AppColors.surfaceContainerHigh;
  static const Color active = AppColors.activeContainer;
  static const Color inactive = AppColors.surfaceContainerHigh;

  static const Color offlineBanner = AppColors.surfaceContainer;
  static const Color onOfflineBanner = AppColors.onSurfaceVariant;
  static const Color warningBanner = Color(0xFFFFF3E0);
  static const Color onWarningBanner = Color(0xFF5C2400);

  /// Chip color of an assignment [status].
  static Color status(AssignmentStatus status) => switch (status) {
        AssignmentStatus.assigned => assigned,
        AssignmentStatus.delivered => delivered,
        AssignmentStatus.cancelled => cancelled,
      };
}
