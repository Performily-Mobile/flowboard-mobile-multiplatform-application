/// Time of the day (hour and minute) used by the hourly requests.
class RequestTime implements Comparable<RequestTime> {
  /// Creates the time; throws [ArgumentError] when the hour or the minute is out of range.
  RequestTime(this.hour, this.minute) {
    if (hour < 0 || hour > 23) throw ArgumentError('La hora debe estar entre 0 y 23.');
    if (minute < 0 || minute > 59) throw ArgumentError('Los minutos deben estar entre 0 y 59.');
  }

  /// Time of the text "HH:mm" or "HH:mm:ss", or null when it is not valid.
  static RequestTime? tryParse(String? raw) {
    if (raw == null) return null;
    final RegExpMatch? match = _pattern.firstMatch(raw.trim());
    if (match == null) return null;
    final int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return RequestTime(hour, minute);
  }

  static final RegExp _pattern = RegExp(r'^(\d{1,2}):(\d{2})(:\d{2}(\.\d+)?)?$');

  final int hour;
  final int minute;

  /// Minutes since midnight.
  int get inMinutes => hour * 60 + minute;

  /// True when this time is later than [other].
  bool isAfter(RequestTime other) => inMinutes > other.inMinutes;

  /// Text "HH:mm".
  String format() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(RequestTime other) => inMinutes.compareTo(other.inMinutes);

  @override
  bool operator ==(Object other) => other is RequestTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => format();
}
