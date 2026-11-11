import 'package:flowboard/features/dashboard/domain/entity/dashboard_sources.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_attendance_summary_dto.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/valueobject/approver_type.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';

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
  /// A request that goes to HR is one whose requester has no direct manager.
  static RequestToAttend toRequestToAttend(Request request) {
    final RequestPeriod? period = request.period;
    return RequestToAttend(
      requestId: request.id,
      requesterName: request.requesterName,
      requestTypeName: request.requestTypeName,
      startDate: period?.startDate,
      endDate: period?.endDate,
      hours: period != null && period.hasHours ? period.hours : null,
      withoutDirectManager: request.approverType == ApproverType.hrStaff,
    );
  }

  /// Text yyyy-MM-dd of [date], as the backend expects it.
  static String formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }
}
