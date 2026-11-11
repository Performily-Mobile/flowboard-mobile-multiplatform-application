import 'package:flowboard/features/attendance/domain/entity/attendance_page.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';

/// Paging of the records list: whether the server has more records and whether the next ones are
/// loading.
class AttendancePagingState {
  /// Creates the state.
  const AttendancePagingState({this.hasMore = false, this.isLoadingMore = false, this.loadMoreFailed = false});

  /// Paging after [page] was received from the server.
  factory AttendancePagingState.after(AttendancePage page) => AttendancePagingState(hasMore: !page.isLast);

  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  /// True when the next page can be asked for.
  bool get canLoadMore => hasMore && !isLoadingMore;

  /// Copy with the given values replaced.
  AttendancePagingState copyWith({bool? hasMore, bool? isLoadingMore, bool? loadMoreFailed}) {
    return AttendancePagingState(
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  /// Page to ask for when the list already shows [loadedCount] records.
  static int nextPage(int loadedCount) => loadedCount ~/ AttendancePage.defaultSize;

  /// Records of [page] added at the end of [current], skipping the ones already shown.
  static List<AttendanceRecord> merge(List<AttendanceRecord> current, AttendancePage page) {
    final Set<String> shown = current.map(_key).toSet();
    return <AttendanceRecord>[...current, ...page.records.where((AttendanceRecord record) => shown.add(_key(record)))];
  }

  static String _key(AttendanceRecord record) =>
      record.id?.toString() ?? '${record.employeeId}-${record.workDate.toIso8601String()}';
}
