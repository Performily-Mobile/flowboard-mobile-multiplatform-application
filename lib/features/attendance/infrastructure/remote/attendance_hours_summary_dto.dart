class AttendanceHoursSummaryDto {
  const AttendanceHoursSummaryDto(this.data);

  final Map<String, dynamic> data;

  factory AttendanceHoursSummaryDto.fromJson(Map<String, dynamic> json) =>
      AttendanceHoursSummaryDto(json);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);

  dynamic get employeeId => data['employeeId'];
  dynamic get effectiveHours => data['effectiveHours'];
  dynamic get overtimeHours => data['overtimeHours'];
}