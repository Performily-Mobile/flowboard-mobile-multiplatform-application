import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/domain/money.dart';

/// PDF payslip issued by the payroll system of the organization, before it is stored.
///
/// Flowboard does not calculate anything: the employee, the issue date and the net amount come in
/// the name of the file exported by the payroll system (translation of the ACL):
///
///     <employeeId>_<yyyy-MM-dd>_<netAmount>.pdf     for example: 12_2026-09-30_1420.00.pdf
class PayrollSystemFile {
  const PayrollSystemFile._({
    required this.sourcePath,
    required this.fileName,
    required this.contentType,
    required this.sizeInBytes,
    required this.employeeId,
    required this.issueDate,
    required this.netAmount,
  });

  /// Validates the picked file and reads its data.
  ///
  /// Throws [ArgumentError] with a message that is shown as it is to the user.
  factory PayrollSystemFile.from({
    required String sourcePath,
    required String fileName,
    required String contentType,
    required int sizeInBytes,
    DateTime? today,
  }) {
    if (sourcePath.trim().isEmpty) throw ArgumentError('Selecciona un archivo.');
    if (contentType != pdfContentType || !fileName.toLowerCase().endsWith('.pdf')) {
      throw ArgumentError('$fileName no es un formato permitido. Sube archivos PDF.');
    }
    if (sizeInBytes <= 0) throw ArgumentError('$fileName está vacío.');
    if (sizeInBytes > maxSizeInBytes) throw ArgumentError('$fileName supera los 5 MB.');

    final RegExpMatch? match = _namePattern.firstMatch(fileName);
    if (match == null) {
      throw ArgumentError('$fileName no sigue el formato del sistema de planilla ($nameFormat).');
    }
    final int? employeeNumber = int.tryParse(match.group(1)!);
    if (employeeNumber == null || employeeNumber <= 0) {
      throw ArgumentError('$fileName tiene un identificador de colaborador no válido.');
    }
    return PayrollSystemFile._(
      sourcePath: sourcePath,
      fileName: fileName,
      contentType: contentType,
      sizeInBytes: sizeInBytes,
      employeeId: EmployeeId(employeeNumber),
      issueDate: _issueDate(fileName, match.group(2)!, today ?? DateTime.now()),
      netAmount: Money(amount: double.parse(match.group(3)!)),
    );
  }

  /// Only content type accepted for a payslip.
  static const String pdfContentType = 'application/pdf';

  /// Largest file accepted: 5 MB.
  static const int maxSizeInBytes = 5 * 1024 * 1024;

  /// Name format shown to the user when a file does not follow it.
  static const String nameFormat = 'ID_AAAA-MM-DD_NETO.pdf';

  static final RegExp _namePattern =
      RegExp(r'^(\d+)_(\d{4}-\d{2}-\d{2})_(\d+(?:\.\d{1,2})?)\.pdf$', caseSensitive: false);

  /// Local path of the picked file.
  final String sourcePath;
  final String fileName;
  final String contentType;
  final int sizeInBytes;
  final EmployeeId employeeId;
  final DateTime issueDate;
  final Money netAmount;

  /// Reference to the file once it was stored at [storageUrl].
  FileReference toFileReference(String storageUrl) => FileReference(
        fileName: fileName,
        contentType: contentType,
        sizeInBytes: sizeInBytes,
        storageUrl: storageUrl,
      );

  static DateTime _issueDate(String fileName, String text, DateTime now) {
    final RegExpMatch match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text)!;
    final int year = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int day = int.parse(match.group(3)!);
    final DateTime date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      throw ArgumentError('$fileName tiene una fecha de emisión no válida.');
    }
    if (date.isAfter(DateTime(now.year, now.month, now.day))) {
      throw ArgumentError('$fileName tiene una fecha de emisión futura.');
    }
    return date;
  }
}
