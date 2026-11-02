/// Reads and writes the ISO dates (yyyy-MM-dd) exchanged with the API.
class IsoDateMapper {
  const IsoDateMapper._();

  /// Date of the text [raw] without its time.
  static DateTime parseDate(String raw) {
    final DateTime parsed = DateTime.parse(raw);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Date and time of the text [raw].
  static DateTime parseDateTime(String raw) => DateTime.parse(raw);

  /// Text yyyy-MM-dd of [date].
  static String format(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }
}
