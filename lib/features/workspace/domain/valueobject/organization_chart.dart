import 'package:flowboard/features/workspace/domain/valueobject/organization_chart_node.dart';

/// Organization chart: the hierarchy of active employees and those waiting for a new manager.
class OrganizationChart {
  /// Creates the chart.
  const OrganizationChart({required this.nodes, required this.pendingReassignment});

  final List<OrganizationChartNode> nodes;
  final List<OrganizationChartNode> pendingReassignment;

  /// True when there is nobody to show.
  bool get isEmpty => nodes.isEmpty && pendingReassignment.isEmpty;
}
