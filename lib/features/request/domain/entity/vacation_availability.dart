/// Vacation days an employee can still use.
class VacationAvailability {
  /// Creates the availability.
  const VacationAvailability({required this.employeeId, required this.availableDays});

  final int employeeId;
  final double availableDays;

  /// True when there are at least [days] available.
  bool isEnoughFor(int days) => availableDays >= days;

  /// Days left after using [days].
  double afterUsing(int days) => availableDays - days;
}
