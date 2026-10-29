/// Typed identifier of an employee.
class EmployeeId {
  /// Creates the identifier; throws [ArgumentError] when [value] is not positive.
  EmployeeId(this.value) {
    if (value <= 0) {
      throw ArgumentError('El identificador del colaborador debe ser positivo.');
    }
  }

  final int value;

  @override
  bool operator ==(Object other) => other is EmployeeId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EmployeeId($value)';
}
