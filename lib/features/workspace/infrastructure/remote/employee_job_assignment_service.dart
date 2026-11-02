import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/assign_job_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/job_assignment_dto.dart';

/// Endpoints of the job history.
class EmployeeJobAssignmentService {
  /// Creates the service.
  const EmployeeJobAssignmentService({required this.client});

  final ApiClient client;

  /// GET employees/{employeeId}/job-assignments.
  Future<List<JobAssignmentDto>> getJobAssignments(int employeeId) async {
    final List<dynamic> json = await client.get('employees/$employeeId/job-assignments') as List<dynamic>;
    return json.map((dynamic item) => JobAssignmentDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// POST employees/{employeeId}/job-assignments.
  Future<JobAssignmentDto> assignJob(int employeeId, AssignJobRequestDto request) async {
    final dynamic json = await client.post('employees/$employeeId/job-assignments', body: request.toJson());
    return JobAssignmentDto.fromJson(json as Map<String, dynamic>);
  }
}
