import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_area_summary_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_hours_summary_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_page_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_record_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/justify_attendance_request_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/punch_request_dto.dart';

/// Endpoints of the attendance records.
///
/// Dates are sent as "yyyy-MM-dd".
class AttendanceService {
  /// Creates the service.
  const AttendanceService({required this.client});

  final ApiClient client;

  /// GET attendance/me?from=&to=.
  Future<List<AttendanceRecordDto>> getMyRecords(String from, String to) async {
    return _records(await client.get('attendance/me', query: <String, dynamic>{'from': from, 'to': to}));
  }

  /// GET attendance/employees/{employeeId}?from=&to=.
  Future<List<AttendanceRecordDto>> getEmployeeRecords(int employeeId, String from, String to) async {
    return _records(
      await client.get('attendance/employees/$employeeId', query: <String, dynamic>{'from': from, 'to': to}),
    );
  }

  /// GET attendance/records?from=&to=&status=&page=&size=.
  Future<AttendancePageDto> getRecords({
    required String from,
    required String to,
    String? status,
    required int page,
    required int size,
  }) async {
    final dynamic json = await client.get(
      'attendance/records',
      query: <String, dynamic>{'from': from, 'to': to, 'status': status, 'page': page, 'size': size},
    );
    return AttendancePageDto.fromJson(json as Map<String, dynamic>);
  }

  /// GET attendance/areas/{areaId}/records?from=&to=.
  Future<List<AttendanceRecordDto>> getAreaRecords(int areaId, String from, String to) async {
    return _records(
      await client.get('attendance/areas/$areaId/records', query: <String, dynamic>{'from': from, 'to': to}),
    );
  }

  /// GET attendance/reports/areas/{areaId}?from=&to=.
  Future<AttendanceAreaSummaryDto> getAreaSummary(int areaId, String from, String to) async {
    final dynamic json =
        await client.get('attendance/reports/areas/$areaId', query: <String, dynamic>{'from': from, 'to': to});
    return AttendanceAreaSummaryDto.fromJson(json as Map<String, dynamic>);
  }

  /// GET attendance/reports/employees/{employeeId}/hours?from=&to=.
  Future<AttendanceHoursSummaryDto> getEmployeeHours(int employeeId, String from, String to) async {
    final dynamic json = await client.get(
      'attendance/reports/employees/$employeeId/hours',
      query: <String, dynamic>{'from': from, 'to': to},
    );
    return AttendanceHoursSummaryDto.fromJson(json as Map<String, dynamic>);
  }

  /// POST attendance/punches; returns the identifier of the record.
  Future<int> registerPunch(PunchRequestDto request) async {
    final dynamic json = await client.post('attendance/punches', body: request.toJson());
    return json is num ? json.toInt() : int.parse('$json');
  }

  /// POST attendance/{attendanceRecordId}/justification.
  Future<AttendanceRecordDto> justify(int recordId, JustifyAttendanceRequestDto request) async {
    final dynamic json = await client.post('attendance/$recordId/justification', body: request.toJson());
    return AttendanceRecordDto.fromJson(json as Map<String, dynamic>);
  }

  List<AttendanceRecordDto> _records(dynamic json) {
    return (json as List<dynamic>)
        .map((dynamic item) => AttendanceRecordDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
