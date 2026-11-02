/// Body to move an employee to another area and position.
class AssignJobRequestDto {
  /// Creates the DTO.
  const AssignJobRequestDto({required this.areaId, required this.positionId, required this.effectiveDate});

  final int areaId;
  final int positionId;
  final String effectiveDate;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'areaId': areaId,
        'positionId': positionId,
        'effectiveDate': effectiveDate,
      };
}
