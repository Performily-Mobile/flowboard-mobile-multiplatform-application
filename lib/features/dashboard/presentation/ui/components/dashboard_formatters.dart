import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';

/// Text formatting helpers for the dashboard.
class DashboardFormatters {
  const DashboardFormatters._();

  static const List<String> _weekdays = <String>[
    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
  ];
  static const List<String> _months = <String>[
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  /// Title of the top bar, for example "Buenos días, Ana".
  static String greeting(String? firstName, DateTime now) {
    return _greeting(now) + (firstName == null ? '' : ', $firstName');
  }

  /// Subtitle of the top bar, for example "lunes 2 de noviembre".
  static String dateLabel(DateTime now) {
    return '${_weekdays[now.weekday - 1]} ${now.day} de ${_months[now.month - 1]}';
  }

  /// Freshness of the data, for example "Actualizado hace 4 min".
  static String updatedLabel(DateTime loadedAt, DateTime now) {
    final String text = _updatedAgo(loadedAt, now);
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Formats a counter, or a dash when the section could not be loaded.
  static String count(num? value) => value?.toString() ?? '—';

  /// Formats a lateness percentage, for example "2.8% de las marcaciones".
  static String lateness(double percentage) => '${percentage.toStringAsFixed(1)}% de las marcaciones';

  /// Describes a pending request, for example "Vacaciones · 19/10 al 23/10" or
  /// "Descanso médico · sin jefe asignado".
  static String requestDetail(RequestToAttend request) {
    final DateTime? start = request.startDate;
    final DateTime? end = request.endDate;
    final double? requestHours = request.hours;
    final String? period;
    if (request.withoutDirectManager) {
      period = 'sin jefe asignado';
    } else if (start == null) {
      period = null;
    } else if (requestHours != null) {
      period = '${_shortDate(start)} · ${_hours(requestHours)}';
    } else if (end == null || end == start) {
      period = '${_shortDate(start)} · 1 día';
    } else {
      period = '${_shortDate(start)} al ${_shortDate(end)}';
    }
    return <String>[request.requestTypeName, if (period != null) period].join(' · ');
  }

  /// Uppercase initials of the first two words of a name.
  static String initials(String name) {
    return name
        .split(' ')
        .where((String word) => word.trim().isNotEmpty)
        .take(2)
        .map((String word) => String.fromCharCode(word.runes.first).toUpperCase())
        .join();
  }

  static String _greeting(DateTime now) {
    if (now.hour < 12) return 'Buenos días';
    if (now.hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  static String _updatedAgo(DateTime loadedAt, DateTime now) {
    final int minutes = now.difference(loadedAt).inMinutes;
    if (minutes < 1) return 'actualizado ahora';
    if (minutes < 60) return 'actualizado hace $minutes min';
    return 'actualizado hace ${minutes ~/ 60} h';
  }

  static String _shortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  static String _hours(double value) {
    return value % 1 == 0 ? '${value.toInt()} h' : '${value.toStringAsFixed(1)} h';
  }
}
