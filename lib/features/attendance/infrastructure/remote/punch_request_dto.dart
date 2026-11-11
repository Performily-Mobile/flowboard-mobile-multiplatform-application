/// Body of the punch request.
class PunchRequestDto {
  /// Creates the DTO.
  const PunchRequestDto({required this.employeeId, required this.type, required this.punchedAt});

  final int employeeId;

  /// API name of the punch, `CHECK_IN` or `CHECK_OUT`.
  final String type;

  /// Time sent for reference; the backend uses its own clock.
  final DateTime punchedAt;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'employeeId': employeeId,
        'type': type,
        'punchedAt': punchedAt.toIso8601String().split('.').first,
      };
}
