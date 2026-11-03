class EmployeeSummaryDto {
  const EmployeeSummaryDto(this.data);

  final Map<String, dynamic> data;

  factory EmployeeSummaryDto.fromJson(Map<String, dynamic> json) =>
      EmployeeSummaryDto(json);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);

  dynamic get id => data['id'];
  dynamic get name => data['name'];
}