import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';

/// Cancels a request of the current employee.
class CancelRequestUseCase {
  /// Creates the use case.
  const CancelRequestUseCase({required this.repository, required this.currentEmployeeProvider});

  final RequestRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Cancels [request]; throws [ArgumentError] when it was already resolved.
  Future<Request> execute(Request request) {
    if (request.isResolved) {
      throw ArgumentError('La solicitud ya fue resuelta y no se puede cancelar.');
    }
    return repository.cancel(request.id, currentEmployeeProvider.currentEmployeeId().value);
  }
}
