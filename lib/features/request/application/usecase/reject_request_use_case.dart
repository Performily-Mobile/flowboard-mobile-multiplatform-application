import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';

/// Rejects a request as the current employee.
class RejectRequestUseCase {
  /// Creates the use case.
  const RejectRequestUseCase({required this.repository, required this.currentEmployeeProvider});

  final RequestRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  static const int _maxComment = 500;

  /// Rejects [request]; throws [ArgumentError] when the [reason] is blank or too long.
  Future<Request> execute(Request request, String reason) {
    final String cleanReason = reason.trim();
    if (cleanReason.isEmpty) throw ArgumentError('Ingresa el motivo para rechazar la solicitud.');
    if (cleanReason.length > _maxComment) throw ArgumentError('El motivo admite hasta $_maxComment caracteres.');
    return repository.reject(request.id, currentEmployeeProvider.currentEmployeeId().value, cleanReason);
  }
}
