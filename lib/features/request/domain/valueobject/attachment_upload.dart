/// File chosen to support a request, before it is stored.
///
/// [sourceUri] is the local reference of the file (its path on the device).
class AttachmentUpload {
  /// Creates the upload; throws [ArgumentError] when the file is missing, empty, of a type that
  /// is not allowed or larger than 5 MB.
  AttachmentUpload({
    required this.sourceUri,
    required this.fileName,
    required this.contentType,
    required this.sizeInBytes,
  }) {
    if (sourceUri.trim().isEmpty) throw ArgumentError('Selecciona un archivo.');
    if (fileName.trim().isEmpty) throw ArgumentError('El archivo debe tener nombre.');
    if (!allowedContentTypes.contains(contentType)) {
      throw ArgumentError('Solo se aceptan archivos PDF, JPG o PNG.');
    }
    if (sizeInBytes <= 0) throw ArgumentError('El archivo está vacío.');
    if (sizeInBytes > maxSizeInBytes) throw ArgumentError('El archivo supera los 5 MB.');
  }

  /// Largest file accepted, in bytes.
  static const int maxSizeInBytes = 5 * 1024 * 1024;

  /// MIME types accepted.
  static const Set<String> allowedContentTypes = <String>{'application/pdf', 'image/jpeg', 'image/png'};

  final String sourceUri;
  final String fileName;
  final String contentType;
  final int sizeInBytes;
}
