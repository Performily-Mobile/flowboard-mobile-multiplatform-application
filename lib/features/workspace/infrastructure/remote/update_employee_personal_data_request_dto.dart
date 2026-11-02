/// Body to update the personal data of an employee.
class UpdateEmployeePersonalDataRequestDto {
  /// Creates the DTO.
  const UpdateEmployeePersonalDataRequestDto({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.phoneNumber,
    required this.street,
    required this.district,
    required this.province,
    required this.department,
  });

  final String firstName;
  final String lastName;
  final String birthDate;
  final String email;
  final String phoneNumber;
  final String? street;
  final String? district;
  final String? province;
  final String? department;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate,
        'email': email,
        'phoneNumber': phoneNumber,
        'street': street,
        'district': district,
        'province': province,
        'department': department,
      };
}
