import 'package:flowboard/features/workspace/infrastructure/remote/organization_chart_node_dto.dart';

/// Organization chart as returned by the API.
class OrganizationChartDto {
  /// Creates the DTO.
  const OrganizationChartDto({required this.nodes, required this.pendingReassignment});

  /// Reads the DTO from its JSON.
  factory OrganizationChartDto.fromJson(Map<String, dynamic> json) {
    return OrganizationChartDto(
      nodes: _nodes(json['nodes']),
      pendingReassignment: _nodes(json['pendingReassignment']),
    );
  }

  static List<OrganizationChartNodeDto>? _nodes(dynamic raw) => (raw as List<dynamic>?)
      ?.map((dynamic node) => OrganizationChartNodeDto.fromJson(node as Map<String, dynamic>))
      .toList();

  final List<OrganizationChartNodeDto>? nodes;
  final List<OrganizationChartNodeDto>? pendingReassignment;
}
