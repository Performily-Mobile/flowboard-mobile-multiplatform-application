import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';

/// Lists the documents of an employee record, newest first.
class GetEmployeeDocumentsUseCase {
  /// Creates the use case.
  const GetEmployeeDocumentsUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Documents of [employeeId], newest first.
  Future<List<EmployeeDocument>> execute(EmployeeId employeeId) async {
    final List<EmployeeDocument> documents = await repository.getDocuments(employeeId);
    return documents..sort((EmployeeDocument a, EmployeeDocument b) => b.uploadedAt.compareTo(a.uploadedAt));
  }
}
