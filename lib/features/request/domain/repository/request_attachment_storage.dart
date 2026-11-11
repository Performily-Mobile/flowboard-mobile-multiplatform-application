import 'package:flowboard/features/request/domain/valueobject/attachment_upload.dart';

/// Storage port of the files attached to the requests.
///
/// It stores the chosen file and returns the URL where it was saved. The implementation is chosen
/// in infrastructure/di (local today, Firebase Storage later).
abstract class RequestAttachmentStorage {
  /// Stores [upload] and returns its URL.
  Future<String> store(AttachmentUpload upload);
}
