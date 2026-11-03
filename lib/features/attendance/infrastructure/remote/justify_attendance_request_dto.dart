class JustifyAttendanceRequestDto {
  const JustifyAttendanceRequestDto(this.data);

  final Map<String, dynamic> data;

  factory JustifyAttendanceRequestDto.fromJson(Map<String, dynamic> json) =>
      JustifyAttendanceRequestDto(json);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);

  dynamic get reason => data['reason'];
  dynamic get evidenceUrl => data['evidenceUrl'];
}