/// Area to which a benefit can be assigned. It comes from Workspace.
class AreaOption {
  /// Creates the option.
  const AreaOption({required this.id, required this.name, required this.activeEmployees});

  final int id;
  final String name;
  final int activeEmployees;

  @override
  bool operator ==(Object other) => other is AreaOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Active employee to whom a benefit can be assigned. It comes from Workspace.
class EmployeeOption {
  /// Creates the option.
  const EmployeeOption({required this.id, required this.name, required this.areaName});

  final int id;
  final String name;
  final String areaName;

  @override
  bool operator ==(Object other) => other is EmployeeOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
