import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/domain/valueobject/publication_status.dart';

/// Colors of the Payroll chips and banners (MA-64 to MA-69); they reuse the theme colors.
class PayrollColors {
  const PayrollColors._();

  /// "Pendiente" and "Por publicar".
  static const Color awaiting = AppColors.awaitingContainer;

  /// "Pagado" and "Publicada".
  static const Color done = AppColors.activeContainer;

  /// "Observado".
  static const Color observed = AppColors.errorContainer;

  /// Banner of the files that could not be uploaded (MA-67).
  static const Color errorBanner = AppColors.errorContainer;
  static const Color onErrorBanner = AppColors.onErrorContainer;

  /// Circle of the lock of MA-64.
  static const Color lockContainer = AppColors.primaryContainer;

  /// "Vista previa del PDF" placeholder of MA-66.
  static const Color pdfPreview = Color(0xFFDDE3EC);

  /// Chip color of a payment [status].
  static Color payment(PaymentStatus status) => switch (status) {
        PaymentStatus.pending => awaiting,
        PaymentStatus.paid => done,
        PaymentStatus.observed => observed,
      };

  /// Chip color of a publication [status].
  static Color publication(PublicationStatus status) => switch (status) {
        PublicationStatus.underReview => awaiting,
        PublicationStatus.published => done,
      };
}
