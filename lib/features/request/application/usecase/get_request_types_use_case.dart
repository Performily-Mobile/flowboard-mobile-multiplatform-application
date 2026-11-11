import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/repository/request_type_repository.dart';

/// Lists the request types, the active ones first.
class GetRequestTypesUseCase {
  /// Creates the use case.
  const GetRequestTypesUseCase({required this.repository});

  final RequestTypeRepository repository;

  /// Request types; only the active ones when [activeOnly] is true.
  Future<List<RequestType>> execute({bool activeOnly = false}) async {
    final List<RequestType> types = await repository.getRequestTypes(activeOnly: activeOnly);
    return <RequestType>[...types]..sort((RequestType a, RequestType b) {
        if (a.active != b.active) return a.active ? -1 : 1;
        return a.id.compareTo(b.id);
      });
  }
}
