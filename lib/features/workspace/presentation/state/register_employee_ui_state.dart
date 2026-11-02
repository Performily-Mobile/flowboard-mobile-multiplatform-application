import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/valueobject/contract_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document_type.dart';

const Object _keep = Object();

DateTime _today() {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Fields of the registration form that can show an error.
enum RegisterField {
  firstName,
  lastName,
  documentNumber,
  birthDate,
  email,
  phone,
  hireDate,
  contractEndDate,
  area,
  position,
}

/// State of the two-step employee registration.
class RegisterEmployeeUiState {
  /// Creates the state; the hire date starts on today.
  RegisterEmployeeUiState({
    this.step = 1,
    this.firstName = '',
    this.lastName = '',
    this.documentType = IdentityDocumentType.dni,
    this.documentNumber = '',
    this.birthDate,
    this.email = '',
    this.phoneNumber = '',
    this.contractType = ContractType.indefinite,
    Object? hireDate = _keep,
    this.contractEndDate,
    this.areaId,
    this.positionId,
    this.directManagerId,
    this.areas = const <Area>[],
    this.positions = const <Position>[],
    this.managers = const <Employee>[],
    this.fieldErrors = const <RegisterField, String>{},
    this.isSubmitting = false,
    this.errorMessage,
    this.registeredEmployeeId,
  }) : hireDate = identical(hireDate, _keep) ? _today() : hireDate as DateTime?;

  final int step;
  final String firstName;
  final String lastName;
  final IdentityDocumentType documentType;
  final String documentNumber;
  final DateTime? birthDate;
  final String email;
  final String phoneNumber;
  final ContractType contractType;
  final DateTime? hireDate;
  final DateTime? contractEndDate;
  final int? areaId;
  final int? positionId;
  final EmployeeId? directManagerId;
  final List<Area> areas;
  final List<Position> positions;
  final List<Employee> managers;
  final Map<RegisterField, String> fieldErrors;
  final bool isSubmitting;
  final String? errorMessage;
  final int? registeredEmployeeId;

  /// Position chosen in the form, if any.
  Position? get selectedPosition {
    for (final Position position in positions) {
      if (position.id == positionId) return position;
    }
    return null;
  }

  /// Error of [field], if any.
  String? errorOf(RegisterField field) => fieldErrors[field];

  /// Copy with the given values replaced.
  RegisterEmployeeUiState copyWith({
    int? step,
    String? firstName,
    String? lastName,
    IdentityDocumentType? documentType,
    String? documentNumber,
    Object? birthDate = _keep,
    String? email,
    String? phoneNumber,
    ContractType? contractType,
    Object? hireDate = _keep,
    Object? contractEndDate = _keep,
    Object? areaId = _keep,
    Object? positionId = _keep,
    Object? directManagerId = _keep,
    List<Area>? areas,
    List<Position>? positions,
    List<Employee>? managers,
    Map<RegisterField, String>? fieldErrors,
    bool? isSubmitting,
    Object? errorMessage = _keep,
    Object? registeredEmployeeId = _keep,
  }) {
    return RegisterEmployeeUiState(
      step: step ?? this.step,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      birthDate: identical(birthDate, _keep) ? this.birthDate : birthDate as DateTime?,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contractType: contractType ?? this.contractType,
      hireDate: identical(hireDate, _keep) ? this.hireDate : hireDate,
      contractEndDate: identical(contractEndDate, _keep) ? this.contractEndDate : contractEndDate as DateTime?,
      areaId: identical(areaId, _keep) ? this.areaId : areaId as int?,
      positionId: identical(positionId, _keep) ? this.positionId : positionId as int?,
      directManagerId: identical(directManagerId, _keep) ? this.directManagerId : directManagerId as EmployeeId?,
      areas: areas ?? this.areas,
      positions: positions ?? this.positions,
      managers: managers ?? this.managers,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      registeredEmployeeId:
          identical(registeredEmployeeId, _keep) ? this.registeredEmployeeId : registeredEmployeeId as int?,
    );
  }
}
