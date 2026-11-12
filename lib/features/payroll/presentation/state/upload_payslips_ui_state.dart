import 'package:flowboard/features/payroll/application/usecase/payslip_entry.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_area.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_period.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/presentation/state/payment_sheet_form.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_formatters.dart';

const Object _keep = Object();

/// File picked in the selector, before it is validated.
class SelectedPayslipFile {
  /// Creates the file.
  const SelectedPayslipFile({
    required this.path,
    required this.name,
    required this.contentType,
    required this.sizeInBytes,
  });

  final String path;
  final String name;
  final String contentType;
  final int sizeInBytes;
}

/// Progress of the upload: file [current] of [total].
class UploadProgress {
  /// Creates the progress.
  const UploadProgress({required this.current, required this.total});

  final int current;
  final int total;
}

/// Data of the "Ya existe una boleta" dialog (MA-68).
class DuplicatePrompt {
  /// Creates the prompt.
  const DuplicatePrompt({required this.employeeName, required this.periodLabel, required this.fileName});

  final String employeeName;
  final String periodLabel;
  final String fileName;
}

/// State of "Boletas y pagos" of HR (MA-67, MA-68, MA-69): the payslips of the period with their
/// payment status, the upload and publication of new payslips and the payment sheet.
class UploadPayslipsUiState {
  /// Creates the state.
  const UploadPayslipsUiState({
    this.isLoadingPeriods = false,
    this.periods = const <PayrollPeriod>[],
    this.selectedPeriod,
    this.isLoadingPayslips = false,
    this.entries = const <PayslipEntry>[],
    this.errorMessage,
    this.bannerMessage,
    this.upload,
    this.duplicate,
    this.isPublishing = false,
    this.snackbarMessage,
    this.query = '',
    this.areas = const <PayrollArea>[],
    this.selectedArea,
    this.selectedStatus,
    this.sheet,
  });

  final bool isLoadingPeriods;
  final List<PayrollPeriod> periods;
  final PayrollPeriod? selectedPeriod;
  final bool isLoadingPayslips;
  final List<PayslipEntry> entries;
  final String? errorMessage;

  /// Files that could not be uploaded, one per line.
  final String? bannerMessage;
  final UploadProgress? upload;
  final DuplicatePrompt? duplicate;
  final bool isPublishing;
  final String? snackbarMessage;

  /// Text of the search box: name or last name of the employee.
  final String query;

  /// Areas of the filter; it comes from Workspace.
  final List<PayrollArea> areas;
  final PayrollArea? selectedArea;

  /// Payment status of the filter; null shows every payslip.
  final PaymentStatus? selectedStatus;

  /// "Actualizar estado de pago" sheet, when it is open.
  final PaymentSheetForm? sheet;

  /// True when a search or a filter is applied.
  bool get hasFilters => query.trim().isNotEmpty || selectedArea != null || selectedStatus != null;

  /// Payslips of the period that match the search and the filters.
  ///
  /// A status filter only keeps published payslips, because the payment is not registered on a
  /// payslip still under review.
  List<PayslipEntry> get visibleEntries {
    final PayrollArea? area = selectedArea;
    final PaymentStatus? status = selectedStatus;
    return entries
        .where((PayslipEntry entry) => area == null || entry.employee?.areaId == area.id)
        .where((PayslipEntry entry) =>
            status == null || (entry.payslip.isPublished && entry.payslip.payment.status == status))
        .where((PayslipEntry entry) =>
            query.trim().isEmpty || PayrollFormatters.matches(<String>[entry.fullName, entry.listName], query))
        .toList();
  }

  /// True while files are being uploaded.
  bool get isUploading => upload != null;

  /// Payslips of the period still under review.
  int get underReviewCount => entries.where((PayslipEntry entry) => entry.payslip.isUnderReview).length;

  /// True when there is something to publish and nothing else running.
  bool get canPublish => selectedPeriod != null && underReviewCount > 0 && !isPublishing && !isUploading;

  /// True when HR can pick files.
  bool get canPickFiles =>
      selectedPeriod != null &&
      !isUploading &&
      !isPublishing &&
      !isLoadingPeriods &&
      !isLoadingPayslips &&
      errorMessage == null;

  /// Copy with the given values replaced.
  UploadPayslipsUiState copyWith({
    bool? isLoadingPeriods,
    List<PayrollPeriod>? periods,
    Object? selectedPeriod = _keep,
    bool? isLoadingPayslips,
    List<PayslipEntry>? entries,
    Object? errorMessage = _keep,
    Object? bannerMessage = _keep,
    Object? upload = _keep,
    Object? duplicate = _keep,
    bool? isPublishing,
    Object? snackbarMessage = _keep,
    String? query,
    List<PayrollArea>? areas,
    Object? selectedArea = _keep,
    Object? selectedStatus = _keep,
    Object? sheet = _keep,
  }) {
    return UploadPayslipsUiState(
      isLoadingPeriods: isLoadingPeriods ?? this.isLoadingPeriods,
      periods: periods ?? this.periods,
      selectedPeriod: identical(selectedPeriod, _keep) ? this.selectedPeriod : selectedPeriod as PayrollPeriod?,
      isLoadingPayslips: isLoadingPayslips ?? this.isLoadingPayslips,
      entries: entries ?? this.entries,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      bannerMessage: identical(bannerMessage, _keep) ? this.bannerMessage : bannerMessage as String?,
      upload: identical(upload, _keep) ? this.upload : upload as UploadProgress?,
      duplicate: identical(duplicate, _keep) ? this.duplicate : duplicate as DuplicatePrompt?,
      isPublishing: isPublishing ?? this.isPublishing,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
      query: query ?? this.query,
      areas: areas ?? this.areas,
      selectedArea: identical(selectedArea, _keep) ? this.selectedArea : selectedArea as PayrollArea?,
      selectedStatus: identical(selectedStatus, _keep) ? this.selectedStatus : selectedStatus as PaymentStatus?,
      sheet: identical(sheet, _keep) ? this.sheet : sheet as PaymentSheetForm?,
    );
  }
}
