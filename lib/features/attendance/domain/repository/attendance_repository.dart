import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> myRecords(
      int employeeId, DateTime from, DateTime to);

  Future<List<AttendanceRecord>> employeeRecords(
      int employeeId, DateTime from, DateTime to);

  Future<List<AttendanceRecord>> areaRecords(int areaId, DateTime day);

  Future> employeeHours(
      int employeeId, DateTime from, DateTime to);

  Future> areaSummary(
      int areaId, DateTime from, DateTime to);

  Future<int> punch(int employeeId, String type);

  Future<AttendanceRecord> justify(
      int recordId, String reason, String? evidenceUrl);

  Future<List>> areas();

  Future<List>> employees(String query);
}