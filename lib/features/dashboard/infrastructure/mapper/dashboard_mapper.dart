import 'package:flowboard/features/dashboard/domain/entity/dashboard_sources.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_attendance_summary_dto.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_request_dto.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';

/// Translates the models of other bounded contexts into the dashboard model.
class DashboardMapper {
  const DashboardMapper._();

  /// Converts a Workspace area into a dashboard area.
  static DashboardArea toArea(Area area) {
    return DashboardArea(id: area.id, name: area.name, activeEmployees: area.activeEmployees);
  }

  /// Converts the Attendance response into an attendance summary.
  static AttendanceSummary toSummary(DashboardAttendanceSummaryDto dto) {
    return AttendanceSummary(
      onTime: dto.onTime,
      late: dto.late,
      absent: dto.absent,
      incomplete: dto.incomplete,
      justified: dto.justified,
    );
  }

  /// Converts a pending request of the Request context into the dashboard model.
  ///
  /// [requester] comes from Workspace; without it the name falls back to the identifier and the
  /// missing direct manager cannot be told.
  static RequestToAttend toRequestToAttend(DashboardRequestDto dto, Employee? requester) {
    final DateTime? start = _date(dto.startDate);
    final DateTime? end = _date(dto.endDate);
    final bool validPeriod = start != null && end != null && !end.isBefore(start);
    return RequestToAttend(
      requestId: dto.id,
      requesterName: requester?.name.fullName ?? 'Colaborador #${dto.requesterId}',
      requestTypeName: dto.requestTypeName,
      startDate: validPeriod ? start : null,
      endDate: validPeriod ? end : null,
      hours: validPeriod ? _hours(dto.startTime, dto.endTime) : null,
      withoutDirectManager: requester != null && requester.directManagerId == null,
    );
  }

  /// Moment the request was submitted, used to put the oldest first.
  static DateTime submittedAt(DashboardRequestDto dto) {
    final String? raw = dto.submittedAt;
    return (raw == null ? null : DateTime.tryParse(raw)) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// Text yyyy-MM-dd of [date], as the backend expects it.
  static String formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  static DateTime? _date(String? raw) {
    final DateTime? parsed = raw == null ? null : DateTime.tryParse(raw);
    return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Hours between two "HH:mm" times, or null when the request has no hourly range.
  static double? _hours(String? start, String? end) {
    final int? from = _minutes(start);
    final int? to = _minutes(end);
    if (from == null || to == null || to <= from) return null;
    return (to - from) / 60.0;
  }

  static int? _minutes(String? time) {
    if (time == null) return null;
    final List<String> parts = time.split(':');
    if (parts.length < 2) return null;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    return hour == null || minute == null ? null : hour * 60 + minute;
  }
}
