import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/attendance/application/usecase/get_attendance_records_use_case.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_page.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_paging_state.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_records_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_error_messages.dart';

/// View model of the records section: the history of the whole staff, by status and page.
class AttendanceRecordsViewModel extends ViewModel<AttendanceRecordsUiState> {
  /// Creates the view model with the current month.
  AttendanceRecordsViewModel({required this.getAttendanceRecords})
      : super(AttendanceRecordsUiState(period: AttendancePeriod.currentMonth()));

  final GetAttendanceRecordsUseCase getAttendanceRecords;

  /// Loads the first page of the records.
  Future<void> load() async {
    final AttendanceRecordsUiState current = state;
    update((AttendanceRecordsUiState s) => s.copyWith(isLoading: s.records.isEmpty, errorMessage: null));
    try {
      final AttendancePage result = await getAttendanceRecords.execute(
        period: current.period,
        status: current.statusFilter.status,
      );
      if (!_sameQuery(current)) return;
      update((AttendanceRecordsUiState s) => s.copyWith(
            isLoading: false,
            records: result.records,
            total: result.total,
            paging: AttendancePagingState.after(result),
          ));
    } catch (error) {
      if (!_sameQuery(current)) return;
      update((AttendanceRecordsUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: attendanceErrorMessage(error, 'No se pudieron cargar los registros.'),
          ));
    }
  }

  /// Shows the records of [period].
  void onPeriodSelected(AttendancePeriod period) {
    if (period == state.period) return;
    update((AttendanceRecordsUiState s) => s.copyWith(period: period, records: const <AttendanceRecord>[], total: 0));
    load();
  }

  /// Filters the records by status.
  void onStatusFilterSelected(AttendanceStatusFilter filter) {
    if (filter == state.statusFilter) return;
    update((AttendanceRecordsUiState s) =>
        s.copyWith(statusFilter: filter, records: const <AttendanceRecord>[], total: 0));
    load();
  }

  /// Loads the next page and adds it at the end of the list.
  Future<void> loadMore() async {
    final AttendanceRecordsUiState current = state;
    if (!current.paging.canLoadMore) return;
    update((AttendanceRecordsUiState s) =>
        s.copyWith(paging: s.paging.copyWith(isLoadingMore: true, loadMoreFailed: false)));
    try {
      final AttendancePage result = await getAttendanceRecords.execute(
        period: current.period,
        status: current.statusFilter.status,
        page: AttendancePagingState.nextPage(current.records.length),
      );
      if (!_sameQuery(current)) return;
      update((AttendanceRecordsUiState s) => s.copyWith(
            records: AttendancePagingState.merge(s.records, result),
            total: result.total,
            paging: AttendancePagingState.after(result),
          ));
    } catch (_) {
      if (!_sameQuery(current)) return;
      update((AttendanceRecordsUiState s) =>
          s.copyWith(paging: s.paging.copyWith(isLoadingMore: false, loadMoreFailed: true)));
    }
  }

  bool _sameQuery(AttendanceRecordsUiState query) =>
      state.period == query.period && state.statusFilter == query.statusFilter;
}
