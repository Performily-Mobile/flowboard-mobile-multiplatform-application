import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/request/application/usecase/submit_request_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';

/// Sends again a request that the approver returned for review.
class ResubmitRequestUseCase {
  /// Creates the use case.
  const ResubmitRequestUseCase({required this.repository, required this.currentEmployeeProvider});

  final RequestRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Resubmits [request] with its [attachments]; throws [ArgumentError] when it is not under review
  /// or breaks a rule of its [type].
  Future<Request> execute({
    required Request request,
    required RequestType? type,
    required List<FileReference> attachments,
    String? comment,
  }) {
    if (!request.isUnderReview) {
      throw ArgumentError('Solo se puede reenviar una solicitud devuelta a revisión.');
    }
    if (type != null) {
      final String? problem = SubmitRequestUseCase.validate(type, request.period, request.fieldValues, attachments);
      if (problem != null) throw ArgumentError(problem);
    }
    final String? cleanComment = comment?.trim();
    return repository.resubmit(
      requestId: request.id,
      actorId: currentEmployeeProvider.currentEmployeeId().value,
      fieldValues: request.fieldValues,
      attachments: attachments,
      comment: cleanComment == null || cleanComment.isEmpty ? null : cleanComment,
    );
  }
}
