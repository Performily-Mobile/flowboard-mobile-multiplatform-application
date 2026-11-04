import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';

class AttendanceAreaUiState {
  const AttendanceAreaUiState({
    this.loading = false,
    this.error,
    this.records = const [],
  });

  final bool loading;
  final String? error;
  final List<AttendanceRecord> records;
}