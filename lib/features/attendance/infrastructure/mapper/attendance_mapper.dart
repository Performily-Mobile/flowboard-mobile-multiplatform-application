import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';

class AttendanceMapper {
  static int? integer(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');

  static double? decimal(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('$v');

  static AttendanceRecord fromJson(Map<String, dynamic> j) => AttendanceRecord(
        id: integer(j['id']),
        employeeId: integer(j['employeeId']) ?? 0,
        workDate: '${j['workDate'] ?? ''}',
        status: '${j['status'] ?? 'INCOMPLETE'}',
        employeeName: j['employeeName']?.toString() ??
            [j['firstName'], j['lastName']]
                .whereType<String>()
                .join(' ')
                .trim(),
        areaId: integer(j['areaId']),
        areaName: j['areaName']?.toString(),
        positionTitle: j['positionTitle']?.toString(),
        checkInTime: j['checkInTime']?.toString(),
        checkOutTime: j['checkOutTime']?.toString(),
        effectiveHours: decimal(j['effectiveHours'] ?? j['workedHours']),
        overtimeHours: decimal(j['overtimeHours'] ?? j['overtime']),
      );
}