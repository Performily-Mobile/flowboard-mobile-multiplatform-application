/// Body to bring a terminated employee back.
class ReinstateEmployeeRequestDto {
  /// Creates the DTO.
  const ReinstateEmployeeRequestDto({
    required this.areaId,
    required this.positionId,
    required this.reinstatementDate,
  });

  final int areaId;
  final int positionId;
  final String reinstatementDate;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'areaId': areaId,
        'positionId': positionId,
        'reinstatementDate': reinstatementDate,
      };
}
