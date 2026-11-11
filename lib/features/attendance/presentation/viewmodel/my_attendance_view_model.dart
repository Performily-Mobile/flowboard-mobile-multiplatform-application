import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/attendance/application/usecase/get_my_attendance_use_case.dart';
import 'package:flowboard/features/attendance/application/usecase/register_punch_use_case.dart';
import 'package:flowboard/features/attendance/domain/entity/my_attendance.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/domain/valueobject/punch_type.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/my_attendance_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_error_messages.dart';

/// View model of the attendance of the signed-in employee: punches and records of a period.
class MyAttendanceViewModel extends ViewModel<MyAttendanceUiState> {
  /// Creates the view model with the current month.
  MyAttendanceViewModel({required this.getMyAttendance, required this.registerPunch})
      : super(MyAttendanceUiState(period: AttendancePeriod.currentMonth()));

  final GetMyAttendanceUseCase getMyAttendance;
  final RegisterPunchUseCase registerPunch;

  /// Loads the attendance of the period.
  Future<void> load() async {
    final AttendancePeriod period = state.period;
    update((MyAttendanceUiState s) => s.copyWith(isLoading: s.attendance == null, errorMessage: null));
    try {
      final MyAttendance result = await getMyAttendance.execute(period);
      if (state.period != period) return;
      update((MyAttendanceUiState s) => s.copyWith(isLoading: false, attendance: result));
    } catch (error) {
      if (state.period != period) return;
      update((MyAttendanceUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: attendanceErrorMessage(error, 'No se pudo cargar tu asistencia.'),
          ));
    }
  }

  /// Shows the records of [period].
  void onPeriodSelected(AttendancePeriod period) {
    if (period == state.period) return;
    update((MyAttendanceUiState s) => s.copyWith(period: period, attendance: null));
    load();
  }

  /// Filters the records by status.
  void onStatusFilterSelected(AttendanceStatusFilter filter) {
    update((MyAttendanceUiState s) => s.copyWith(statusFilter: filter));
  }

  /// Registers the punch that comes next: the check-in or the check-out.
  Future<void> punch() async {
    final PunchType? type = state.nextPunch;
    if (type == null || state.isPunching) return;
    update((MyAttendanceUiState s) => s.copyWith(isPunching: true));
    try {
      await registerPunch.execute(type);
      update((MyAttendanceUiState s) => s.copyWith(
            isPunching: false,
            snackbarMessage: type == PunchType.checkIn ? 'Entrada registrada.' : 'Salida registrada.',
          ));
      await load();
    } catch (error) {
      update((MyAttendanceUiState s) => s.copyWith(
            isPunching: false,
            snackbarMessage: attendanceErrorMessage(error, 'No se pudo registrar la marcación.'),
          ));
    }
  }

  /// Shows the message left by another screen and reloads the records.
  void onResult(String message) {
    update((MyAttendanceUiState s) => s.copyWith(snackbarMessage: message));
    load();
  }

  /// Clears the message once it was shown.
  void consumeMessage() => update((MyAttendanceUiState s) => s.copyWith(snackbarMessage: null));
}
