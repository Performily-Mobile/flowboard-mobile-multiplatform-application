import 'package:flutter/foundation.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class AttendanceHomeViewModel extends ChangeNotifier {
  AttendanceHomeViewModel(this.repository);

  final AttendanceRepository repository;
  bool loading = false;
  String? error;
  List<AttendanceRecord> records = [];

  Future<void> load(int employeeId, DateTime from, DateTime to) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      records = await repository.myRecords(employeeId, from, to);
    } catch (e) {
      error = e.toString();
      records = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}