import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/repository/request_type_repository.dart';

/// Deletes a request type that nobody used.
class DeleteRequestTypeUseCase {
  /// Creates the use case.
  const DeleteRequestTypeUseCase({required this.repository});

  final RequestTypeRepository repository;

  /// Deletes [type].
  Future<void> execute(RequestType type) => repository.delete(type.id);
}
