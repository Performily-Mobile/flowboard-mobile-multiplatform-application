import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_paging_state.dart';

const Object _keep = Object();

/// State of the records section: the history of the whole staff, by status and page.
class AttendanceRecordsUiState {
  /// Creates the state.
  const AttendanceRecordsUiState({
    required this.period,
    this.statusFilter = AttendanceStatusFilter.all,
    this.isLoading = false,
    this.records = const <AttendanceRecord>[],
    this.total = 0,
    this.paging = const AttendancePagingState(),
    this.errorMessage,
  });

  final AttendancePeriod period;
  final AttendanceStatusFilter statusFilter;
  final bool isLoading;
  final List<AttendanceRecord> records;

  /// Records that match the filters, in every page.
  final int total;
  final AttendancePagingState paging;
  final String? errorMessage;

  /// Copy with the given values replaced.
  AttendanceRecordsUiState copyWith({
    AttendancePeriod? period,
    AttendanceStatusFilter? statusFilter,
    bool? isLoading,
    List<AttendanceRecord>? records,
    int? total,
    AttendancePagingState? paging,
    Object? errorMessage = _keep,
  }) {
    return AttendanceRecordsUiState(
      period: period ?? this.period,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      total: total ?? this.total,
      paging: paging ?? this.paging,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
