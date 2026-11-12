import 'package:flowboard/features/payroll/application/usecase/payslip_upload_result.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_file_storage.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payroll_system_file.dart';

/// Uploads the payslip of an employee in a period (MA-67, US43).
///
/// Rule: one payslip per employee and period. If it already exists nothing is uploaded and
/// [PayslipDuplicate] is returned so HR decides whether to replace it (MA-68). When the backend
/// rejects the payslip, the stored copy of the file is deleted so no orphan file remains.
class UploadPayslipUseCase {
  /// Creates the use case.
  const UploadPayslipUseCase({required this.storage, required this.repository});

  final PayslipFileStorage storage;
  final PayslipRepository repository;

  /// Uploads [file] unless its employee already has a payslip among [payslipsInPeriod].
  Future<PayslipUploadResult> execute(
    int payrollPeriodId,
    PayrollSystemFile file,
    List<Payslip> payslipsInPeriod,
  ) async {
    for (final Payslip existing in payslipsInPeriod) {
      if (existing.employeeId == file.employeeId) return PayslipDuplicate(existing);
    }
    final String storageUrl = await storage.store(file);
    try {
      final Payslip payslip = await repository.uploadPayslip(
        file.employeeId,
        payrollPeriodId,
        file.toFileReference(storageUrl),
        file.issueDate,
        file.netAmount,
      );
      return PayslipUploaded(payslip);
    } catch (_) {
      await storage.delete(storageUrl);
      rethrow;
    }
  }
}
