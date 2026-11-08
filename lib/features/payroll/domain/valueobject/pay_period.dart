/// Payroll month a payslip belongs to.
///
/// Rules (same as the backend): month between 1 and 12 and year 2000 or later. That the period is
/// not a future month is required only when a period is created with [PayPeriod.create]; it is not
/// required when the period is rebuilt from server data, because the clock of the phone may differ.
class PayPeriod {
  /// Creates the period; throws [ArgumentError] when the month or the year is not valid.
  PayPeriod({required this.year, required this.month}) {
    if (month < 1 || month > 12) {
      throw ArgumentError('El mes debe estar entre 1 y 12.');
    }
    if (year < minYear) {
      throw ArgumentError('El año debe ser $minYear o posterior.');
    }
  }

  /// Creates a new period; besides the basic rules it cannot be a future month.
  factory PayPeriod.create({required int year, required int month, DateTime? today}) {
    final PayPeriod period = PayPeriod(year: year, month: month);
    final DateTime now = today ?? DateTime.now();
    if (year > now.year || (year == now.year && month > now.month)) {
      throw ArgumentError('El período no puede ser futuro.');
    }
    return period;
  }

  /// First year accepted by the backend.
  static const int minYear = 2000;

  static const List<String> _monthNames = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  final int year;
  final int month;

  /// Readable name of the period, for example "Septiembre 2026".
  String get label {
    final String name = _monthNames[month - 1];
    return '${name[0].toUpperCase()}${name.substring(1)} $year';
  }

  /// Readable name in lower case, for example "septiembre 2026", to use inside a sentence.
  String get inlineLabel => '${_monthNames[month - 1]} $year';

  /// True when this period is after [other].
  bool isAfter(PayPeriod other) => year != other.year ? year > other.year : month > other.month;

  @override
  bool operator ==(Object other) => other is PayPeriod && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}
