import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/iam/application/session/session_manager.dart';
import 'package:flowboard/features/iam/application/usecase/change_account_role_use_case.dart';
import 'package:flowboard/features/iam/application/usecase/change_password_use_case.dart';
import 'package:flowboard/features/iam/application/usecase/get_accounts_use_case.dart';
import 'package:flowboard/features/iam/application/usecase/reset_account_password_use_case.dart';
import 'package:flowboard/features/iam/application/usecase/restore_session_use_case.dart';
import 'package:flowboard/features/iam/application/usecase/sign_in_use_case.dart';
import 'package:flowboard/features/iam/application/usecase/sign_out_use_case.dart';
import 'package:flowboard/features/iam/domain/repository/iam_repository.dart';
import 'package:flowboard/features/iam/domain/repository/session_store.dart';
import 'package:flowboard/features/iam/infrastructure/local/secure_session_store.dart';
import 'package:flowboard/features/iam/infrastructure/remote/iam_service.dart';
import 'package:flowboard/features/iam/infrastructure/repository/iam_repository_impl.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/account_security_view_model.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/accounts_view_model.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/login_view_model.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/password_change_view_model.dart';

/// Registers the dependencies of the IAM bounded context.
///
/// The service, the repository, the session store, the session manager and the use cases are
/// singletons, so the whole app shares one session; view models are created for each screen.
void setupIamDependencies() {
  getIt
    ..registerLazySingleton<IamService>(() => IamService(client: getIt<ApiClient>()))
    ..registerLazySingleton<IamRepository>(() => IamRepositoryImpl(service: getIt<IamService>()))
    ..registerLazySingleton<SessionStore>(() => const SecureSessionStore(storage: FlutterSecureStorage()))
    ..registerLazySingleton<SessionManager>(() => SessionManager(store: getIt<SessionStore>()))
    ..registerLazySingleton<SignInUseCase>(
        () => SignInUseCase(repository: getIt<IamRepository>(), sessionManager: getIt<SessionManager>()))
    ..registerLazySingleton<ChangePasswordUseCase>(
        () => ChangePasswordUseCase(repository: getIt<IamRepository>(), sessionManager: getIt<SessionManager>()))
    ..registerLazySingleton<SignOutUseCase>(
        () => SignOutUseCase(repository: getIt<IamRepository>(), sessionManager: getIt<SessionManager>()))
    ..registerLazySingleton<RestoreSessionUseCase>(
        () => RestoreSessionUseCase(sessionManager: getIt<SessionManager>()))
    ..registerLazySingleton<GetAccountsUseCase>(() => GetAccountsUseCase(repository: getIt<IamRepository>()))
    ..registerLazySingleton<ChangeAccountRoleUseCase>(
        () => ChangeAccountRoleUseCase(repository: getIt<IamRepository>()))
    ..registerLazySingleton<ResetAccountPasswordUseCase>(
        () => ResetAccountPasswordUseCase(repository: getIt<IamRepository>()))
    ..registerFactory<LoginViewModel>(() => LoginViewModel(signIn: getIt<SignInUseCase>()))
    ..registerFactory<PasswordChangeViewModel>(() => PasswordChangeViewModel(
          changePassword: getIt<ChangePasswordUseCase>(),
          signOut: getIt<SignOutUseCase>(),
          sessionManager: getIt<SessionManager>(),
        ))
    ..registerFactory<AccountSecurityViewModel>(() => AccountSecurityViewModel(
          signOut: getIt<SignOutUseCase>(),
          sessionManager: getIt<SessionManager>(),
        ))
    ..registerFactory<AccountsViewModel>(() => AccountsViewModel(
          getAccounts: getIt<GetAccountsUseCase>(),
          changeAccountRole: getIt<ChangeAccountRoleUseCase>(),
          resetAccountPassword: getIt<ResetAccountPasswordUseCase>(),
          sessionManager: getIt<SessionManager>(),
        ));
}
