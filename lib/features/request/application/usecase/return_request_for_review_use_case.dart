import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';

/// Returns a request to its requester asking for changes.
class ReturnRequestForReviewUseCase {
  /// Creates the use case.
  const ReturnRequestForReviewUseCase({required this.repository, required this.currentEmployeeProvider});

  final RequestRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  static const int _maxComment = 500;

  /// Returns [request]; throws [ArgumentError] when the [comment] is blank or too long.
  Future<Request> execute(Request request, String comment) {
    final String cleanComment = comment.trim();
    if (cleanComment.isEmpty) throw ArgumentError('Ingresa un comentario para el colaborador.');
    if (cleanComment.length > _maxComment) throw ArgumentError('El comentario admite hasta $_maxComment caracteres.');
    return repository.returnForReview(request.id, currentEmployeeProvider.currentEmployeeId().value, cleanComment);
  }
}
