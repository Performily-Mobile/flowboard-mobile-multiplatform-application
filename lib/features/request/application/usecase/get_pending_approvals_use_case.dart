import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/core/session/user_role.dart';
import 'package:flowboard/features/request/application/usecase/request_people_resolver.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';
import 'package:flowboard/features/request/domain/valueobject/request_sort_order.dart';

/// Gets one page of the pending requests the current employee has to resolve: as direct manager,
/// or the HR inbox when the role is HR.
class GetPendingApprovalsUseCase {
  /// Creates the use case.
  const GetPendingApprovalsUseCase({
    required this.repository,
    required this.currentEmployeeProvider,
    required this.peopleResolver,
  });

  final RequestRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;
  final RequestPeopleResolver peopleResolver;

  /// Page [page] of the pending requests, optionally of one request type.
  Future<RequestPage> execute({
    int? requestTypeId,
    RequestSortOrder sort = RequestSortOrder.oldestFirst,
    int page = 0,
  }) async {
    final RequestPage result = switch (currentEmployeeProvider.currentRole()) {
      UserRole.humanResources =>
        await repository.getPendingForHrStaff(requestTypeId: requestTypeId, sort: sort, page: page),
      UserRole.employee => await repository.getPendingForApprover(
          currentEmployeeProvider.currentEmployeeId().value,
          requestTypeId: requestTypeId,
          sort: sort,
          page: page,
        ),
    };
    return peopleResolver.resolvePage(result);
  }
}
