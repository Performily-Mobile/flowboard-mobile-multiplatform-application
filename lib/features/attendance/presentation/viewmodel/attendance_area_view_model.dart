import 'package:flutter/foundation.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

class AttendanceAreaViewModel extends ChangeNotifier {
  AttendanceAreaViewModel(this.repository);

  final AttendanceRepository repository;
  bool loading = false;
  String? error;
  List<AttendanceRecord> records = [];

  Future<void> load(int areaId, DateTime day) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      records = await repository.areaRecords(areaId, day);
    } catch (e) {
      error = e.toString();
      records = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}