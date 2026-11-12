import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_file_storage.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payroll_system_file.dart';

/// Replaces the file of a payslip that was already uploaded (MA-68, US44).
///
/// The payslip goes back to "Por publicar" so HR reviews the new file. A paid payslip cannot be
/// replaced. When the backend rejects the replacement, the stored copy is deleted.
class ReplacePayslipFileUseCase {
  /// Creates the use case.
  const ReplacePayslipFileUseCase({required this.storage, required this.repository});

  final PayslipFileStorage storage;
  final PayslipRepository repository;

  /// The updated payslip; throws [StateError] when [existing] is already paid.
  Future<Payslip> execute(Payslip existing, PayrollSystemFile file) async {
    if (!existing.canBeReplaced) {
      throw StateError('La boleta de ${existing.period.label} ya está pagada y no se puede reemplazar.');
    }
    final String storageUrl = await storage.store(file);
    try {
      return await repository.replaceFile(existing.id, file.toFileReference(storageUrl), file.issueDate, file.netAmount);
    } catch (_) {
      await storage.delete(storageUrl);
      rethrow;
    }
  }
}
