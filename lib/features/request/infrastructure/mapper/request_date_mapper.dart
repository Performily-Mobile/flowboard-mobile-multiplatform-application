import 'package:flowboard/features/request/domain/valueobject/request_time.dart';

/// Reads and writes the dates and times exchanged with the API.
class RequestDateMapper {
  const RequestDateMapper._();

  /// Date of the text yyyy-MM-dd without its time, or null when it is not valid.
  static DateTime? parseDate(String? raw) {
    final DateTime? parsed = raw == null ? null : DateTime.tryParse(raw);
    return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Date and time of the text [raw], or null when it is not valid.
  static DateTime? parseDateTime(String? raw) => raw == null ? null : DateTime.tryParse(raw);

  /// Time of the text "HH:mm" or "HH:mm:ss", or null.
  static RequestTime? parseTime(String? raw) => RequestTime.tryParse(raw);

  /// Text yyyy-MM-dd of [date].
  static String formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }
}
