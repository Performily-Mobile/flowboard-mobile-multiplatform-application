/// Body of the justification request.
class JustifyAttendanceRequestDto {
  /// Creates the DTO.
  const JustifyAttendanceRequestDto({required this.reason, this.evidenceUrl});

  final String reason;
  final String? evidenceUrl;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{'reason': reason, 'evidenceUrl': evidenceUrl};
}
