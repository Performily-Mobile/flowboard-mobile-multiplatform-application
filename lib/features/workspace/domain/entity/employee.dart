import 'package:flowboard/core/domain/email_address.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/valueobject/address.dart';
import 'package:flowboard/features/workspace/domain/valueobject/birth_date.dart';
import 'package:flowboard/features/workspace/domain/valueobject/contract_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_period.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document.dart';
import 'package:flowboard/features/workspace/domain/valueobject/person_name.dart';
import 'package:flowboard/features/workspace/domain/valueobject/phone_number.dart';
import 'package:flowboard/features/workspace/domain/valueobject/termination_details.dart';

/// Employee of the organization: aggregate root of the Workspace bounded context.
class Employee {
  /// Creates the employee.
  const Employee({
    required this.id,
    required this.name,
    required this.identityDocument,
    required this.birthDate,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.contractType,
    required this.employmentPeriod,
    required this.status,
    required this.termination,
    required this.areaId,
    required this.areaName,
    required this.positionId,
    required this.positionTitle,
    required this.directManagerId,
    required this.updatedAt,
  });

  final EmployeeId id;
  final PersonName name;
  final IdentityDocument identityDocument;
  final BirthDate birthDate;
  final EmailAddress email;
  final PhoneNumber phoneNumber;
  final Address address;
  final ContractType contractType;
  final EmploymentPeriod employmentPeriod;
  final EmploymentStatus status;
  final TerminationDetails? termination;
  final int areaId;
  final String areaName;
  final int positionId;
  final String positionTitle;
  final EmployeeId? directManagerId;
  final DateTime? updatedAt;

  /// True when the employee is active.
  bool get isActive => status == EmploymentStatus.active;

  /// True when the employee was terminated.
  bool get isTerminated => status == EmploymentStatus.terminated;

  /// True when the employee has a direct manager.
  bool get hasDirectManager => directManagerId != null;

  /// True when [managerId] is the direct manager of the employee.
  bool isManagedBy(EmployeeId managerId) => directManagerId == managerId;

  /// "Position · Area".
  String get jobDescription => '$positionTitle · $areaName';
}
