/// Attendance record as returned by the API.
class AttendanceRecordDto {
  /// Creates the DTO.
  const AttendanceRecordDto({
    required this.id,
    required this.employeeId,
    required this.workDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.workedHours,
    required this.overtimeHours,
    required this.status,
    required this.justificationReason,
  });

  /// Reads the DTO from its JSON.
  factory AttendanceRecordDto.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordDto(
      id: (json['id'] as num?)?.toInt(),
      employeeId: (json['employeeId'] as num).toInt(),
      workDate: json['workDate'] as String,
      checkInTime: json['checkInTime'] as String?,
      checkOutTime: json['checkOutTime'] as String?,
      workedHours: (json['workedHours'] as num?)?.toDouble() ?? 0,
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'INCOMPLETE',
      justificationReason: json['justificationReason'] as String?,
    );
  }

  final int? id;
  final int employeeId;

  /// Day as "yyyy-MM-dd".
  final String workDate;

  /// Times as "yyyy-MM-ddTHH:mm:ss" in the time of Lima.
  final String? checkInTime;
  final String? checkOutTime;
  final double workedHours;
  final double overtimeHours;
  final String status;
  final String? justificationReason;
}
