/// Employee shown next to the attendance records.
class AttendanceEmployee {
  /// Creates the employee.
  const AttendanceEmployee({
    required this.id,
    required this.name,
    required this.areaId,
    required this.areaName,
    required this.positionTitle,
    required this.isActive,
  });

  final int id;
  final String name;
  final int areaId;
  final String areaName;
  final String positionTitle;
  final bool isActive;
}
