import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';

/// Approves a request as the current employee.
class ApproveRequestUseCase {
  /// Creates the use case.
  const ApproveRequestUseCase({required this.repository, required this.currentEmployeeProvider});

  final RequestRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Approves [request].
  Future<Request> execute(Request request) {
    return repository.approve(request.id, currentEmployeeProvider.currentEmployeeId().value);
  }
}
