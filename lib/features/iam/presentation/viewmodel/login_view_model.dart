import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/iam/application/usecase/sign_in_use_case.dart';
import 'package:flowboard/features/iam/presentation/state/login_ui_state.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/iam_error_messages.dart';

/// Handles the sign-in screen. When the sign in works, the session starts and the app leaves the
/// login by itself.
class LoginViewModel extends ViewModel<LoginUiState> {
  /// Creates the view model.
  LoginViewModel({required this.signIn}) : super(const LoginUiState());

  final SignInUseCase signIn;

  void onUsernameChange(String value) =>
      update((LoginUiState s) => s.copyWith(username: value, errorMessage: null));

  void onPasswordChange(String value) =>
      update((LoginUiState s) => s.copyWith(password: value, errorMessage: null));

  void togglePasswordVisibility() =>
      update((LoginUiState s) => s.copyWith(isPasswordVisible: !s.isPasswordVisible));

  void showRecovery() => update((LoginUiState s) => s.copyWith(isRecoveryVisible: true, errorMessage: null));

  void hideRecovery() => update((LoginUiState s) => s.copyWith(isRecoveryVisible: false));

  /// Signs in with the typed e-mail and password.
  Future<void> submit() async {
    if (state.isSubmitting) return;
    update((LoginUiState s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await signIn.execute(username: state.username, password: state.password);
      update((LoginUiState s) => s.copyWith(isSubmitting: false, password: ''));
    } catch (error) {
      update((LoginUiState s) => s.copyWith(
            isSubmitting: false,
            errorMessage: iamErrorMessage(error, IamAction.signIn, 'No se pudo iniciar sesión. Inténtalo otra vez.'),
          ));
    }
  }
}
