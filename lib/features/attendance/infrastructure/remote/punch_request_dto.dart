class PunchRequestDto {
  const PunchRequestDto(this.data);

  final Map<String, dynamic> data;

  factory PunchRequestDto.fromJson(Map<String, dynamic> json) =>
      PunchRequestDto(json);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);

  dynamic get employeeId => data['employeeId'];
  dynamic get type => data['type'];
  dynamic get punchedAt => data['punchedAt'];