import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_period.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_detail.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_download_link.dart';
import 'package:flowboard/features/payroll/domain/valueobject/pay_period.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_details.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/domain/valueobject/publication_status.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payroll_period_dto.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payslip_dto.dart';

/// Translates the Payroll DTOs to domain entities and builds the requests.
class PayrollMapper {
  const PayrollMapper._();

  static const String _defaultContentType = 'application/pdf';

  /// Domain payslip of [dto].
  ///
  /// The backend does not expose the location of the file, so the storage URL stays empty: the file
  /// is downloaded through a temporary link. Server data is rebuilt without the creation rules
  /// (future dates), because the clock of the phone may differ from the server.
  static Payslip toPayslip(PayslipDto dto) {
    return Payslip(
      id: dto.id,
      employeeId: EmployeeId(dto.employeeId),
      payrollPeriodId: dto.payrollPeriodId,
      period: PayPeriod(year: dto.periodYear, month: dto.periodMonth),
      file: FileReference(
        fileName: dto.fileName,
        contentType: dto.contentType ?? _defaultContentType,
        sizeInBytes: dto.sizeInBytes,
        storageUrl: '',
      ),
      issueDate: _requiredDate(dto.issueDate),
      netAmount: Money(amount: dto.netAmount, currency: dto.currency ?? Money.defaultCurrency),
      publicationStatus: publicationStatus(dto.publicationStatus),
      publishedAt: dto.publishedAt == null ? null : DateTime.tryParse(dto.publishedAt!),
      payment: _payment(dto),
      employeeName: _blankToNull(dto.employeeName),
    );
  }

  /// Domain payslip with the employer data.
  static PayslipDetail toDetail(PayslipDetailDto dto) {
    return PayslipDetail(
      payslip: toPayslip(dto.payslip),
      companyLegalName: _blankToNull(dto.companyLegalName),
      companyTaxId: _blankToNull(dto.companyTaxId),
    );
  }

  /// Domain download link.
  static PayslipDownloadLink toDownloadLink(PayslipDownloadUrlDto dto) {
    return PayslipDownloadLink(
      downloadUrl: dto.downloadUrl,
      fileName: dto.fileName ?? 'boleta.pdf',
      contentType: dto.contentType ?? _defaultContentType,
      expiresAt: dto.expiresAt == null ? null : DateTime.tryParse(dto.expiresAt!),
    );
  }

  /// Domain payroll period of [dto].
  static PayrollPeriod toPayrollPeriod(PayrollPeriodDto dto) {
    return PayrollPeriod(
      id: dto.id,
      period: PayPeriod(year: dto.year, month: dto.month),
      scheduledPaymentDate: _requiredDate(dto.scheduledPaymentDate),
    );
  }

  /// Body to upload ([employeeId] and [payrollPeriodId] given) or to replace the file of a payslip.
  static PayslipFileRequestDto toFileRequest(
    FileReference file,
    DateTime issueDate,
    Money netAmount, {
    EmployeeId? employeeId,
    int? payrollPeriodId,
  }) {
    return PayslipFileRequestDto(
      employeeId: employeeId?.value,
      payrollPeriodId: payrollPeriodId,
      fileName: file.fileName,
      contentType: file.contentType,
      sizeInBytes: file.sizeInBytes,
      storageUrl: file.storageUrl,
      issueDate: isoDate(issueDate),
      netAmount: netAmount.amount,
      currency: netAmount.currency,
    );
  }

  /// Publication status of [value]; unknown values are read as under review.
  static PublicationStatus publicationStatus(String value) =>
      value == 'PUBLISHED' ? PublicationStatus.published : PublicationStatus.underReview;

  /// Payment status of [value]; unknown values are read as pending.
  static PaymentStatus paymentStatus(String value) => switch (value) {
        'PAID' => PaymentStatus.paid,
        'OBSERVED' => PaymentStatus.observed,
        _ => PaymentStatus.pending,
      };

  /// ISO `yyyy-MM-dd` text of [date], as the API expects it.
  static String isoDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  static PaymentDetails _payment(PayslipDto dto) {
    final DateTime? paidOn = dto.paidOn == null ? null : _date(dto.paidOn!);
    final String? reason = _blankToNull(dto.observationReason);
    return switch (paymentStatus(dto.paymentStatus)) {
      PaymentStatus.paid when paidOn != null => PaymentDetails(status: PaymentStatus.paid, paidOn: paidOn),
      PaymentStatus.observed when reason != null => PaymentDetails.observed(reason),
      _ => PaymentDetails.pending(),
    };
  }

  static String? _blankToNull(String? value) => value == null || value.trim().isEmpty ? null : value.trim();

  static DateTime? _date(String value) {
    final DateTime? parsed = DateTime.tryParse(value);
    return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime _requiredDate(String value) {
    final DateTime? date = _date(value);
    if (date == null) throw FormatException('Fecha inválida: $value');
    return date;
  }
}
