import 'package:flowboard/features/request/domain/valueobject/request_time.dart';

/// Dates covered by a request, with an optional range of hours for a single day.
class RequestPeriod {
  /// Creates the period; throws [ArgumentError] when the end is before the start, when only one
  /// of the times is given, or when an hourly period spans more than one day.
  RequestPeriod({
    required DateTime startDate,
    required DateTime endDate,
    this.startTime,
    this.endTime,
  })  : startDate = _dateOnly(startDate),
        endDate = _dateOnly(endDate) {
    if (this.endDate.isBefore(this.startDate)) {
      throw ArgumentError('La fecha de fin no puede ser anterior a la de inicio.');
    }
    if ((startTime == null) != (endTime == null)) {
      throw ArgumentError('Indica la hora de inicio y la de fin.');
    }
    final RequestTime? start = startTime;
    final RequestTime? end = endTime;
    if (start != null && end != null) {
      if (!isSameDay(this.startDate, this.endDate)) {
        throw ArgumentError('Un permiso por horas debe empezar y terminar el mismo día.');
      }
      if (!end.isAfter(start)) {
        throw ArgumentError('La hora de fin debe ser posterior a la de inicio.');
      }
    }
  }

  final DateTime startDate;
  final DateTime endDate;
  final RequestTime? startTime;
  final RequestTime? endTime;

  /// True when the period is a range of hours.
  bool get hasHours => startTime != null;

  /// True when the period starts and ends on the same day.
  bool get isSingleDay => isSameDay(startDate, endDate);

  /// Whole days covered, both ends included; 0 for an hourly period.
  int get days {
    if (hasHours) return 0;
    final DateTime start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final DateTime end = DateTime.utc(endDate.year, endDate.month, endDate.day);
    return end.difference(start).inDays + 1;
  }

  /// Hours covered by an hourly period; 0 otherwise.
  double get hours {
    final RequestTime? start = startTime;
    final RequestTime? end = endTime;
    if (start == null || end == null) return 0;
    return (end.inMinutes - start.inMinutes) / 60.0;
  }

  /// True when [a] and [b] are the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
