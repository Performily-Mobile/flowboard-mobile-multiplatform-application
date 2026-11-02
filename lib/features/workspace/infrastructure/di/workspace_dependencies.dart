import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/feature_route_registry.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/workspace/application/usecase/assign_direct_manager_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/assign_job_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/attach_employee_document_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/create_area_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/create_position_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/deactivate_area_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_current_employee_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employee_by_id_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employee_documents_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_job_assignments_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_organization_chart_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_positions_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_subordinates_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/register_employee_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/reinstate_employee_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/remove_direct_manager_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/terminate_employee_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/update_employee_personal_data_use_case.dart';
import 'package:flowboard/features/workspace/domain/repository/area_repository.dart';
import 'package:flowboard/features/workspace/domain/repository/document_file_storage.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';
import 'package:flowboard/features/workspace/domain/repository/position_repository.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/area_service.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_document_service.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_job_assignment_service.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_service.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/position_service.dart';
import 'package:flowboard/features/workspace/infrastructure/repository/area_repository_impl.dart';
import 'package:flowboard/features/workspace/infrastructure/repository/employee_repository_impl.dart';
import 'package:flowboard/features/workspace/infrastructure/repository/local_document_file_storage.dart';
import 'package:flowboard/features/workspace/infrastructure/repository/position_repository_impl.dart';
import 'package:flowboard/features/workspace/presentation/ui/navigation/workspace_navigation.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/edit_personal_data_view_model.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/employee_detail_view_model.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/employees_view_model.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/my_profile_view_model.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/my_record_view_model.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/organization_chart_view_model.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/organization_view_model.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/register_employee_view_model.dart';

