import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/job_assignment.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';

/// Lists the job history of an employee, newest first.
class GetJobAssignmentsUseCase {
  /// Creates the use case.
  const GetJobAssignmentsUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Job assignments of [employeeId], newest first.
  Future<List<JobAssignment>> execute(EmployeeId employeeId) async {
    final List<JobAssignment> assignments = await repository.getJobAssignments(employeeId);
    return assignments..sort((JobAssignment a, JobAssignment b) => b.startDate.compareTo(a.startDate));
  }
}
