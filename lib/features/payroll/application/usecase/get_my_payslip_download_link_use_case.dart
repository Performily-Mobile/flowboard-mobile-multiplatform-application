import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_download_link.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';

/// Temporary link to download the PDF of a payslip of the employee using the app (MA-66).
///
/// The backend records each download for audit.
class GetMyPayslipDownloadLinkUseCase {
  /// Creates the use case.
  const GetMyPayslipDownloadLinkUseCase({required this.repository, required this.currentEmployeeProvider});

  final PayslipRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Link of the payslip [payslipId].
  Future<PayslipDownloadLink> execute(int payslipId) =>
      repository.getMyPayslipDownloadLink(currentEmployeeProvider.currentEmployeeId(), payslipId);
}
