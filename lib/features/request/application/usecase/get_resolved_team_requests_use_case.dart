import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/request/application/usecase/request_people_resolver.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';

/// Gets one page of the requests the current employee approved or rejected as direct manager.
class GetResolvedTeamRequestsUseCase {
  /// Creates the use case.
  const GetResolvedTeamRequestsUseCase({
    required this.repository,
    required this.currentEmployeeProvider,
    required this.peopleResolver,
  });

  final RequestRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;
  final RequestPeopleResolver peopleResolver;

  /// Page [page] of the resolved requests.
  Future<RequestPage> execute({int page = 0}) async {
    final RequestPage result = await repository.getAll(
      statuses: const <RequestStatus>[RequestStatus.approved, RequestStatus.rejected],
      approverId: currentEmployeeProvider.currentEmployeeId().value,
      page: page,
    );
    return peopleResolver.resolvePage(result);
  }
}
