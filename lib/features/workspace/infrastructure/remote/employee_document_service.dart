import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/attach_employee_document_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_document_dto.dart';

/// Endpoints of the employee record documents.
class EmployeeDocumentService {
  /// Creates the service.
  const EmployeeDocumentService({required this.client});

  final ApiClient client;

  /// GET employees/{employeeId}/documents.
  Future<List<EmployeeDocumentDto>> getDocuments(int employeeId) async {
    final List<dynamic> json = await client.get('employees/$employeeId/documents') as List<dynamic>;
    return json.map((dynamic item) => EmployeeDocumentDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// POST employees/{employeeId}/documents.
  Future<EmployeeDocumentDto> attachDocument(int employeeId, AttachEmployeeDocumentRequestDto request) async {
    final dynamic json = await client.post('employees/$employeeId/documents', body: request.toJson());
    return EmployeeDocumentDto.fromJson(json as Map<String, dynamic>);
  }
}
