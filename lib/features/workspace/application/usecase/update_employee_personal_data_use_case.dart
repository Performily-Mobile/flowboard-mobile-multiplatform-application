import 'package:flowboard/core/domain/email_address.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';
import 'package:flowboard/features/workspace/domain/valueobject/address.dart';
import 'package:flowboard/features/workspace/domain/valueobject/birth_date.dart';
import 'package:flowboard/features/workspace/domain/valueobject/person_name.dart';
import 'package:flowboard/features/workspace/domain/valueobject/phone_number.dart';

/// Updates the personal data of an employee.
class UpdateEmployeePersonalDataUseCase {
  /// Creates the use case.
  const UpdateEmployeePersonalDataUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Saves the new personal data and address of [id].
  Future<Employee> execute({
    required EmployeeId id,
    required PersonName name,
    required BirthDate birthDate,
    required EmailAddress email,
    required PhoneNumber phoneNumber,
    required Address address,
  }) {
    return repository.updatePersonalData(
      id: id,
      name: name,
      birthDate: birthDate,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
    );
  }
}
