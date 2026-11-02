import 'package:flowboard/core/domain/email_address.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/entity/job_assignment.dart';
import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';
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
import 'package:flowboard/features/workspace/infrastructure/mapper/employee_document_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/employee_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/job_assignment_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/organization_chart_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/workspace_enum_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/assign_direct_manager_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_document_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_document_service.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_job_assignment_service.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_service.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/job_assignment_dto.dart';

/// Employees, job history, documents and organization chart read from and written to the API.
class EmployeeRepositoryImpl implements EmployeeRepository {
  /// Creates the repository.
  const EmployeeRepositoryImpl({
    required this.employeeService,
    required this.jobAssignmentService,
    required this.documentService,
  });

  final EmployeeService employeeService;
  final EmployeeJobAssignmentService jobAssignmentService;
  final EmployeeDocumentService documentService;

  @override
  Future<List<Employee>> getEmployees({String? search, int? areaId, EmploymentStatus? status, int? positionId}) async {
    final List<EmployeeDto> dtos = await employeeService.getEmployees(
      search,
      areaId,
      status == null ? null : WorkspaceEnumMapper.toApi(status),
      positionId,
    );
    return dtos.map(EmployeeMapper.toDomain).toList();
  }

  @override
  Future<Employee> getEmployeeById(EmployeeId id) async {
    return EmployeeMapper.toDomain(await employeeService.getEmployeeById(id.value));
  }

  @override
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
  }) async {
    final EmployeeDto dto = await employeeService.registerEmployee(
      EmployeeMapper.toRegisterRequest(
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
      ),
    );
    return EmployeeMapper.toDomain(dto);
  }

  @override
  Future<Employee> updatePersonalData({
    required EmployeeId id,
    required PersonName name,
    required BirthDate birthDate,
    required EmailAddress email,
    required PhoneNumber phoneNumber,
    required Address address,
  }) async {
    final EmployeeDto dto = await employeeService.updatePersonalData(
      id.value,
      EmployeeMapper.toUpdatePersonalDataRequest(
        name: name,
        birthDate: birthDate,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
      ),
    );
    return EmployeeMapper.toDomain(dto);
  }

  @override
  Future<JobAssignment> assignJob(EmployeeId id, int areaId, int positionId, DateTime effectiveDate) async {
    final JobAssignmentDto dto = await jobAssignmentService.assignJob(
      id.value,
      JobAssignmentMapper.toAssignRequest(areaId, positionId, effectiveDate),
    );
    return JobAssignmentMapper.toDomain(dto);
  }

  @override
  Future<Employee> assignDirectManager(EmployeeId id, EmployeeId managerId) async {
    final EmployeeDto dto = await employeeService.assignDirectManager(
      id.value,
      AssignDirectManagerRequestDto(managerId: managerId.value),
    );
    return EmployeeMapper.toDomain(dto);
  }

  @override
  Future<Employee> removeDirectManager(EmployeeId id) async {
    return EmployeeMapper.toDomain(await employeeService.removeDirectManager(id.value));
  }

  @override
  Future<List<Employee>> getSubordinates(EmployeeId id) async {
    final List<EmployeeDto> dtos = await employeeService.getSubordinates(id.value);
    return dtos.map(EmployeeMapper.toDomain).toList();
  }

  @override
  Future<Employee> terminate(EmployeeId id, TerminationDetails termination) async {
    final EmployeeDto dto = await employeeService.terminate(id.value, EmployeeMapper.toTerminateRequest(termination));
    return EmployeeMapper.toDomain(dto);
  }

  @override
  Future<Employee> reinstate(EmployeeId id, int areaId, int positionId, DateTime reinstatementDate) async {
    final EmployeeDto dto = await employeeService.reinstate(
      id.value,
      EmployeeMapper.toReinstateRequest(areaId, positionId, reinstatementDate),
    );
    return EmployeeMapper.toDomain(dto);
  }

  @override
  Future<List<JobAssignment>> getJobAssignments(EmployeeId employeeId) async {
    final List<JobAssignmentDto> dtos = await jobAssignmentService.getJobAssignments(employeeId.value);
    return dtos.map(JobAssignmentMapper.toDomain).toList();
  }

  @override
  Future<List<EmployeeDocument>> getDocuments(EmployeeId employeeId) async {
    final List<EmployeeDocumentDto> dtos = await documentService.getDocuments(employeeId.value);
    return dtos.map(EmployeeDocumentMapper.toDomain).toList();
  }

  @override
  Future<EmployeeDocument> attachDocument(EmployeeId employeeId, DocumentType documentType, FileReference file) async {
    final EmployeeDocumentDto dto = await documentService.attachDocument(
      employeeId.value,
      EmployeeDocumentMapper.toAttachRequest(documentType, file),
    );
    return EmployeeDocumentMapper.toDomain(dto);
  }

  @override
  Future<OrganizationChart> getOrganizationChart(int? areaId) async {
    return OrganizationChartMapper.toDomain(await employeeService.getOrganizationChart(areaId));
  }
}
