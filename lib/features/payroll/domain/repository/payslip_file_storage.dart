import 'package:flowboard/features/payroll/domain/valueobject/payroll_system_file.dart';

/// Port to store the PDF of a payslip.
///
/// It saves the picked file and returns the URL where it was left; the backend only registers its
/// metadata.
abstract class PayslipFileStorage {
  /// Saves the [file] and returns the URL where it was stored.
  Future<String> store(PayrollSystemFile file);

  /// Deletes a stored file that was never registered in the backend; it does not fail when the file
  /// does not exist.
  Future<void> delete(String storageUrl);
}
