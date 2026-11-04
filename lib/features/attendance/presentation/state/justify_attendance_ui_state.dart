import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';

class JustifyAttendanceUiState {
  const JustifyAttendanceUiState({
    this.loading = false,
    this.error,
    this.records = const [],
  });

  final bool loading;
  final String? error;
  final List<AttendanceRecord> records;
}