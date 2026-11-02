import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/valueobject/organization_chart.dart';
import 'package:flowboard/features/workspace/domain/valueobject/organization_chart_node.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/organization_chart_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/organization_chart_node_dto.dart';

/// Translates the organization chart between the API and the domain.
class OrganizationChartMapper {
  const OrganizationChartMapper._();

  /// Domain chart of [dto].
  static OrganizationChart toDomain(OrganizationChartDto dto) {
    return OrganizationChart(
      nodes: (dto.nodes ?? const <OrganizationChartNodeDto>[]).map(_toNode).toList(),
      pendingReassignment: (dto.pendingReassignment ?? const <OrganizationChartNodeDto>[]).map(_toNode).toList(),
    );
  }

  static OrganizationChartNode _toNode(OrganizationChartNodeDto dto) {
    return OrganizationChartNode(
      employeeId: EmployeeId(dto.employeeId),
      fullName: dto.fullName,
      positionTitle: dto.positionTitle ?? '',
      areaName: dto.areaName ?? '',
      subordinates: (dto.subordinates ?? const <OrganizationChartNodeDto>[]).map(_toNode).toList(),
    );
  }
}
