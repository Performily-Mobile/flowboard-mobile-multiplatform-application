import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/attendance/application/usecase/get_employee_attendance_use_case.dart';
import 'package:flowboard/features/attendance/domain/entity/employee_attendance.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/employee_attendance_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_error_messages.dart';

/// View model of the attendance detail of one employee, seen by the HR staff.
class EmployeeAttendanceViewModel extends ViewModel<EmployeeAttendanceUiState> {
  /// Creates the view model with the current month.
  EmployeeAttendanceViewModel({required this.getEmployeeAttendance})
      : super(EmployeeAttendanceUiState(period: AttendancePeriod.currentMonth()));

  final GetEmployeeAttendanceUseCase getEmployeeAttendance;

  /// Loads the attendance of the employee [employeeId] in [period], or in the period shown.
  Future<void> load(int employeeId, {AttendancePeriod? period}) async {
    final AttendancePeriod query = period ?? state.period;
    update((EmployeeAttendanceUiState s) => s.copyWith(
          employeeId: employeeId,
          period: query,
          isLoading: s.attendance == null,
          errorMessage: null,
        ));
    try {
      final EmployeeAttendance result = await getEmployeeAttendance.execute(employeeId, query);
      if (state.period != query) return;
      update((EmployeeAttendanceUiState s) => s.copyWith(isLoading: false, attendance: result));
    } catch (error) {
      if (state.period != query) return;
      update((EmployeeAttendanceUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: attendanceErrorMessage(error, 'No se pudo cargar la asistencia del colaborador.'),
          ));
    }
  }

  /// Loads the attendance again.
  void retry() {
    final int? employeeId = state.employeeId;
    if (employeeId != null) load(employeeId);
  }

  /// Shows the records of [period].
  void onPeriodSelected(AttendancePeriod period) {
    final int? employeeId = state.employeeId;
    if (employeeId == null || period == state.period) return;
    update((EmployeeAttendanceUiState s) => s.copyWith(attendance: null));
    load(employeeId, period: period);
  }

  /// Filters the records by status.
  void onStatusFilterSelected(AttendanceStatusFilter filter) {
    update((EmployeeAttendanceUiState s) => s.copyWith(statusFilter: filter));
  }
}
