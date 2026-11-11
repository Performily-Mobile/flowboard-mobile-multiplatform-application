import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/attendance/application/usecase/justify_attendance_use_case.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/justify_attendance_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_error_messages.dart';

/// View model of the form to justify a late, absent or incomplete day.
class JustifyAttendanceViewModel extends ViewModel<JustifyAttendanceUiState> {
  /// Creates the view model.
  JustifyAttendanceViewModel({required this.justifyAttendance}) : super(const JustifyAttendanceUiState());

  final JustifyAttendanceUseCase justifyAttendance;

  static const int _maxUrl = 300;

  /// Starts the form for [record].
  void start(AttendanceRecord record) => update((JustifyAttendanceUiState s) => s.copyWith(record: record));

  /// Changes the kind of justification.
  void onTypeChange(JustificationType type) => update((JustifyAttendanceUiState s) => s.copyWith(type: type));

  /// Changes the reason; the kind is added in front, so it keeps room for the longest kind.
  void onReasonChange(String value) {
    final int max = JustifyAttendanceUseCase.maxReason - _longestPrefix;
    update((JustifyAttendanceUiState s) =>
        s.copyWith(reason: value.length > max ? value.substring(0, max) : value, reasonError: null));
  }

  /// Changes the link to the evidence.
  void onEvidenceUrlChange(String value) {
    update((JustifyAttendanceUiState s) =>
        s.copyWith(evidenceUrl: value.length > _maxUrl ? value.substring(0, _maxUrl) : value, evidenceError: null));
  }

  /// Sends the justification.
  Future<void> save() async {
    final JustifyAttendanceUiState current = state;
    final AttendanceRecord? record = current.record;
    if (record == null || current.isSaving) return;
    if (current.reason.trim().isEmpty) {
      update((JustifyAttendanceUiState s) => s.copyWith(reasonError: 'Ingresa el motivo de la justificación.'));
      return;
    }
    update((JustifyAttendanceUiState s) => s.copyWith(isSaving: true, errorMessage: null));
    try {
      await justifyAttendance.execute(
        record,
        reason: '${_prefix(current.type)}${current.reason.trim()}',
        evidenceUrl: current.evidenceUrl,
      );
      update((JustifyAttendanceUiState s) => s.copyWith(isSaving: false, resultMessage: 'Justificación enviada.'));
    } catch (error) {
      final String message = attendanceErrorMessage(error, 'No se pudo enviar la justificación.');
      update((JustifyAttendanceUiState s) => message.contains('enlace')
          ? s.copyWith(isSaving: false, evidenceError: message)
          : s.copyWith(isSaving: false, errorMessage: message));
    }
  }

  String _prefix(JustificationType type) => '${type.label}: ';

  int get _longestPrefix => JustificationType.values
      .map((JustificationType type) => _prefix(type).length)
      .reduce((int a, int b) => a > b ? a : b);
}
