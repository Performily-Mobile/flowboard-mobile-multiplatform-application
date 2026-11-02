import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flowboard/features/workspace/domain/repository/document_file_storage.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_upload.dart';

/// Temporary implementation of the document storage.
///
/// It copies the file to the private folder of the app and returns its local URI. When the real
/// storage is defined (for example Firebase Storage), another implementation of
/// [DocumentFileStorage] is created and registered in the workspace dependencies; nothing else of
/// the project changes.
class LocalDocumentFileStorage implements DocumentFileStorage {
  /// Creates the storage.
  const LocalDocumentFileStorage();

  static const String _directory = 'employee-documents';

  @override
  Future<String> store(DocumentUpload upload) async {
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
