/// Body to register the termination of an employee.
class TerminateEmployeeRequestDto {
  /// Creates the DTO.
  const TerminateEmployeeRequestDto({required this.reason, required this.terminationDate});

  final String reason;
  final String terminationDate;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{'reason': reason, 'terminationDate': terminationDate};
}
