import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/domain/repository/request_attachment_storage.dart';
import 'package:flowboard/features/request/domain/valueobject/attachment_upload.dart';

/// Stores a file chosen to support a request.
class StoreAttachmentUseCase {
  /// Creates the use case.
  const StoreAttachmentUseCase({required this.storage});

  final RequestAttachmentStorage storage;

  /// Stores the file and returns its reference; throws [ArgumentError] when the file is not valid.
  Future<FileReference> execute({
    required String sourceUri,
    required String fileName,
    required String contentType,
    required int sizeInBytes,
  }) async {
    final AttachmentUpload upload = AttachmentUpload(
      sourceUri: sourceUri,
      fileName: fileName,
      contentType: contentType,
      sizeInBytes: sizeInBytes,
    );
    final String url = await storage.store(upload);
    return FileReference(
      fileName: upload.fileName,
      contentType: upload.contentType,
      sizeInBytes: upload.sizeInBytes,
      storageUrl: url,
    );
  }
}
