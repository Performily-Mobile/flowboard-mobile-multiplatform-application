import 'package:flowboard/features/attendance/domain/entity/attendance_area_summary.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_hours.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_page.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';
import 'package:flowboard/features/attendance/domain/valueobject/punch_type.dart';
import 'package:flowboard/features/attendance/infrastructure/mapper/attendance_mapper.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_record_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_service.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/justify_attendance_request_dto.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/punch_request_dto.dart';

/// [AttendanceRepository] backed by the attendance endpoints of the backend.
class AttendanceRepositoryImpl implements AttendanceRepository {
  /// Creates the repository.
  const AttendanceRepositoryImpl({required this.service});

  final AttendanceService service;

  @override
  Future<List<AttendanceRecord>> getMyRecords(AttendancePeriod period) async {
    return _records(await service.getMyRecords(_from(period), _to(period)));
  }

  @override
  Future<List<AttendanceRecord>> getEmployeeRecords(int employeeId, AttendancePeriod period) async {
    return _records(await service.getEmployeeRecords(employeeId, _from(period), _to(period)));
  }

  @override
  Future<AttendancePage> getRecords({
    required AttendancePeriod period,
    AttendanceStatus? status,
    required int page,
    required int size,
  }) async {
    return AttendanceMapper.toPage(await service.getRecords(
      from: _from(period),
      to: _to(period),
      status: status == null ? null : AttendanceMapper.statusToApi(status),
      page: page,
      size: size,
    ));
  }

  @override
  Future<List<AttendanceRecord>> getAreaRecords(int areaId, AttendancePeriod period) async {
    return _records(await service.getAreaRecords(areaId, _from(period), _to(period)));
  }

  @override
  Future<AttendanceAreaSummary> getAreaSummary(int areaId, AttendancePeriod period) async {
    return AttendanceMapper.toAreaSummary(await service.getAreaSummary(areaId, _from(period), _to(period)));
  }

  @override
  Future<AttendanceHours> getEmployeeHours(int employeeId, AttendancePeriod period) async {
    return AttendanceMapper.toHours(await service.getEmployeeHours(employeeId, _from(period), _to(period)));
  }

  @override
  Future<int> registerPunch({required int employeeId, required PunchType type}) {
    return service.registerPunch(PunchRequestDto(
      employeeId: employeeId,
      type: AttendanceMapper.punchTypeToApi(type),
      punchedAt: DateTime.now(),
    ));
  }

  @override
  Future<AttendanceRecord> justify({required int recordId, required String reason, String? evidenceUrl}) async {
    final AttendanceRecordDto dto =
        await service.justify(recordId, JustifyAttendanceRequestDto(reason: reason, evidenceUrl: evidenceUrl));
    return AttendanceMapper.toRecord(dto);
  }

  List<AttendanceRecord> _records(List<AttendanceRecordDto> dtos) => dtos.map(AttendanceMapper.toRecord).toList();

  String _from(AttendancePeriod period) => AttendanceMapper.toApiDate(period.from);

  String _to(AttendancePeriod period) => AttendanceMapper.toApiDate(period.to);
}
