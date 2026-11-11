import 'package:flowboard/features/request/application/usecase/request_people_resolver.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';

/// Gets one request with the names of its people.
class GetRequestUseCase {
  /// Creates the use case.
  const GetRequestUseCase({required this.repository, required this.peopleResolver});

  final RequestRepository repository;
  final RequestPeopleResolver peopleResolver;

  /// Request [requestId].
  Future<Request> execute(int requestId) async {
    return peopleResolver.resolve(await repository.getRequest(requestId));
  }
}
