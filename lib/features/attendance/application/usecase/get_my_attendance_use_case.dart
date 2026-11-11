import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/entity/my_attendance.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';

/// Gets the attendance of the signed-in employee in a period, with the record of today.
class GetMyAttendanceUseCase {
  /// Creates the use case.
  const GetMyAttendanceUseCase({required this.repository});

  final AttendanceRepository repository;

  /// Attendance in [period].
  Future<MyAttendance> execute(AttendancePeriod period) async {
    final DateTime now = DateTime.now();
    final List<AttendanceRecord> records = (await repository.getMyRecords(period)).toList()
      ..sort(AttendanceRecord.newestFirst);
    final List<AttendanceRecord> todayRecords = _includesToday(period, now)
        ? records
        : await repository.getMyRecords(AttendancePeriod(from: now, to: now));
    return MyAttendance(records: records, today: _recordOf(todayRecords, now));
  }

  bool _includesToday(AttendancePeriod period, DateTime now) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    return !today.isBefore(period.from) && !today.isAfter(period.to);
  }

  AttendanceRecord? _recordOf(List<AttendanceRecord> records, DateTime day) {
    for (final AttendanceRecord record in records) {
      if (record.isOn(day)) return record;
    }
    return null;
  }
}
