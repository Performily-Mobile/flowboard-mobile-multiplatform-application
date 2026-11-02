import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_current_employee_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employee_by_id_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/presentation/state/my_profile_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/workspace_error_messages.dart';

/// View model of the profile of the signed-in employee.
class MyProfileViewModel extends ViewModel<MyProfileUiState> {
  /// Creates the view model and loads the profile.
  MyProfileViewModel({required this.getCurrentEmployee, required this.getEmployeeById})
      : super(const MyProfileUiState()) {
    load();
  }

  final GetCurrentEmployeeUseCase getCurrentEmployee;
  final GetEmployeeByIdUseCase getEmployeeById;

  /// Loads the employee and their direct manager.
  Future<void> load() async {
    update((MyProfileUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    try {
      final Employee employee = await getCurrentEmployee.execute();
      final EmployeeId? managerId = employee.directManagerId;
      final Employee? manager =
          managerId == null ? null : await attemptOrNull(() => getEmployeeById.execute(managerId));
      update((MyProfileUiState s) => s.copyWith(isLoading: false, employee: employee, directManager: manager));
    } catch (error) {
      update((MyProfileUiState s) => s.copyWith(isLoading: false, errorMessage: workspaceErrorMessage(error)));
    }
  }
}
