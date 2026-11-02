import 'package:flowboard/features/workspace/domain/valueobject/document_upload.dart';

/// Storage port of the files of the employee record.
///
/// It stores the file chosen by the user and returns the URL where it was saved. The
/// implementation is chosen in infrastructure/di (local today, Firebase Storage later).
abstract class DocumentFileStorage {
  /// Stores [upload] and returns its URL.
  Future<String> store(DocumentUpload upload);
}
