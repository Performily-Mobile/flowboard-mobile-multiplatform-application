import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/benefits/application/usecase/get_my_vacation_balance_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_vacation_balance_use_case.dart';
import 'package:flowboard/features/request/application/usecase/approve_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/cancel_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/change_request_type_status_use_case.dart';
import 'package:flowboard/features/request/application/usecase/create_request_type_use_case.dart';
import 'package:flowboard/features/request/application/usecase/delete_request_type_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_all_requests_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_approver_preview_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_my_requests_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_pending_approvals_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_request_types_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_resolved_team_requests_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_vacation_availability_use_case.dart';
import 'package:flowboard/features/request/application/usecase/reject_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/request_people_resolver.dart';
import 'package:flowboard/features/request/application/usecase/resubmit_request_use_case.dart';
import 'package:flowboard/features/request/application/usecase/return_request_for_review_use_case.dart';
import 'package:flowboard/features/request/application/usecase/store_attachment_use_case.dart';
import 'package:flowboard/features/request/application/usecase/submit_request_use_case.dart';
import 'package:flowboard/features/request/domain/repository/request_attachment_storage.dart';
import 'package:flowboard/features/request/domain/repository/request_employee_directory.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';
import 'package:flowboard/features/request/domain/repository/request_type_repository.dart';
import 'package:flowboard/features/request/domain/repository/vacation_balance_provider.dart';
import 'package:flowboard/features/request/infrastructure/acl/benefits_vacation_balance_adapter.dart';
import 'package:flowboard/features/request/infrastructure/acl/workspace_employee_directory_adapter.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_service.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_type_service.dart';
import 'package:flowboard/features/request/infrastructure/repository/local_request_attachment_storage.dart';
import 'package:flowboard/features/request/infrastructure/repository/request_repository_impl.dart';
import 'package:flowboard/features/request/infrastructure/repository/request_type_repository_impl.dart';
import 'package:flowboard/features/request/presentation/viewmodel/my_requests_view_model.dart';
import 'package:flowboard/features/request/presentation/viewmodel/new_request_type_view_model.dart';
import 'package:flowboard/features/request/presentation/viewmodel/new_request_view_model.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_detail_view_model.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_types_view_model.dart';
import 'package:flowboard/features/request/presentation/viewmodel/requests_view_model.dart';
import 'package:flowboard/features/request/presentation/viewmodel/resolved_requests_view_model.dart';
import 'package:flowboard/features/request/presentation/viewmodel/review_request_view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employee_by_id_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';

