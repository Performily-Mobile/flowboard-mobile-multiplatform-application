class AttendanceRecordDto {
  const AttendanceRecordDto(this.data);

  final Map<String, dynamic> data;

  factory AttendanceRecordDto.fromJson(Map<String, dynamic> json) =>
      AttendanceRecordDto(json);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);

  dynamic get id => data['id'];
  dynamic get employeeId => data['employeeId'];
  dynamic get workDate => data['workDate'];
  dynamic get status => data['status'];
}