import 'package:flowboard/core/domain/email_address.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';
import 'package:flowboard/features/workspace/domain/valueobject/address.dart';
import 'package:flowboard/features/workspace/domain/valueobject/birth_date.dart';
import 'package:flowboard/features/workspace/domain/valueobject/contract_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_period.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document.dart';
import 'package:flowboard/features/workspace/domain/valueobject/person_name.dart';
import 'package:flowboard/features/workspace/domain/valueobject/phone_number.dart';

/// Registers a new employee.
class RegisterEmployeeUseCase {
  /// Creates the use case.
  const RegisterEmployeeUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Registers the employee with its personal data, contract and assignment.
  Future<Employee> execute({
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
    return repository.registerEmployee(
      name: name,
      identityDocument: identityDocument,
      birthDate: birthDate,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      contractType: contractType,
      employmentPeriod: employmentPeriod,
      areaId: areaId,
      positionId: positionId,
      directManagerId: directManagerId,
    );
  }
}