/// Registers the dependencies of the Request bounded context.
///
/// Services, repositories and use cases are singletons; view models are created for each screen.
/// The employee directory and the vacation balance read the Workspace and Benefits use cases, which
/// are resolved when they are first used. The attachment storage is temporary (local) until the real
/// storage is defined.
void setupRequestDependencies() {
  getIt
    ..registerLazySingleton<RequestService>(() => RequestService(client: getIt<ApiClient>()))
    ..registerLazySingleton<RequestTypeService>(() => RequestTypeService(client: getIt<ApiClient>()))
    ..registerLazySingleton<RequestRepository>(() => RequestRepositoryImpl(service: getIt<RequestService>()))
    ..registerLazySingleton<RequestTypeRepository>(
        () => RequestTypeRepositoryImpl(service: getIt<RequestTypeService>()))
    ..registerLazySingleton<RequestEmployeeDirectory>(() => WorkspaceEmployeeDirectoryAdapter(
          getEmployeeById: getIt<GetEmployeeByIdUseCase>(),
          getEmployees: getIt<GetEmployeesUseCase>(),
        ))
    ..registerLazySingleton<VacationBalanceProvider>(() => BenefitsVacationBalanceAdapter(
          getMyVacationBalance: getIt<GetMyVacationBalanceUseCase>(),
          getVacationBalance: getIt<GetVacationBalanceUseCase>(),
        ))
    ..registerLazySingleton<RequestAttachmentStorage>(() => const LocalRequestAttachmentStorage())
    ..registerLazySingleton<RequestPeopleResolver>(
        () => RequestPeopleResolver(directory: getIt<RequestEmployeeDirectory>()))
    ..registerLazySingleton<GetMyRequestsUseCase>(() => GetMyRequestsUseCase(
          repository: getIt<RequestRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
          peopleResolver: getIt<RequestPeopleResolver>(),
        ))
    ..registerLazySingleton<GetPendingApprovalsUseCase>(() => GetPendingApprovalsUseCase(
          repository: getIt<RequestRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
          peopleResolver: getIt<RequestPeopleResolver>(),
        ))
    ..registerLazySingleton<GetAllRequestsUseCase>(() => GetAllRequestsUseCase(
          repository: getIt<RequestRepository>(),
          peopleResolver: getIt<RequestPeopleResolver>(),
        ))
    ..registerLazySingleton<GetResolvedTeamRequestsUseCase>(() => GetResolvedTeamRequestsUseCase(
          repository: getIt<RequestRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
          peopleResolver: getIt<RequestPeopleResolver>(),
        ))
    ..registerLazySingleton<GetRequestUseCase>(() => GetRequestUseCase(
          repository: getIt<RequestRepository>(),
          peopleResolver: getIt<RequestPeopleResolver>(),
        ))
    ..registerLazySingleton<GetRequestTypesUseCase>(
        () => GetRequestTypesUseCase(repository: getIt<RequestTypeRepository>()))
    ..registerLazySingleton<GetVacationAvailabilityUseCase>(
        () => GetVacationAvailabilityUseCase(provider: getIt<VacationBalanceProvider>()))
    ..registerLazySingleton<GetApproverPreviewUseCase>(() => GetApproverPreviewUseCase(
          directory: getIt<RequestEmployeeDirectory>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<SubmitRequestUseCase>(() => SubmitRequestUseCase(
          repository: getIt<RequestRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<ResubmitRequestUseCase>(() => ResubmitRequestUseCase(
          repository: getIt<RequestRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<CancelRequestUseCase>(() => CancelRequestUseCase(
          repository: getIt<RequestRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<ApproveRequestUseCase>(() => ApproveRequestUseCase(
          repository: getIt<RequestRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<RejectRequestUseCase>(() => RejectRequestUseCase(
          repository: getIt<RequestRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<ReturnRequestForReviewUseCase>(() => ReturnRequestForReviewUseCase(
          repository: getIt<RequestRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<StoreAttachmentUseCase>(
        () => StoreAttachmentUseCase(storage: getIt<RequestAttachmentStorage>()))
    ..registerLazySingleton<CreateRequestTypeUseCase>(
        () => CreateRequestTypeUseCase(repository: getIt<RequestTypeRepository>()))
    ..registerLazySingleton<ChangeRequestTypeStatusUseCase>(
        () => ChangeRequestTypeStatusUseCase(repository: getIt<RequestTypeRepository>()))
    ..registerLazySingleton<DeleteRequestTypeUseCase>(
        () => DeleteRequestTypeUseCase(repository: getIt<RequestTypeRepository>()))
    ..registerFactory<RequestsViewModel>(() => RequestsViewModel(
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
          getMyRequests: getIt<GetMyRequestsUseCase>(),
          getPendingApprovals: getIt<GetPendingApprovalsUseCase>(),
          getAllRequests: getIt<GetAllRequestsUseCase>(),
          getRequestTypes: getIt<GetRequestTypesUseCase>(),
          approveRequest: getIt<ApproveRequestUseCase>(),
          rejectRequest: getIt<RejectRequestUseCase>(),
        ))
    ..registerFactory<MyRequestsViewModel>(() => MyRequestsViewModel(getMyRequests: getIt<GetMyRequestsUseCase>()))
    ..registerFactory<NewRequestViewModel>(() => NewRequestViewModel(
          getRequestTypes: getIt<GetRequestTypesUseCase>(),
          getVacationAvailability: getIt<GetVacationAvailabilityUseCase>(),
          getApproverPreview: getIt<GetApproverPreviewUseCase>(),
          storeAttachment: getIt<StoreAttachmentUseCase>(),
          submitRequest: getIt<SubmitRequestUseCase>(),
        ))
    ..registerFactory<RequestDetailViewModel>(() => RequestDetailViewModel(
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
          getRequest: getIt<GetRequestUseCase>(),
          getRequestTypes: getIt<GetRequestTypesUseCase>(),
          cancelRequest: getIt<CancelRequestUseCase>(),
          resubmitRequest: getIt<ResubmitRequestUseCase>(),
          storeAttachment: getIt<StoreAttachmentUseCase>(),
        ))
    ..registerFactory<ReviewRequestViewModel>(() => ReviewRequestViewModel(
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
          getRequest: getIt<GetRequestUseCase>(),
          getRequestTypes: getIt<GetRequestTypesUseCase>(),
          getVacationAvailability: getIt<GetVacationAvailabilityUseCase>(),
          approveRequest: getIt<ApproveRequestUseCase>(),
          rejectRequest: getIt<RejectRequestUseCase>(),
          returnRequestForReview: getIt<ReturnRequestForReviewUseCase>(),
        ))
    ..registerFactory<ResolvedRequestsViewModel>(() =>
        ResolvedRequestsViewModel(getResolvedTeamRequests: getIt<GetResolvedTeamRequestsUseCase>()))
    ..registerFactory<RequestTypesViewModel>(() => RequestTypesViewModel(
          getRequestTypes: getIt<GetRequestTypesUseCase>(),
          changeRequestTypeStatus: getIt<ChangeRequestTypeStatusUseCase>(),
          deleteRequestType: getIt<DeleteRequestTypeUseCase>(),
        ))
    ..registerFactory<NewRequestTypeViewModel>(
        () => NewRequestTypeViewModel(createRequestType: getIt<CreateRequestTypeUseCase>()));
}
