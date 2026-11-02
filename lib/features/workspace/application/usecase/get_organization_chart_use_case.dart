import 'package:flowboard/features/workspace/domain/repository/employee_repository.dart';
import 'package:flowboard/features/workspace/domain/valueobject/organization_chart.dart';

/// Gets the organization chart.
class GetOrganizationChartUseCase {
  /// Creates the use case.
  const GetOrganizationChartUseCase({required this.repository});

  final EmployeeRepository repository;

  /// Chart of [areaId], or of the whole organization when it is null.
  Future<OrganizationChart> execute({int? areaId}) => repository.getOrganizationChart(areaId);
}
