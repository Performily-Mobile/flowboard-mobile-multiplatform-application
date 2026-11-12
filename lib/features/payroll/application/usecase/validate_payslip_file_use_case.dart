import 'package:flowboard/features/payroll/domain/valueobject/payroll_system_file.dart';

/// Validates a picked file (PDF only, up to 5 MB, name given by the payroll system) and reads its
/// data (MA-67).
class ValidatePayslipFileUseCase {
  /// Creates the use case.
  const ValidatePayslipFileUseCase();

  /// The payslip file; throws [ArgumentError] with a message for the user when it is not valid.
  PayrollSystemFile execute({
    required String sourcePath,
    required String fileName,
    required String contentType,
    required int sizeInBytes,
  }) {
    return PayrollSystemFile.from(
      sourcePath: sourcePath,
      fileName: fileName,
      contentType: contentType,
      sizeInBytes: sizeInBytes,
    );
  }
}
