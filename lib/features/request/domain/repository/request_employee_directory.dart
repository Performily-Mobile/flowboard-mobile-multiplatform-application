import 'package:flowboard/features/request/domain/entity/request_person.dart';

/// Port to read employees from Workspace, used to name requesters and approvers.
abstract class RequestEmployeeDirectory {
  /// Employee [employeeId].
  Future<RequestPerson> getPerson(int employeeId);

  /// Every employee of the organization.
  Future<List<RequestPerson>> getPeople();
}
