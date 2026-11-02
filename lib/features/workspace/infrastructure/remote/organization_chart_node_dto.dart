/// Node of the organization chart as returned by the API.
class OrganizationChartNodeDto {
  /// Creates the DTO.
  const OrganizationChartNodeDto({
    required this.employeeId,
    required this.fullName,
    required this.positionTitle,
    required this.areaName,
    required this.subordinates,
  });

  /// Reads the DTO, with its subordinates, from its JSON.
  factory OrganizationChartNodeDto.fromJson(Map<String, dynamic> json) {
    return OrganizationChartNodeDto(
      employeeId: (json['employeeId'] as num).toInt(),
      fullName: json['fullName'] as String,
      positionTitle: json['positionTitle'] as String?,
      areaName: json['areaName'] as String?,
      subordinates: (json['subordinates'] as List<dynamic>?)
          ?.map((dynamic node) => OrganizationChartNodeDto.fromJson(node as Map<String, dynamic>))
          .toList(),
    );
  }

  final int employeeId;
  final String fullName;
  final String? positionTitle;
  final String? areaName;
  final List<OrganizationChartNodeDto>? subordinates;
}
