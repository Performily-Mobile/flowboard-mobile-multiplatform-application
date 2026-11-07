import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/feature_route_registry.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/benefits/application/usecase/adjust_vacation_balance_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/assign_benefit_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/change_benefit_type_status_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/create_benefit_type_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_assignment_targets_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_assignments_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_benefit_types_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_my_benefits_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_my_vacation_balance_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_vacation_balance_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_vacation_balances_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/preview_area_assignment_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/register_delivery_use_case.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_assignment_repository.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_type_repository.dart';
import 'package:flowboard/features/benefits/domain/repository/vacation_balance_repository.dart';
import 'package:flowboard/features/benefits/domain/repository/workspace_directory.dart';
import 'package:flowboard/features/benefits/infrastructure/acl/workspace_directory_adapter.dart';
import 'package:flowboard/features/benefits/infrastructure/local/vacation_balance_cache.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_service.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_type_service.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/vacation_balance_service.dart';
import 'package:flowboard/features/benefits/infrastructure/repository/benefit_assignment_repository_impl.dart';
import 'package:flowboard/features/benefits/infrastructure/repository/benefit_type_repository_impl.dart';
import 'package:flowboard/features/benefits/infrastructure/repository/vacation_balance_repository_impl.dart';
import 'package:flowboard/features/benefits/presentation/ui/navigation/benefits_navigation.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/assign_benefit_view_model.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/benefits_admin_view_model.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/my_benefits_view_model.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/my_vacation_balance_view_model.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/vacation_balance_detail_view_model.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/vacation_balances_view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';

/// Registers the dependencies of the Benefits bounded context and its routes.
///
/// It must run after the Workspace setup, because the anti-corruption layer reads its use cases.
/// Services, repositories and use cases are singletons; view models are created for each screen.
void setupBenefitsDependencies() {
  getIt
    ..registerLazySingleton<BenefitTypeService>(() => BenefitTypeService(client: getIt<ApiClient>()))
    ..registerLazySingleton<BenefitService>(() => BenefitService(client: getIt<ApiClient>()))
    ..registerLazySingleton<VacationBalanceService>(() => VacationBalanceService(client: getIt<ApiClient>()))
    ..registerLazySingleton<VacationBalanceCache>(() => const VacationBalanceCache())
    ..registerLazySingleton<BenefitTypeRepository>(() => BenefitTypeRepositoryImpl(service: getIt<BenefitTypeService>()))
    ..registerLazySingleton<BenefitAssignmentRepository>(
        () => BenefitAssignmentRepositoryImpl(service: getIt<BenefitService>()))
    ..registerLazySingleton<VacationBalanceRepository>(() => VacationBalanceRepositoryImpl(
          service: getIt<VacationBalanceService>(),
          cache: getIt<VacationBalanceCache>(),
        ))
    ..registerLazySingleton<WorkspaceDirectory>(() => WorkspaceDirectoryAdapter(
          getAreas: getIt<GetAreasUseCase>(),
          getEmployees: getIt<GetEmployeesUseCase>(),
        ))
    ..registerLazySingleton<GetBenefitTypesUseCase>(
        () => GetBenefitTypesUseCase(repository: getIt<BenefitTypeRepository>()))
    ..registerLazySingleton<CreateBenefitTypeUseCase>(
        () => CreateBenefitTypeUseCase(repository: getIt<BenefitTypeRepository>()))
    ..registerLazySingleton<ChangeBenefitTypeStatusUseCase>(
        () => ChangeBenefitTypeStatusUseCase(repository: getIt<BenefitTypeRepository>()))
    ..registerLazySingleton<GetAssignmentsUseCase>(
        () => GetAssignmentsUseCase(repository: getIt<BenefitAssignmentRepository>()))
    ..registerLazySingleton<GetAssignmentTargetsUseCase>(
        () => GetAssignmentTargetsUseCase(directory: getIt<WorkspaceDirectory>()))
    ..registerLazySingleton<PreviewAreaAssignmentUseCase>(
        () => PreviewAreaAssignmentUseCase(repository: getIt<BenefitAssignmentRepository>()))
    ..registerLazySingleton<AssignBenefitUseCase>(
        () => AssignBenefitUseCase(repository: getIt<BenefitAssignmentRepository>()))
    ..registerLazySingleton<RegisterDeliveryUseCase>(() => RegisterDeliveryUseCase(
          repository: getIt<BenefitAssignmentRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<GetMyBenefitsUseCase>(() => GetMyBenefitsUseCase(
          repository: getIt<BenefitAssignmentRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<GetMyVacationBalanceUseCase>(() => GetMyVacationBalanceUseCase(
          repository: getIt<VacationBalanceRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<GetVacationBalancesUseCase>(
        () => GetVacationBalancesUseCase(repository: getIt<VacationBalanceRepository>()))
    ..registerLazySingleton<GetVacationBalanceUseCase>(
        () => GetVacationBalanceUseCase(repository: getIt<VacationBalanceRepository>()))
    ..registerLazySingleton<AdjustVacationBalanceUseCase>(() => AdjustVacationBalanceUseCase(
          repository: getIt<VacationBalanceRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerFactory<BenefitsAdminViewModel>(() => BenefitsAdminViewModel(
          getBenefitTypes: getIt<GetBenefitTypesUseCase>(),
          createBenefitType: getIt<CreateBenefitTypeUseCase>(),
          changeBenefitTypeStatus: getIt<ChangeBenefitTypeStatusUseCase>(),
          getAssignments: getIt<GetAssignmentsUseCase>(),
          registerDelivery: getIt<RegisterDeliveryUseCase>(),
        ))
    ..registerFactory<AssignBenefitViewModel>(() => AssignBenefitViewModel(
          getBenefitTypes: getIt<GetBenefitTypesUseCase>(),
          getTargets: getIt<GetAssignmentTargetsUseCase>(),
          previewAreaAssignment: getIt<PreviewAreaAssignmentUseCase>(),
          assignBenefit: getIt<AssignBenefitUseCase>(),
        ))
    ..registerFactory<VacationBalancesViewModel>(
        () => VacationBalancesViewModel(getVacationBalances: getIt<GetVacationBalancesUseCase>()))
    ..registerFactory<VacationBalanceDetailViewModel>(() => VacationBalanceDetailViewModel(
          getVacationBalance: getIt<GetVacationBalanceUseCase>(),
          adjustVacationBalance: getIt<AdjustVacationBalanceUseCase>(),
        ))
    ..registerFactory<MyBenefitsViewModel>(() => MyBenefitsViewModel(getMyBenefits: getIt<GetMyBenefitsUseCase>()))
    ..registerFactory<MyVacationBalanceViewModel>(
        () => MyVacationBalanceViewModel(getMyVacationBalance: getIt<GetMyVacationBalanceUseCase>()));

  getIt<FeatureRouteRegistry>().register(BenefitsNavigation.pageFor);
}
