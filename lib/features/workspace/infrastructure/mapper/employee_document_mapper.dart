import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/iso_date_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/workspace_enum_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/attach_employee_document_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_document_dto.dart';

/// Translates the record documents between the API and the domain.
class EmployeeDocumentMapper {
  const EmployeeDocumentMapper._();

  /// Domain document of [dto].
  static EmployeeDocument toDomain(EmployeeDocumentDto dto) {
    return EmployeeDocument(
      id: dto.id,
      documentType: WorkspaceEnumMapper.fromApi(DocumentType.values, dto.documentType),
      file: FileReference(
        fileName: dto.fileName,
        contentType: dto.contentType,
        sizeInBytes: dto.sizeInBytes,
        storageUrl: dto.storageUrl,
      ),
      uploadedAt: IsoDateMapper.parseDateTime(dto.uploadedAt),
    );
  }

  /// Body to attach a stored [file] of type [documentType].
  static AttachEmployeeDocumentRequestDto toAttachRequest(DocumentType documentType, FileReference file) {
    return AttachEmployeeDocumentRequestDto(
      documentType: WorkspaceEnumMapper.toApi(documentType),
      fileName: file.fileName,
      contentType: file.contentType,
      sizeInBytes: file.sizeInBytes,
      storageUrl: file.storageUrl,
    );
  }
}
