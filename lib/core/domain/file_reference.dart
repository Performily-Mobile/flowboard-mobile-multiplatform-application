/// Reference to a stored file.
class FileReference {
  /// Creates the reference; throws [ArgumentError] when the name is blank or the file is empty.
  FileReference({
    required this.fileName,
    required this.contentType,
    required this.sizeInBytes,
    required this.storageUrl,
  }) {
    if (fileName.trim().isEmpty) {
      throw ArgumentError('El archivo debe tener nombre.');
    }
    if (sizeInBytes <= 0) {
      throw ArgumentError('El archivo está vacío.');
    }
  }

  final String fileName;
  final String contentType;
  final int sizeInBytes;
  final String storageUrl;
}
