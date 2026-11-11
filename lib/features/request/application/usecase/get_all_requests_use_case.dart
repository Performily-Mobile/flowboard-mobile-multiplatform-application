import 'package:flowboard/features/request/application/usecase/request_people_resolver.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';

/// Gets one page of the requests of every employee, newest first, for the HR staff.
class GetAllRequestsUseCase {
  /// Creates the use case.
  const GetAllRequestsUseCase({required this.repository, required this.peopleResolver});

  final RequestRepository repository;
  final RequestPeopleResolver peopleResolver;

  /// Page [page] of the requests with [status], or of every status when it is null.
  Future<RequestPage> execute({RequestStatus? status, int page = 0}) async {
    final RequestPage result = await repository.getAll(
      statuses: <RequestStatus>[?status],
      page: page,
    );
    return peopleResolver.resolvePage(result);
  }
}
