import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/request/application/usecase/request_people_resolver.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';

/// Gets one page of the requests of the current employee, newest first.
class GetMyRequestsUseCase {
  /// Creates the use case.
  const GetMyRequestsUseCase({
    required this.repository,
    required this.currentEmployeeProvider,
    required this.peopleResolver,
  });

  final RequestRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;
  final RequestPeopleResolver peopleResolver;

  /// Page [page] of the requests with [status], or of every status when it is null.
  Future<RequestPage> execute({RequestStatus? status, int page = 0}) async {
    final RequestPage result = await repository.getRequestsOf(
      currentEmployeeProvider.currentEmployeeId().value,
      status: status,
      page: page,
    );
    return peopleResolver.resolvePage(result);
  }
}
