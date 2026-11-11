import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';

/// Colors of the request screens, equal to the Android app.
class RequestColors {
  const RequestColors._();

  static const Color pending = AppColors.awaitingContainer;
  static const Color underReview = AppColors.surfaceContainerLow;
  static const Color approved = AppColors.activeContainer;
  static const Color rejected = Color(0xFFFFCBC5);
  static const Color cancelled = AppColors.surfaceContainerHigh;

  static const Color typeActive = AppColors.activeContainer;
  static const Color typeInactive = AppColors.surfaceContainerLow;

  static const Color okBanner = Color(0xFFE8F5E9);
  static const Color onOkBanner = Color(0xFF2E7D32);

  static const Color errorBanner = AppColors.errorContainer;
  static const Color onErrorBanner = AppColors.onErrorContainer;

  static const Color infoBanner = AppColors.secondaryContainer;
  static const Color onInfoBanner = AppColors.onSecondaryContainer;

  static const Color commentCard = AppColors.secondaryContainer;
  static const Color onCommentCard = AppColors.onSecondaryContainer;

  static const Color timelinePast = AppColors.outline;
  static const Color timelineCurrent = AppColors.primary;

  static const Color attachmentZone = AppColors.surfaceContainer;

  /// Color of the chip of [status].
  static Color status(RequestStatus status) => switch (status) {
        RequestStatus.inProgress => pending,
        RequestStatus.underReview => underReview,
        RequestStatus.approved => approved,
        RequestStatus.rejected => rejected,
        RequestStatus.cancelled => cancelled,
      };
}
