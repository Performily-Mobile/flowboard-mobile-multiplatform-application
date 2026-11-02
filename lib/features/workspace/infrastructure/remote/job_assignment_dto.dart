/// Entry of the job history as returned by the API.
class JobAssignmentDto {
  /// Creates the DTO.
  const JobAssignmentDto({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.positionId,
    required this.positionTitle,
    required this.changeType,
    required this.startDate,
    required this.endDate,
    required this.current,
  });

  /// Reads the DTO from its JSON.
  factory JobAssignmentDto.fromJson(Map<String, dynamic> json) {
    return JobAssignmentDto(
      id: (json['id'] as num).toInt(),
      areaId: (json['areaId'] as num).toInt(),
      areaName: json['areaName'] as String?,
      positionId: (json['positionId'] as num).toInt(),
      positionTitle: json['positionTitle'] as String?,
      changeType: json['changeType'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
      current: json['current'] as bool,
    );
  }

  final int id;
  final int areaId;
  final String? areaName;
  final int positionId;
  final String? positionTitle;
  final String changeType;
  final String startDate;
  final String? endDate;
  final bool current;
}