/// Registers the dependencies of the Workspace bounded context and its routes.
///
/// Services, repositories and use cases are singletons; view models are created for each screen.
/// The document storage is temporary (local) until the real storage is defined.
void setupWorkspaceDependencies() {
  getIt
    ..registerLazySingleton<EmployeeService>(() => EmployeeService(client: getIt<ApiClient>()))
    ..registerLazySingleton<EmployeeJobAssignmentService>(
        () => EmployeeJobAssignmentService(client: getIt<ApiClient>()))
    ..registerLazySingleton<EmployeeDocumentService>(() => EmployeeDocumentService(client: getIt<ApiClient>()))
    ..registerLazySingleton<AreaService>(() => AreaService(client: getIt<ApiClient>()))
    ..registerLazySingleton<PositionService>(() => PositionService(client: getIt<ApiClient>()))
    ..registerLazySingleton<EmployeeRepository>(() => EmployeeRepositoryImpl(
          employeeService: getIt<EmployeeService>(),
          jobAssignmentService: getIt<EmployeeJobAssignmentService>(),
          documentService: getIt<EmployeeDocumentService>(),
        ))
    ..registerLazySingleton<AreaRepository>(() => AreaRepositoryImpl(service: getIt<AreaService>()))
    ..registerLazySingleton<PositionRepository>(() => PositionRepositoryImpl(service: getIt<PositionService>()))
    ..registerLazySingleton<DocumentFileStorage>(() => const LocalDocumentFileStorage())
    ..registerLazySingleton<AssignDirectManagerUseCase>(
        () => AssignDirectManagerUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<AssignJobUseCase>(() => AssignJobUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<AttachEmployeeDocumentUseCase>(() => AttachEmployeeDocumentUseCase(
          storage: getIt<DocumentFileStorage>(),
          repository: getIt<EmployeeRepository>(),
        ))
    ..registerLazySingleton<CreateAreaUseCase>(() => CreateAreaUseCase(repository: getIt<AreaRepository>()))
    ..registerLazySingleton<CreatePositionUseCase>(
        () => CreatePositionUseCase(repository: getIt<PositionRepository>()))
    ..registerLazySingleton<DeactivateAreaUseCase>(() => DeactivateAreaUseCase(repository: getIt<AreaRepository>()))
    ..registerLazySingleton<GetAreasUseCase>(() => GetAreasUseCase(repository: getIt<AreaRepository>()))
    ..registerLazySingleton<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
          repository: getIt<EmployeeRepository>(),
        ))
    ..registerLazySingleton<GetEmployeeByIdUseCase>(
        () => GetEmployeeByIdUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<GetEmployeeDocumentsUseCase>(
        () => GetEmployeeDocumentsUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<GetEmployeesUseCase>(() => GetEmployeesUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<GetJobAssignmentsUseCase>(
        () => GetJobAssignmentsUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<GetOrganizationChartUseCase>(
        () => GetOrganizationChartUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<GetPositionsUseCase>(() => GetPositionsUseCase(repository: getIt<PositionRepository>()))
    ..registerLazySingleton<GetSubordinatesUseCase>(
        () => GetSubordinatesUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<RegisterEmployeeUseCase>(
        () => RegisterEmployeeUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<ReinstateEmployeeUseCase>(
        () => ReinstateEmployeeUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<RemoveDirectManagerUseCase>(
        () => RemoveDirectManagerUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<TerminateEmployeeUseCase>(
        () => TerminateEmployeeUseCase(repository: getIt<EmployeeRepository>()))
    ..registerLazySingleton<UpdateEmployeePersonalDataUseCase>(
        () => UpdateEmployeePersonalDataUseCase(repository: getIt<EmployeeRepository>()))
    ..registerFactory<EmployeesViewModel>(() => EmployeesViewModel(
          getEmployees: getIt<GetEmployeesUseCase>(),
          getAreas: getIt<GetAreasUseCase>(),
          getPositions: getIt<GetPositionsUseCase>(),
        ))
    ..registerFactory<EmployeeDetailViewModel>(() => EmployeeDetailViewModel(
          getEmployeeById: getIt<GetEmployeeByIdUseCase>(),
          getJobAssignments: getIt<GetJobAssignmentsUseCase>(),
          getEmployeeDocuments: getIt<GetEmployeeDocumentsUseCase>(),
          getAreas: getIt<GetAreasUseCase>(),
          getPositions: getIt<GetPositionsUseCase>(),
          getEmployees: getIt<GetEmployeesUseCase>(),
          getSubordinates: getIt<GetSubordinatesUseCase>(),
          assignJob: getIt<AssignJobUseCase>(),
          assignDirectManager: getIt<AssignDirectManagerUseCase>(),
          removeDirectManager: getIt<RemoveDirectManagerUseCase>(),
          terminateEmployee: getIt<TerminateEmployeeUseCase>(),
          reinstateEmployee: getIt<ReinstateEmployeeUseCase>(),
          attachEmployeeDocument: getIt<AttachEmployeeDocumentUseCase>(),
        ))
    ..registerFactory<EditPersonalDataViewModel>(() => EditPersonalDataViewModel(
          getEmployeeById: getIt<GetEmployeeByIdUseCase>(),
          updatePersonalData: getIt<UpdateEmployeePersonalDataUseCase>(),
        ))
    ..registerFactory<RegisterEmployeeViewModel>(() => RegisterEmployeeViewModel(
          registerEmployee: getIt<RegisterEmployeeUseCase>(),
          getAreas: getIt<GetAreasUseCase>(),
          getPositions: getIt<GetPositionsUseCase>(),
          getEmployees: getIt<GetEmployeesUseCase>(),
        ))
    ..registerFactory<OrganizationViewModel>(() => OrganizationViewModel(
          getAreas: getIt<GetAreasUseCase>(),
          getPositions: getIt<GetPositionsUseCase>(),
          createArea: getIt<CreateAreaUseCase>(),
          createPosition: getIt<CreatePositionUseCase>(),
          deactivateArea: getIt<DeactivateAreaUseCase>(),
        ))
    ..registerFactory<OrganizationChartViewModel>(() => OrganizationChartViewModel(
          getOrganizationChart: getIt<GetOrganizationChartUseCase>(),
          getAreas: getIt<GetAreasUseCase>(),
        ))
    ..registerFactory<MyProfileViewModel>(() => MyProfileViewModel(
          getCurrentEmployee: getIt<GetCurrentEmployeeUseCase>(),
          getEmployeeById: getIt<GetEmployeeByIdUseCase>(),
        ))
    ..registerFactory<MyRecordViewModel>(() => MyRecordViewModel(
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
          getEmployeeDocuments: getIt<GetEmployeeDocumentsUseCase>(),
        ));

  getIt<FeatureRouteRegistry>().register(WorkspaceNavigation.pageFor);
}
