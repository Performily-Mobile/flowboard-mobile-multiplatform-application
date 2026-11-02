import 'package:flowboard/core/domain/employee_id.dart';

/// Employee of the organization chart with its direct reports.
class OrganizationChartNode {
  /// Creates the node.
  const OrganizationChartNode({
    required this.employeeId,
    required this.fullName,
    required this.positionTitle,
    required this.areaName,
    required this.subordinates,
  });

  final EmployeeId employeeId;
  final String fullName;
  final String positionTitle;
  final String areaName;
  final List<OrganizationChartNode> subordinates;

  /// First letters of the first two words of the name.
  String get initials => fullName
      .split(' ')
      .where((String word) => word.trim().isNotEmpty)
      .take(2)
      .map((String word) => String.fromCharCode(word.trim().runes.first).toUpperCase())
      .join();
}
