/// Body to register an employee.
class RegisterEmployeeRequestDto {
  /// Creates the DTO.
  const RegisterEmployeeRequestDto({
    required this.firstName,
    required this.lastName,
    required this.identityDocumentType,
    required this.identityDocumentNumber,
    required this.birthDate,
    required this.email,
    required this.phoneNumber,
    required this.street,
    required this.district,
    required this.province,
    required this.department,
    required this.contractType,
    required this.hireDate,
    required this.contractEndDate,
    required this.areaId,
    required this.positionId,
    required this.directManagerId,
  });

  final String firstName;
  final String lastName;
  final String identityDocumentType;
  final String identityDocumentNumber;
  final String birthDate;
  final String email;
  final String phoneNumber;
  final String? street;
  final String? district;
  final String? province;
  final String? department;
  final String contractType;
  final String hireDate;
  final String? contractEndDate;
  final int areaId;
  final int positionId;
  final int? directManagerId;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'identityDocumentType': identityDocumentType,
        'identityDocumentNumber': identityDocumentNumber,
        'birthDate': birthDate,
        'email': email,
        'phoneNumber': phoneNumber,
        'street': street,
        'district': district,
        'province': province,
        'department': department,
        'contractType': contractType,
        'hireDate': hireDate,
        'contractEndDate': contractEndDate,
        'areaId': areaId,
        'positionId': positionId,
        'directManagerId': directManagerId,
      };
}
