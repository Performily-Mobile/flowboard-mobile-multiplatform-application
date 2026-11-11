import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_home_ui_state.dart';

/// View model of the attendance tab: chooses the view of the role and the section shown to HR.
class AttendanceHomeViewModel extends ViewModel<AttendanceHomeUiState> {
  /// Creates the view model with the role of the viewer.
  AttendanceHomeViewModel({required CurrentEmployeeProvider currentEmployeeProvider})
      : super(AttendanceHomeUiState(role: currentEmployeeProvider.currentRole()));

  /// Shows [section].
  void onSectionSelected(AttendanceSection section) {
    update((AttendanceHomeUiState s) => s.copyWith(section: section));
  }
}
