import 'package:flowboard/core/domain/email_address.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/valueobject/address.dart';
import 'package:flowboard/features/workspace/domain/valueobject/birth_date.dart';
import 'package:flowboard/features/workspace/domain/valueobject/contract_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_period.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/person_name.dart';
import 'package:flowboard/features/workspace/domain/valueobject/phone_number.dart';
import 'package:flowboard/features/workspace/domain/valueobject/termination_details.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/iso_date_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/workspace_enum_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/register_employee_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/reinstate_employee_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/terminate_employee_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/update_employee_personal_data_request_dto.dart';

/// Translates the employees between the API and the domain.
class EmployeeMapper {
  const EmployeeMapper._();

  /// Domain employee of [dto].
  static Employee toDomain(EmployeeDto dto) {
    final String? terminationReason = dto.terminationReason;
    final String? terminationDate = dto.terminationDate;
    return Employee(
      id: EmployeeId(dto.id),
      name: PersonName(dto.firstName, dto.lastName),
      identityDocument: IdentityDocument(
        WorkspaceEnumMapper.fromApi(IdentityDocumentType.values, dto.identityDocumentType),
        dto.identityDocumentNumber,
      ),
      birthDate: BirthDate(IsoDateMapper.parseDate(dto.birthDate)),
      email: EmailAddress(dto.email),
      phoneNumber: PhoneNumber.of(dto.phoneNumber),
      address: Address(
        street: dto.street,
        district: dto.district,
        province: dto.province,
        department: dto.department,
      ),
      contractType: WorkspaceEnumMapper.fromApi(ContractType.values, dto.contractType),
      employmentPeriod: EmploymentPeriod(
        hireDate: IsoDateMapper.parseDate(dto.hireDate),
        contractEndDate: dto.contractEndDate == null ? null : IsoDateMapper.parseDate(dto.contractEndDate!),
      ),
      status: WorkspaceEnumMapper.fromApi(EmploymentStatus.values, dto.status),
      termination: terminationReason != null && terminationDate != null
          ? TerminationDetails(reason: terminationReason, terminationDate: IsoDateMapper.parseDate(terminationDate))
          : null,
      areaId: dto.areaId,
      areaName: dto.areaName ?? '',
      positionId: dto.positionId,
      positionTitle: dto.positionTitle ?? '',
      directManagerId: dto.directManagerId == null ? null : EmployeeId(dto.directManagerId!),
      updatedAt: dto.updatedAt == null ? null : DateTime.tryParse(dto.updatedAt!),
    );
  }

  /// Body to register an employee.
  static RegisterEmployeeRequestDto toRegisterRequest({
    required PersonName name,
    required IdentityDocument identityDocument,
    required BirthDate birthDate,
    required EmailAddress email,
    required PhoneNumber phoneNumber,
    required Address address,
    required ContractType contractType,
    required EmploymentPeriod employmentPeriod,
    required int areaId,
    required int positionId,
    required EmployeeId? directManagerId,
  }) {
    return RegisterEmployeeRequestDto(
      firstName: name.firstName.trim(),
      lastName: name.lastName.trim(),
      identityDocumentType: WorkspaceEnumMapper.toApi(identityDocument.type),
      identityDocumentNumber: identityDocument.number,
      birthDate: IsoDateMapper.format(birthDate.value),
      email: email.value,
      phoneNumber: phoneNumber.value,
      street: _blankToNull(address.street),
      district: _blankToNull(address.district),
      province: _blankToNull(address.province),
      department: _blankToNull(address.department),
      contractType: WorkspaceEnumMapper.toApi(contractType),
      hireDate: IsoDateMapper.format(employmentPeriod.hireDate),
      contractEndDate:
          employmentPeriod.contractEndDate == null ? null : IsoDateMapper.format(employmentPeriod.contractEndDate!),
      areaId: areaId,
      positionId: positionId,
      directManagerId: directManagerId?.value,
    );
  }

  /// Body to update the personal data of an employee.
  static UpdateEmployeePersonalDataRequestDto toUpdatePersonalDataRequest({
    required PersonName name,
    required BirthDate birthDate,
    required EmailAddress email,
    required PhoneNumber phoneNumber,
    required Address address,
  }) {
    return UpdateEmployeePersonalDataRequestDto(
      firstName: name.firstName.trim(),
      lastName: name.lastName.trim(),
      birthDate: IsoDateMapper.format(birthDate.value),
      email: email.value,
      phoneNumber: phoneNumber.value,
      street: _blankToNull(address.street),
      district: _blankToNull(address.district),
      province: _blankToNull(address.province),
      department: _blankToNull(address.department),
    );
  }

  /// Body to register a termination.
  static TerminateEmployeeRequestDto toTerminateRequest(TerminationDetails termination) {
    return TerminateEmployeeRequestDto(
      reason: termination.reason.trim(),
      terminationDate: IsoDateMapper.format(termination.terminationDate),
    );
  }

  /// Body to reinstate an employee.
  static ReinstateEmployeeRequestDto toReinstateRequest(int areaId, int positionId, DateTime reinstatementDate) {
    return ReinstateEmployeeRequestDto(
      areaId: areaId,
      positionId: positionId,
      reinstatementDate: IsoDateMapper.format(reinstatementDate),
    );
  }

  static String? _blankToNull(String? value) => value == null || value.trim().isEmpty ? null : value;
}
