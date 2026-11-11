/// Hours of an employee as returned by the API.
class AttendanceHoursSummaryDto {
  /// Creates the DTO.
  const AttendanceHoursSummaryDto({required this.employeeId, required this.workedHours, required this.overtimeHours});

  /// Reads the DTO from its JSON.
  factory AttendanceHoursSummaryDto.fromJson(Map<String, dynamic> json) {
    return AttendanceHoursSummaryDto(
      employeeId: (json['employeeId'] as num).toInt(),
      workedHours: (json['workedHours'] as num?)?.toDouble() ?? 0,
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0,
    );
  }

  final int employeeId;
  final double workedHours;
  final double overtimeHours;
}
