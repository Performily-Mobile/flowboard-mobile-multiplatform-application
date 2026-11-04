import 'package:flutter/foundation.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class AttendanceHoursViewModel extends ChangeNotifier {
  AttendanceHoursViewModel(this.repository);

  final AttendanceRepository repository;
  bool loading = false;
  String? error;
  Map<String, dynamic> report = {};

  Future<void> load(int employeeId, DateTime from, DateTime to) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      report = await repository.employeeHours(employeeId, from, to);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}