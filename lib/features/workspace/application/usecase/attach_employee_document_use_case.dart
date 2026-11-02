import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/repository/document_file_storage.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_upload.dart';

/// Uploads a file to the storage and registers its metadata in the employee record.
class AttachEmployeeDocumentUseCase {
  /// Creates the use case.
  const AttachEmployeeDocumentUseCase({required this.storage, required this.repository});

  final DocumentFileStorage storage;
  final EmployeeRepository repository;

  /// Stores [upload] and attaches it as a [documentType] to the record of [employeeId].
  Future<EmployeeDocument> execute(EmployeeId employeeId, DocumentType documentType, DocumentUpload upload) async {
    final String storageUrl = await storage.store(upload);
    final FileReference file = FileReference(
      fileName: upload.fileName,
      contentType: upload.contentType,
      sizeInBytes: upload.sizeInBytes,
      storageUrl: storageUrl,
    );
    return repository.attachDocument(employeeId, documentType, file);
  }
}
