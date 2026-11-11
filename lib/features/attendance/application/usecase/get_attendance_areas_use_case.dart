import 'package:flowboard/features/attendance/domain/entity/attendance_area.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_directory.dart';

/// Gets the active areas of the company, sorted by name.
class GetAttendanceAreasUseCase {
  /// Creates the use case.
  const GetAttendanceAreasUseCase({required this.directory});

  final AttendanceDirectory directory;

  /// Active areas.
  Future<List<AttendanceArea>> execute() => directory.getAreas();
}
