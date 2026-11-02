import 'package:flowboard/features/workspace/domain/entity/employee.dart';

const Object _keep = Object();

/// State of the profile of the signed-in employee.
class MyProfileUiState {
  /// Creates the state.
  const MyProfileUiState({this.isLoading = false, this.employee, this.directManager, this.errorMessage});

  final bool isLoading;
  final Employee? employee;
  final Employee? directManager;
  final String? errorMessage;

  /// Copy with the given values replaced.
  MyProfileUiState copyWith({
    bool? isLoading,
    Object? employee = _keep,
    Object? directManager = _keep,
    Object? errorMessage = _keep,
  }) {
    return MyProfileUiState(
      isLoading: isLoading ?? this.isLoading,
      employee: identical(employee, _keep) ? this.employee : employee as Employee?,
      directManager: identical(directManager, _keep) ? this.directManager : directManager as Employee?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
