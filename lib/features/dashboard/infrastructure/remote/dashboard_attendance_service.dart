import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_attendance_summary_dto.dart';

/// Attendance summary per area, read from the Attendance backend.
class DashboardAttendanceService {
  /// Creates the service.
  const DashboardAttendanceService({required this.client});

  final ApiClient client;

  /// GET attendance/reports/areas/{areaId}; [fromDate] and [toDate] are ISO dates.
  Future<DashboardAttendanceSummaryDto> getAreaSummary(int areaId, String fromDate, String toDate) async {
    final dynamic json = await client.get(
      'attendance/reports/areas/$areaId',
      query: <String, dynamic>{'from': fromDate, 'to': toDate},
    );
    return DashboardAttendanceSummaryDto.fromJson(json as Map<String, dynamic>);
  }
}
