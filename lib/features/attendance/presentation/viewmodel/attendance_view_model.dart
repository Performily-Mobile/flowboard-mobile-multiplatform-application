import 'package:flutter/foundation.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class AttendanceViewModel extends ChangeNotifier {
  AttendanceViewModel({
    required this.repository,
    required this.employeeProvider,
  });

  final AttendanceRepository repository;
  final CurrentEmployeeProvider employeeProvider;
  bool loading = false;
  String? error;
  List<AttendanceRecord> records = [];

  DateTime from = DateTime(DateTime.now().year, DateTime.now().month, 1),
      to = DateTime.now();

  int get employeeId => employeeProvider.currentEmployeeId().value;

  Future<void> load({int? employeeId, int? areaId}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      records = areaId != null
          ? await repository.areaRecords(areaId, to)
          : employeeId != null
              ? await repository.employeeRecords(employeeId, from, to)
              : await repository.myRecords(this.employeeId, from, to);
    } catch (e) {
      error = e.toString();
      records = [];
    }
    loading = false;
    notifyListeners();
  }

  Future<void> setDates(DateTime start, DateTime end,
      {int? employeeId, int? areaId}) async {
    from = start;
    to = end;
    await load(employeeId: employeeId, areaId: areaId);
  }

  Future<void> punch(String type) async {
    await repository.punch(employeeId, type);
    await load();
  }

  Future<void> justify(int recordId, String reason, String? url) async {
    await repository.justify(recordId, reason, url);
    await load();
  }
}