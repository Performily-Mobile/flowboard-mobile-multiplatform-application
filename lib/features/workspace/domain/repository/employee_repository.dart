import 'package:flowboard/core/domain/email_address.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/entity/job_assignment.dart';
import 'package:flowboard/features/workspace/domain/valueobject/address.dart';
import 'package:flowboard/features/workspace/domain/valueobject/birth_date.dart';
import 'package:flowboard/features/workspace/domain/valueobject/contract_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_period.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document.dart';
import 'package:flowboard/features/workspace/domain/valueobject/organization_chart.dart';
import 'package:flowboard/features/workspace/domain/valueobject/person_name.dart';
import 'package:flowboard/features/workspace/domain/valueobject/phone_number.dart';
import 'package:flowboard/features/workspace/domain/valueobject/termination_details.dart';

/// Repository of the employees, their job history, documents and the organization chart.
abstract class EmployeeRepository {
  /// Employees that match the optional [search] text and filters.
  Future<List<Employee>> getEmployees({String? search, int? areaId, EmploymentStatus? status, int? positionId});

  /// Employee [id].
  Future<Employee> getEmployeeById(EmployeeId id);

  /// Registers a new employee.
  Future<Employee> registerEmployee({
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
  });

  /// Updates the personal data and address of the employee [id].
  Future<Employee> updatePersonalData({
    required EmployeeId id,
    required PersonName name,
    required BirthDate birthDate,
    required EmailAddress email,
    required PhoneNumber phoneNumber,
    required Address address,
  });

  /// Moves the employee [id] to another area and position from [effectiveDate].
  Future<JobAssignment> assignJob(EmployeeId id, int areaId, int positionId, DateTime effectiveDate);

  /// Sets [managerId] as the direct manager of the employee [id].
  Future<Employee> assignDirectManager(EmployeeId id, EmployeeId managerId);

  /// Removes the direct manager of the employee [id].
  Future<Employee> removeDirectManager(EmployeeId id);

  /// Direct reports of the employee [id].
  Future<List<Employee>> getSubordinates(EmployeeId id);

  /// Registers the termination of the employee [id].
  Future<Employee> terminate(EmployeeId id, TerminationDetails termination);

  /// Brings the employee [id] back with a new area and position.
  Future<Employee> reinstate(EmployeeId id, int areaId, int positionId, DateTime reinstatementDate);

  /// Job assignment history of the employee.
  Future<List<JobAssignment>> getJobAssignments(EmployeeId employeeId);

  /// Documents of the record of the employee.
  Future<List<EmployeeDocument>> getDocuments(EmployeeId employeeId);

  /// Registers a stored [file] of type [documentType] in the record of the employee.
  Future<EmployeeDocument> attachDocument(EmployeeId employeeId, DocumentType documentType, FileReference file);

  /// Organization chart of the area [areaId], or of the whole organization when it is null.
  Future<OrganizationChart> getOrganizationChart(int? areaId);
}
