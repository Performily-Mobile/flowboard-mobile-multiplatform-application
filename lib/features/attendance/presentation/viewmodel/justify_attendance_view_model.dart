import 'package:flutter/foundation.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class JustifyAttendanceViewModel extends ChangeNotifier {
  JustifyAttendanceViewModel(this.repository);

  final AttendanceRepository repository;
  bool loading = false;
  String? error;
  AttendanceRecord? updated;

  Future<bool> submit(int id, String reason, String? evidenceUrl) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      updated = await repository.justify(id, reason, evidenceUrl);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}