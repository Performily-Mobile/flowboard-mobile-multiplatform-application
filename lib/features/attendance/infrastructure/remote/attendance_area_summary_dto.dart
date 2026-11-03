class AttendanceAreaSummaryDto {
  const AttendanceAreaSummaryDto(this.data);

  final Map<String, dynamic> data;

  factory AttendanceAreaSummaryDto.fromJson(Map<String, dynamic> json) =>
      AttendanceAreaSummaryDto(json);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);

  dynamic get areaId => data['areaId'];
  dynamic get total => data['total'];
  dynamic get late => data['late'];
  dynamic get absent => data['absent'];
}