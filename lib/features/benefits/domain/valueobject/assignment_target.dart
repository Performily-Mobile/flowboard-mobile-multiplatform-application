/// Who receives a benefit (MA-61): one employee or every active employee of an area.
sealed class AssignmentTarget {
  const AssignmentTarget();
}

/// The benefit is assigned to the employee [employeeId].
class EmployeeTarget extends AssignmentTarget {
  /// Creates the target.
  const EmployeeTarget(this.employeeId);

  final int employeeId;
}

/// The benefit is assigned to every active employee of the area [areaId].
class AreaTarget extends AssignmentTarget {
  /// Creates the target.
  const AreaTarget(this.areaId);

  final int areaId;
}
