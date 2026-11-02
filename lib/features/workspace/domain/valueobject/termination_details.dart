/// Reason and date of the termination of an employee.
class TerminationDetails {
  /// Creates the details; throws [ArgumentError] when the reason is blank or longer than 500
  /// characters.
  TerminationDetails({required this.reason, required this.terminationDate}) {
    if (reason.trim().isEmpty) throw ArgumentError('El motivo de cese es obligatorio.');
    if (reason.length > 500) throw ArgumentError('El motivo admite hasta 500 caracteres.');
  }

  final String reason;
  final DateTime terminationDate;
}
