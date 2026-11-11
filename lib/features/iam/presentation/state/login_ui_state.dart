const Object _keep = Object();

/// State of the sign-in screen.
class LoginUiState {
  /// Creates the state.
  const LoginUiState({
    this.username = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.isRecoveryVisible = false,
  });

  final String username;
  final String password;
  final bool isPasswordVisible;
  final bool isSubmitting;
  final String? errorMessage;

  /// True while the "recover access" page is shown instead of the form.
  final bool isRecoveryVisible;

  /// True when both fields are filled and no request is running.
  bool get canSubmit => username.trim().isNotEmpty && password.isNotEmpty && !isSubmitting;

  /// Copy with the given values replaced.
  LoginUiState copyWith({
    String? username,
    String? password,
    bool? isPasswordVisible,
    bool? isSubmitting,
    Object? errorMessage = _keep,
    bool? isRecoveryVisible,
  }) {
    return LoginUiState(
      username: username ?? this.username,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isRecoveryVisible: isRecoveryVisible ?? this.isRecoveryVisible,
    );
  }
}
