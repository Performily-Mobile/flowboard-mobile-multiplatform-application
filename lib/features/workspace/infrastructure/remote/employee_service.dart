import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/assign_direct_manager_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/employee_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/organization_chart_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/register_employee_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/reinstate_employee_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/terminate_employee_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/update_employee_personal_data_request_dto.dart';

/// Endpoints of the employees.
class EmployeeService {
  /// Creates the service.
  const EmployeeService({required this.client});

  final ApiClient client;

  /// GET employees?search=&areaId=&status=&positionId=.
  Future<List<EmployeeDto>> getEmployees(String? search, int? areaId, String? status, int? positionId) async {
    final dynamic json = await client.get('employees', query: <String, dynamic>{
      'search': search,
      'areaId': areaId,
      'status': status,
      'positionId': positionId,
    });
    return _list(json);
  }

  /// GET employees/{employeeId}.
  Future<EmployeeDto> getEmployeeById(int employeeId) async {
    return _one(await client.get('employees/$employeeId'));
  }

  /// POST employees.
  Future<EmployeeDto> registerEmployee(RegisterEmployeeRequestDto request) async {
    return _one(await client.post('employees', body: request.toJson()));
  }

  /// PUT employees/{employeeId}.
  Future<EmployeeDto> updatePersonalData(int employeeId, UpdateEmployeePersonalDataRequestDto request) async {
    return _one(await client.put('employees/$employeeId', body: request.toJson()));
  }

  /// PUT employees/{employeeId}/direct-manager.
  Future<EmployeeDto> assignDirectManager(int employeeId, AssignDirectManagerRequestDto request) async {
    return _one(await client.put('employees/$employeeId/direct-manager', body: request.toJson()));
  }

  /// DELETE employees/{employeeId}/direct-manager.
  Future<EmployeeDto> removeDirectManager(int employeeId) async {
    return _one(await client.delete('employees/$employeeId/direct-manager'));
  }

  /// GET employees/{employeeId}/subordinates.
  Future<List<EmployeeDto>> getSubordinates(int employeeId) async {
    return _list(await client.get('employees/$employeeId/subordinates'));
  }

  /// PATCH employees/{employeeId}/terminate.
  Future<EmployeeDto> terminate(int employeeId, TerminateEmployeeRequestDto request) async {
    return _one(await client.patch('employees/$employeeId/terminate', body: request.toJson()));
  }

  /// PATCH employees/{employeeId}/reinstate.
  Future<EmployeeDto> reinstate(int employeeId, ReinstateEmployeeRequestDto request) async {
    return _one(await client.patch('employees/$employeeId/reinstate', body: request.toJson()));
  }

  /// GET employees/organization-chart?areaId=.
  Future<OrganizationChartDto> getOrganizationChart(int? areaId) async {
    final dynamic json = await client.get('employees/organization-chart', query: <String, dynamic>{'areaId': areaId});
    return OrganizationChartDto.fromJson(json as Map<String, dynamic>);
  }

  EmployeeDto _one(dynamic json) => EmployeeDto.fromJson(json as Map<String, dynamic>);

  List<EmployeeDto> _list(dynamic json) =>
      (json as List<dynamic>).map((dynamic item) => EmployeeDto.fromJson(item as Map<String, dynamic>)).toList();
}
