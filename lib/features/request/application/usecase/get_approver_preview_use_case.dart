import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/request/domain/entity/request_person.dart';
import 'package:flowboard/features/request/domain/repository/request_employee_directory.dart';

/// Tells who will receive a new request of the current employee: the direct manager, or null when
/// it goes to HR.
class GetApproverPreviewUseCase {
  /// Creates the use case.
  const GetApproverPreviewUseCase({required this.directory, required this.currentEmployeeProvider});

  final RequestEmployeeDirectory directory;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Direct manager of the current employee, or null.
  Future<RequestPerson?> execute() async {
    final RequestPerson me = await directory.getPerson(currentEmployeeProvider.currentEmployeeId().value);
    final int? managerId = me.directManagerId;
    return managerId == null ? null : directory.getPerson(managerId);
  }
}
