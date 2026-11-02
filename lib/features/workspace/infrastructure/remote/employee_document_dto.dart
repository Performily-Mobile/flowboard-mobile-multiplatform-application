/// Document of an employee record as returned by the API.
class EmployeeDocumentDto {
  /// Creates the DTO.
  const EmployeeDocumentDto({
    required this.id,
    required this.documentType,
    required this.fileName,
    required this.contentType,
    required this.sizeInBytes,
    required this.storageUrl,
    required this.uploadedAt,
  });

  /// Reads the DTO from its JSON.
  factory EmployeeDocumentDto.fromJson(Map<String, dynamic> json) {
    return EmployeeDocumentDto(
      id: (json['id'] as num).toInt(),
      documentType: json['documentType'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      sizeInBytes: (json['sizeInBytes'] as num).toInt(),
      storageUrl: json['storageUrl'] as String,
      uploadedAt: json['uploadedAt'] as String,
    );
  }

  final int id;
  final String documentType;
  final String fileName;
  final String contentType;
  final int sizeInBytes;
  final String storageUrl;
  final String uploadedAt;
}
