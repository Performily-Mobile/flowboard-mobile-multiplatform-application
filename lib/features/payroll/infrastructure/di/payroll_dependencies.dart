import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/feature_route_registry.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/payroll/application/usecase/get_my_payslip_download_link_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_my_payslip_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_my_payslips_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_payroll_areas_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_payroll_periods_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/get_payslips_by_period_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/mark_payslip_as_observed_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/mark_payslip_as_paid_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/publish_period_payslips_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/replace_payslip_file_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/unlock_my_payslips_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/upload_payslip_use_case.dart';
import 'package:flowboard/features/payroll/application/usecase/validate_payslip_file_use_case.dart';
import 'package:flowboard/features/payroll/domain/repository/identity_verifier.dart';
import 'package:flowboard/features/payroll/domain/repository/payroll_employee_directory.dart';
import 'package:flowboard/features/payroll/domain/repository/payroll_period_repository.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_file_storage.dart';
import 'package:flowboard/features/payroll/domain/repository/payslip_repository.dart';
import 'package:flowboard/features/payroll/infrastructure/acl/workspace_payroll_employee_directory.dart';
import 'package:flowboard/features/payroll/infrastructure/local/local_auth_identity_verifier.dart';
import 'package:flowboard/features/payroll/infrastructure/local/local_payslip_file_storage.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payroll_period_service.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payslip_service.dart';
import 'package:flowboard/features/payroll/infrastructure/repository/payroll_period_repository_impl.dart';
import 'package:flowboard/features/payroll/infrastructure/repository/payslip_repository_impl.dart';
import 'package:flowboard/features/payroll/presentation/ui/navigation/payroll_navigation.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/my_payslips_view_model.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/payslip_viewer_view_model.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/upload_payslips_view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';

/// Registers the dependencies of the Payroll bounded context and its routes.
///
/// It must run after the Workspace setup, because the anti-corruption layer reads its use cases.
/// Services, repositories and use cases are singletons; view models are created for each screen.
void setupPayrollDependencies() {
  getIt
    ..registerLazySingleton<PayslipService>(() => PayslipService(client: getIt<ApiClient>()))
    ..registerLazySingleton<PayrollPeriodService>(() => PayrollPeriodService(client: getIt<ApiClient>()))
    ..registerLazySingleton<PayslipRepository>(() => PayslipRepositoryImpl(service: getIt<PayslipService>()))
    ..registerLazySingleton<PayrollPeriodRepository>(
        () => PayrollPeriodRepositoryImpl(service: getIt<PayrollPeriodService>()))
    ..registerLazySingleton<PayrollEmployeeDirectory>(() => WorkspacePayrollEmployeeDirectory(
          getAreasUseCase: getIt<GetAreasUseCase>(),
          getEmployeesUseCase: getIt<GetEmployeesUseCase>(),
        ))
    // Temporary, as in the Android app: replace it with the real storage once it is defined.
    ..registerLazySingleton<PayslipFileStorage>(() => const LocalPayslipFileStorage())
    ..registerLazySingleton<IdentityVerifier>(() => LocalAuthIdentityVerifier())
    ..registerLazySingleton<GetPayrollPeriodsUseCase>(
        () => GetPayrollPeriodsUseCase(repository: getIt<PayrollPeriodRepository>()))
    ..registerLazySingleton<GetPayrollAreasUseCase>(
        () => GetPayrollAreasUseCase(directory: getIt<PayrollEmployeeDirectory>()))
    ..registerLazySingleton<GetPayslipsByPeriodUseCase>(() => GetPayslipsByPeriodUseCase(
          repository: getIt<PayslipRepository>(),
          directory: getIt<PayrollEmployeeDirectory>(),
        ))
    ..registerLazySingleton<ValidatePayslipFileUseCase>(() => const ValidatePayslipFileUseCase())
    ..registerLazySingleton<UploadPayslipUseCase>(() => UploadPayslipUseCase(
          storage: getIt<PayslipFileStorage>(),
          repository: getIt<PayslipRepository>(),
        ))
    ..registerLazySingleton<ReplacePayslipFileUseCase>(() => ReplacePayslipFileUseCase(
          storage: getIt<PayslipFileStorage>(),
          repository: getIt<PayslipRepository>(),
        ))
    ..registerLazySingleton<PublishPeriodPayslipsUseCase>(
        () => PublishPeriodPayslipsUseCase(repository: getIt<PayrollPeriodRepository>()))
    ..registerLazySingleton<MarkPayslipAsPaidUseCase>(
        () => MarkPayslipAsPaidUseCase(repository: getIt<PayslipRepository>()))
    ..registerLazySingleton<MarkPayslipAsObservedUseCase>(
        () => MarkPayslipAsObservedUseCase(repository: getIt<PayslipRepository>()))
    ..registerLazySingleton<UnlockMyPayslipsUseCase>(
        () => UnlockMyPayslipsUseCase(verifier: getIt<IdentityVerifier>()))
    ..registerLazySingleton<GetMyPayslipsUseCase>(() => GetMyPayslipsUseCase(
          repository: getIt<PayslipRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<GetMyPayslipUseCase>(() => GetMyPayslipUseCase(
          repository: getIt<PayslipRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerLazySingleton<GetMyPayslipDownloadLinkUseCase>(() => GetMyPayslipDownloadLinkUseCase(
          repository: getIt<PayslipRepository>(),
          currentEmployeeProvider: getIt<CurrentEmployeeProvider>(),
        ))
    ..registerFactory<UploadPayslipsViewModel>(() => UploadPayslipsViewModel(
          getPayrollPeriods: getIt<GetPayrollPeriodsUseCase>(),
          getPayslipsByPeriod: getIt<GetPayslipsByPeriodUseCase>(),
          uploadPayslip: getIt<UploadPayslipUseCase>(),
          replacePayslipFile: getIt<ReplacePayslipFileUseCase>(),
          publishPeriodPayslips: getIt<PublishPeriodPayslipsUseCase>(),
          validatePayslipFile: getIt<ValidatePayslipFileUseCase>(),
          getPayrollAreas: getIt<GetPayrollAreasUseCase>(),
          markPayslipAsPaid: getIt<MarkPayslipAsPaidUseCase>(),
          markPayslipAsObserved: getIt<MarkPayslipAsObservedUseCase>(),
        ))
    ..registerFactory<MyPayslipsViewModel>(() => MyPayslipsViewModel(
          unlockMyPayslips: getIt<UnlockMyPayslipsUseCase>(),
          getMyPayslips: getIt<GetMyPayslipsUseCase>(),
          getDownloadLink: getIt<GetMyPayslipDownloadLinkUseCase>(),
        ))
    ..registerFactory<PayslipViewerViewModel>(() => PayslipViewerViewModel(
          getMyPayslip: getIt<GetMyPayslipUseCase>(),
          getDownloadLink: getIt<GetMyPayslipDownloadLinkUseCase>(),
        ));

  getIt<FeatureRouteRegistry>().register(PayrollNavigation.pageFor);
}
