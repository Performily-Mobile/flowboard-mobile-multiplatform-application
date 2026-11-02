import 'package:flowboard/features/dashboard/domain/entity/dashboard_sources.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';

/// Data the dashboard takes from other bounded contexts.
///
/// The dashboard owns no data of its own: it only reads and summarizes. Every method throws when
/// its source fails, and the use case decides what to do with each failure.
abstract class HrDashboardRepository {
  /// First name of the signed-in user.
  Future<String> getCurrentUserFirstName();

  /// Active areas with their number of active employees.
  Future<List<DashboardArea>> getActiveAreas();

  /// Attendance counts of an area from [from] to [to], both inclusive.
  Future<AttendanceSummary> getAttendanceSummary(int areaId, DateTime from, DateTime to);

  /// Requests pending in the HR inbox, oldest first.
  Future<List<RequestToAttend>> getRequestsToAttend();

  /// Available vacation days of every active employee.
  Future<List<double>> getAvailableVacationDays();
}
