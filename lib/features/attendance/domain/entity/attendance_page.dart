import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';

/// One page of the attendance history of the staff.
class AttendancePage {
  /// Creates the page.
  const AttendancePage({required this.records, required this.total, required this.isLast});

  /// Default page size.
  static const int defaultSize = 20;

  final List<AttendanceRecord> records;

  /// Records that match the filters, in every page.
  final int total;

  /// True when there are no more pages.
  final bool isLast;

  /// Copy with other [records].
  AttendancePage withRecords(List<AttendanceRecord> records) {
    return AttendancePage(records: records, total: total, isLast: isLast);
  }
}
