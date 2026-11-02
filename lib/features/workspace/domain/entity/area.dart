/// Area of the organization.
class Area {
  /// Creates the area.
  const Area({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
    required this.activeEmployees,
  });

  final int id;
  final String name;
  final String? description;
  final bool active;
  final int activeEmployees;

  /// An area can be deactivated only when it is active and has no active employees.
  bool get canBeDeactivated => active && activeEmployees == 0;

  @override
  bool operator ==(Object other) => other is Area && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
