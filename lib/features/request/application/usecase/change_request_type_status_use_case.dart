import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/repository/request_type_repository.dart';

/// Activates an inactive request type or deactivates an active one.
class ChangeRequestTypeStatusUseCase {
  /// Creates the use case.
  const ChangeRequestTypeStatusUseCase({required this.repository});

  final RequestTypeRepository repository;

  /// The type with its status switched.
  Future<RequestType> execute(RequestType type) {
    return type.active ? repository.deactivate(type.id) : repository.activate(type.id);
  }
}
