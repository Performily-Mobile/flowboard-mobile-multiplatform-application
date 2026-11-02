import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';

/// Document stored in the record of an employee.
class EmployeeDocument {
  /// Creates the document.
  const EmployeeDocument({
    required this.id,
    required this.documentType,
    required this.file,
    required this.uploadedAt,
  });

  final int id;
  final DocumentType documentType;
  final FileReference file;
  final DateTime uploadedAt;
}
