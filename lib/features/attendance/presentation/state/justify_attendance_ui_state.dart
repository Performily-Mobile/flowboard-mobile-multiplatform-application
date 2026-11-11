import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';

const Object _keep = Object();

/// State of the form to justify a late, absent or incomplete day.
class JustifyAttendanceUiState {
  /// Creates the state.
  const JustifyAttendanceUiState({
    this.record,
    this.type = JustificationType.medicalRest,
    this.reason = '',
    this.evidenceUrl = '',
    this.reasonError,
    this.evidenceError,
    this.errorMessage,
    this.isSaving = false,
    this.resultMessage,
  });

  /// Day being justified; null until the screen starts the form.
  final AttendanceRecord? record;
  final JustificationType type;
  final String reason;
  final String evidenceUrl;
  final String? reasonError;
  final String? evidenceError;
  final String? errorMessage;
  final bool isSaving;

  /// When set, the justification was sent and the screen closes with this message.
  final String? resultMessage;

  /// True when the form can be sent.
  bool get canSave => !isSaving && record != null && reason.trim().isNotEmpty;

  /// Copy with the given values replaced.
  JustifyAttendanceUiState copyWith({
    Object? record = _keep,
    JustificationType? type,
    String? reason,
    String? evidenceUrl,
    Object? reasonError = _keep,
    Object? evidenceError = _keep,
    Object? errorMessage = _keep,
    bool? isSaving,
    Object? resultMessage = _keep,
  }) {
    return JustifyAttendanceUiState(
      record: identical(record, _keep) ? this.record : record as AttendanceRecord?,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      evidenceUrl: evidenceUrl ?? this.evidenceUrl,
      reasonError: identical(reasonError, _keep) ? this.reasonError : reasonError as String?,
      evidenceError: identical(evidenceError, _keep) ? this.evidenceError : evidenceError as String?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isSaving: isSaving ?? this.isSaving,
      resultMessage: identical(resultMessage, _keep) ? this.resultMessage : resultMessage as String?,
    );
  }
}
