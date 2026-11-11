/// Converts the enums of the domain to and from the UPPER_SNAKE_CASE names used by the API.
class RequestEnumMapper {
  const RequestEnumMapper._();

  /// API name of [value], for example `inProgress` becomes `IN_PROGRESS`.
  static String toApi(Enum value) {
    return value.name
        .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (Match match) => '${match[1]}_${match[2]}')
        .toUpperCase();
  }

  /// Value of [values] whose API name is [raw], or [fallback] when none matches.
  static T fromApi<T extends Enum>(List<T> values, String? raw, T fallback) {
    for (final T value in values) {
      if (toApi(value) == raw) return value;
    }
    return fallback;
  }
}
