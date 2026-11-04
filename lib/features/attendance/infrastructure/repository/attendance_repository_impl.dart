import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/infrastructure/mapper/attendance_mapper.dart';
import 'package:flowboard/features/attendance/infrastructure/remote/attendance_service.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl({required this.service});

  final AttendanceService service;

  List<AttendanceRecord> _records(List<dynamic> items) => items
      .map(
        (dynamic e) => AttendanceMapper.fromJson(e as Map<String, dynamic>),
      )
      .toList();

  @override
  Future<List<AttendanceRecord>> myRecords(
    int id,
    DateTime from,
    DateTime to,
  ) async =>
      _records(await service.myRecords(id, from, to));

  @override
  Future<List<AttendanceRecord>> employeeRecords(
    int id,
    DateTime from,
    DateTime to,
  ) async =>
      _records(await service.employeeRecords(id, from, to));

  @override
  Future<List<AttendanceRecord>> areaRecords(
    int id,
    DateTime day,
  ) async =>
      _records(await service.areaRecords(id, day));

  @override
  Future<Map<String, dynamic>> employeeHours(
    int id,
    DateTime from,
    DateTime to,
  ) =>
      service.employeeHours(id, from, to);

  @override
  Future<Map<String, dynamic>> areaSummary(
    int id,
    DateTime from,
    DateTime to,
  ) =>
      service.areaSummary(id, from, to);

  @override
  Future<int> punch(int id, String type) => service.punch(id, type);

  @override
  Future<AttendanceRecord> justify(
    int id,
    String reason,
    String? url,
  ) async =>
      AttendanceMapper.fromJson(await service.justify(id, reason, url));

  @override
  Future<List<Map<String, dynamic>>> areas() async => (await service.areas())
      .map(
        (dynamic e) => e as Map<String, dynamic>,
      )
      .toList();

  @override
  Future<List<Map<String, dynamic>>> employees(String q) async =>
      (await service.employees(q))
          .map(
            (dynamic e) => e as Map<String, dynamic>,
          )
          .toList();
}