/// Body to set the direct manager of an employee.
class AssignDirectManagerRequestDto {
  /// Creates the DTO.
  const AssignDirectManagerRequestDto({required this.managerId});

  final int managerId;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{'managerId': managerId};
}
