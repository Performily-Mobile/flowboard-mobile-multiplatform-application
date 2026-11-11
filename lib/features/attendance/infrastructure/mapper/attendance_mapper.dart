import 'package:flowboard/features/attendance/domain/entity/attendance_area_summary.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_hours.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_page.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';
import 'package:flowboard/features/attendance/domain/valueobject/punch_type.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_area_summary_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_hours_summary_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_page_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_record_dto.dart';

/// Converts the DTOs of the attendance API to domain objects and back.
class AttendanceMapper {
  const AttendanceMapper._();

  /// Record of [dto].
  static AttendanceRecord toRecord(AttendanceRecordDto dto) {
    return AttendanceRecord(
      id: dto.id,
      employeeId: dto.employeeId,
      workDate: DateTime.parse(dto.workDate),
      checkIn: _dateTime(dto.checkInTime),
      checkOut: _dateTime(dto.checkOutTime),
      workedHours: dto.workedHours,
      overtimeHours: dto.overtimeHours,
      status: statusFromApi(dto.status),
      justificationReason: dto.justificationReason,
    );
  }

  /// Page of [dto].
  static AttendancePage toPage(AttendancePageDto dto) {
    return AttendancePage(records: dto.content.map(toRecord).toList(), total: dto.totalElements, isLast: dto.last);
  }

  /// Summary of [dto].
  static AttendanceAreaSummary toAreaSummary(AttendanceAreaSummaryDto dto) {
    return AttendanceAreaSummary(
      areaId: dto.areaId,
      onTime: dto.onTime,
      late: dto.late,
      incomplete: dto.incomplete,
      absent: dto.absent,
      justified: dto.justified,
      workedHours: dto.workedHours,
      overtimeHours: dto.overtimeHours,
    );
  }

  /// Hours of [dto].
  static AttendanceHours toHours(AttendanceHoursSummaryDto dto) {
    return AttendanceHours(employeeId: dto.employeeId, workedHours: dto.workedHours, overtimeHours: dto.overtimeHours);
  }

  /// API name of [status], for example `ON_TIME`.
  static String statusToApi(AttendanceStatus status) {
    return switch (status) {
      AttendanceStatus.onTime => 'ON_TIME',
      AttendanceStatus.late => 'LATE',
      AttendanceStatus.incomplete => 'INCOMPLETE',
      AttendanceStatus.absent => 'ABSENT',
      AttendanceStatus.justified => 'JUSTIFIED',
    };
  }

  /// Status of the API name [raw]; an unknown name counts as incomplete.
  static AttendanceStatus statusFromApi(String raw) {
    for (final AttendanceStatus status in AttendanceStatus.values) {
      if (statusToApi(status) == raw.toUpperCase()) return status;
    }
    return AttendanceStatus.incomplete;
  }

  /// API name of [type].
  static String punchTypeToApi(PunchType type) {
    return switch (type) {
      PunchType.checkIn => 'CHECK_IN',
      PunchType.checkOut => 'CHECK_OUT',
    };
  }

  /// Day as "yyyy-MM-dd".
  static String toApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime? _dateTime(String? raw) => raw == null ? null : DateTime.tryParse(raw);
}
