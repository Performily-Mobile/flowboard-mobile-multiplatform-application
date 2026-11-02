/// Employee as returned by the API.
class EmployeeDto {
  /// Creates the DTO.
  const EmployeeDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
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
    required this.status,
    required this.terminationReason,
    required this.terminationDate,
    required this.areaId,
    required this.areaName,
    required this.positionId,
    required this.positionTitle,
    required this.directManagerId,
    required this.updatedAt,
  });

  /// Reads the DTO from its JSON.
  factory EmployeeDto.fromJson(Map<String, dynamic> json) {
    return EmployeeDto(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String?,
      identityDocumentType: json['identityDocumentType'] as String,
      identityDocumentNumber: json['identityDocumentNumber'] as String,
      birthDate: json['birthDate'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      street: json['street'] as String?,
      district: json['district'] as String?,
      province: json['province'] as String?,
      department: json['department'] as String?,
      contractType: json['contractType'] as String,
      hireDate: json['hireDate'] as String,
      contractEndDate: json['contractEndDate'] as String?,
      status: json['status'] as String,
      terminationReason: json['terminationReason'] as String?,
      terminationDate: json['terminationDate'] as String?,
      areaId: (json['areaId'] as num).toInt(),
      areaName: json['areaName'] as String?,
      positionId: (json['positionId'] as num).toInt(),
      positionTitle: json['positionTitle'] as String?,
      directManagerId: (json['directManagerId'] as num?)?.toInt(),
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final int id;
  final String firstName;
  final String lastName;
  final String? fullName;
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
  final String status;
  final String? terminationReason;
  final String? terminationDate;
  final int areaId;
  final String? areaName;
  final int positionId;
  final String? positionTitle;
  final int? directManagerId;
  final String? updatedAt;
}
