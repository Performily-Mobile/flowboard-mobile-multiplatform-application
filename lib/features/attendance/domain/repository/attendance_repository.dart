import 'package:flowboard/features/attendance/domain/entity/attendance_area_summary.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_hours.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_page.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';
import 'package:flowboard/features/attendance/domain/valueobject/punch_type.dart';

/// Access to the attendance records of the backend.
abstract class AttendanceRepository {
  /// Records of the signed-in employee in [period].
  Future<List<AttendanceRecord>> getMyRecords(AttendancePeriod period);

  /// Records of the employee [employeeId] in [period]; only for the HR staff.
  Future<List<AttendanceRecord>> getEmployeeRecords(int employeeId, AttendancePeriod period);

  /// One page of the records of the whole staff, newest first; only for the HR staff.
  Future<AttendancePage> getRecords({
    required AttendancePeriod period,
    AttendanceStatus? status,
    required int page,
    required int size,
  });

  /// Records of the area [areaId] in [period]; only for the HR staff.
  Future<List<AttendanceRecord>> getAreaRecords(int areaId, AttendancePeriod period);

  /// Totals of the area [areaId] in [period]; only for the HR staff.
  Future<AttendanceAreaSummary> getAreaSummary(int areaId, AttendancePeriod period);

  /// Worked and overtime hours of the employee [employeeId] in [period].
  Future<AttendanceHours> getEmployeeHours(int employeeId, AttendancePeriod period);

  /// Registers a punch of [employeeId] now and returns the identifier of the record.
  Future<int> registerPunch({required int employeeId, required PunchType type});

  /// Justifies the record [recordId] and returns it updated.
  Future<AttendanceRecord> justify({required int recordId, required String reason, String? evidenceUrl});
}
