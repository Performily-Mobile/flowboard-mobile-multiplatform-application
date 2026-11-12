import 'package:intl/intl.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';

/// Texts of the attendance screens: dates, times, hours, periods and names.
class AttendanceFormatters {
  const AttendanceFormatters._();

  static final NumberFormat _hours = NumberFormat('#,##0.#', 'en_US');

  static const List<String> _weekdays = <String>[
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  /// Date as dd/MM/yyyy.
  static String date(DateTime date) => '${_two(date.day)}/${_two(date.month)}/${date.year}';

  /// Date as dd/MM.
  static String shortDate(DateTime date) => '${_two(date.day)}/${_two(date.month)}';

  /// Time as HH:mm.
  static String time(DateTime time) => '${_two(time.hour)}:${_two(time.minute)}';

  /// Short day, for example "lun 03/11".
  static String day(DateTime date) => '${_weekdays[date.weekday - 1].substring(0, 3)} ${shortDate(date)}';

  /// Long day, for example "Lunes 03/11/2026".
  static String longDay(DateTime date) {
    final String weekday = _weekdays[date.weekday - 1];
    return '${weekday[0].toUpperCase()}${weekday.substring(1)} ${AttendanceFormatters.date(date)}';
  }

  /// Hours with one decimal, for example "8.5 h".
  static String hours(double value) => '${_hours.format(value)} h';

  /// Period, for example "01/11 al 11/11", or one day when both ends are equal.
  static String period(AttendancePeriod period) {
    if (period.from == period.to) return shortDate(period.from);
    return '${shortDate(period.from)} al ${shortDate(period.to)}';
  }

  /// Punches and hours of [record], for example "08:55 – 18:02 · 8.1 h · 0.5 h extra".
  static String punches(AttendanceRecord record) {
    final DateTime? checkIn = record.checkIn;
    final DateTime? checkOut = record.checkOut;
    if (checkIn == null) return 'Sin marcaciones';
    if (checkOut == null) return '${time(checkIn)} – sin salida';
    final String overtime = record.overtimeHours > 0 ? ' · ${hours(record.overtimeHours)} extra' : '';
    return '${time(checkIn)} – ${time(checkOut)} · ${hours(record.workedHours)}$overtime';
  }

  /// Percentage, for example "92%".
  static String percent(int value) => '$value%';

  /// Initials of the first two words of [name].
  static String initials(String name) {
    return _words(name).take(2).map((String word) => word.substring(0, 1).toUpperCase()).join();
  }

  /// First two words of [name], for example "Ana Torres" of "Ana Torres Ruiz".
  static String shortName(String name) => _words(name).take(2).join(' ');

  static String _two(int value) => value.toString().padLeft(2, '0');

  static List<String> _words(String name) =>
      name.trim().split(RegExp(r'\s+')).where((String word) => word.isNotEmpty).toList();
}
