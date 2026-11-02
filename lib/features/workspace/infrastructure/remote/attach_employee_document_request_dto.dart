/// Body to register a stored document in an employee record.
class AttachEmployeeDocumentRequestDto {
  /// Creates the DTO.
  const AttachEmployeeDocumentRequestDto({
    required this.documentType,
    required this.fileName,
    required this.contentType,
    required this.sizeInBytes,
    required this.storageUrl,
  });

  final String documentType;
  final String fileName;
  final String contentType;
  final int sizeInBytes;
  final String storageUrl;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'documentType': documentType,
        'fileName': fileName,
        'contentType': contentType,
        'sizeInBytes': sizeInBytes,
        'storageUrl': storageUrl,
      };
}
