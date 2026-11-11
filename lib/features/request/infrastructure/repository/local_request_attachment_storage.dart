import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flowboard/features/request/domain/repository/request_attachment_storage.dart';
import 'package:flowboard/features/request/domain/valueobject/attachment_upload.dart';

/// Temporary implementation of the attachment storage.
///
/// It copies the file to the private folder of the app and returns its local URI. When the real
/// storage is defined (for example Firebase Storage), another implementation of
/// [RequestAttachmentStorage] is registered in the request dependencies.
class LocalRequestAttachmentStorage implements RequestAttachmentStorage {
  /// Creates the storage.
  const LocalRequestAttachmentStorage();

  static const String _directory = 'request-attachments';

  @override
  Future<String> store(AttachmentUpload upload) async {
    final File source = File(upload.sourceUri);
    if (!await source.exists()) {
      throw StateError('No se pudo leer el archivo seleccionado.');
    }
    final Directory base = await getApplicationDocumentsDirectory();
    final Directory directory = Directory('${base.path}/$_directory');
    await directory.create(recursive: true);
    final String name = '${DateTime.now().millisecondsSinceEpoch}_${_sanitized(upload.fileName)}';
    final File target = await source.copy('${directory.path}/$name');
    return Uri.file(target.path).toString();
  }

  String _sanitized(String value) => value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}
